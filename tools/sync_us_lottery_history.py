from __future__ import annotations

import argparse
import csv
import shutil
import sys
import time
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

import requests
from bs4 import BeautifulSoup


HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
}

# US games use 5 main + 1 supp — different column count from AU (7+2).
# Flutter CSV parser reads col[3..3+mainCount-1]=main, col[3+mainCount]=supp.
# For mainCount=5: main at col[3..7], supp at col[8].
CSV_HEADER = [
    "lottery_id",
    "draw_date",
    "draw_number",
    "main_1",
    "main_2",
    "main_3",
    "main_4",
    "main_5",
    "supp_1",
]


@dataclass(frozen=True)
class GameConfig:
    lottery_id: str
    name: str
    output_csv: str          # relative to repo root
    dart_file: str           # relative to repo root, or "" to skip
    dart_symbol: str
    main_count: int
    supp_count: int


GAMES = [
    GameConfig(
        lottery_id="us_powerball",
        name="Powerball",
        output_csv="docs/us_powerball.csv",
        dart_file="lib/data/seed_us_powerball.dart",
        dart_symbol="kUsPowerballDraws",
        main_count=5,
        supp_count=1,
    ),
    GameConfig(
        lottery_id="us_megamillions",
        name="Mega Millions",
        output_csv="docs/us_megamillions.csv",
        dart_file="lib/data/seed_us_megamillions.dart",
        dart_symbol="kUsMegaMillionsDraws",
        main_count=5,
        supp_count=1,
    ),
    GameConfig(
        lottery_id="us_lotto_america",
        name="Lotto America",
        output_csv="docs/us_lotto_america.csv",
        dart_file="",  # not yet wired in Flutter seed_lotteries.dart
        dart_symbol="kUsLottoAmericaDraws",
        main_count=5,
        supp_count=1,
    ),
]


# ---------------------------------------------------------------------------
# HTTP helpers
# ---------------------------------------------------------------------------

def fetch_json(url: str, params: dict | None = None, retries: int = 3) -> list[dict]:
    for attempt in range(retries):
        try:
            resp = requests.get(url, headers=HEADERS, params=params, timeout=20)
            resp.raise_for_status()
            return resp.json()
        except Exception as exc:
            if attempt == retries - 1:
                raise
            print(f"  Retry {attempt + 1}/{retries}: {exc}")
            time.sleep(2 ** attempt)
    return []


def fetch_html(url: str, retries: int = 3) -> str:
    for attempt in range(retries):
        try:
            resp = requests.get(url, headers=HEADERS, timeout=20)
            resp.raise_for_status()
            return resp.text
        except Exception as exc:
            if attempt == retries - 1:
                raise
            print(f"  Retry {attempt + 1}/{retries}: {exc}")
            time.sleep(2 ** attempt)
    return ""


# ---------------------------------------------------------------------------
# NY Open Data fetchers (Powerball + Mega Millions)
# Stable JSON API — no HTML parsing needed.
# Source: https://data.ny.gov
# ---------------------------------------------------------------------------

_NY_PB_URL = "https://data.ny.gov/resource/d6yy-54nr.json"
_NY_MM_URL = "https://data.ny.gov/resource/5xaw-6ayf.json"


def _ny_powerball_rows(rows: list[dict]) -> list[dict]:
    result = []
    for row in rows:
        nums = row.get("winning_numbers", "").split()
        if len(nums) < 6:
            continue
        date_str = row["draw_date"][:10]
        main = sorted(int(n) for n in nums[:5])
        bonus = int(nums[5])
        result.append({
            "lottery_id": "us_powerball",
            "draw_date": date_str,
            "draw_number": None,
            "main_numbers": main,
            "supp_numbers": [bonus],
        })
    return result


def _ny_megamillions_rows(rows: list[dict]) -> list[dict]:
    result = []
    for row in rows:
        nums = row.get("winning_numbers", "").split()
        mb = row.get("mega_ball", "").strip()
        if len(nums) < 5 or not mb:
            continue
        date_str = row["draw_date"][:10]
        main = sorted(int(n) for n in nums[:5])
        bonus = int(mb)
        result.append({
            "lottery_id": "us_megamillions",
            "draw_date": date_str,
            "draw_number": None,
            "main_numbers": main,
            "supp_numbers": [bonus],
        })
    return result


def fetch_ny_game(game: GameConfig, limit: int) -> list[dict]:
    if game.lottery_id == "us_powerball":
        url, mapper = _NY_PB_URL, _ny_powerball_rows
    else:
        url, mapper = _NY_MM_URL, _ny_megamillions_rows

    raw = fetch_json(url, params={"$limit": limit, "$order": "draw_date DESC"})
    return mapper(raw)


# ---------------------------------------------------------------------------
# Lotto America fetcher — lottery.net static HTML (year-by-year pages).
#
# FRAGILITY NOTE: depends on lottery.net HTML structure:
#   <tr>
#     <td>{weekday}{date}</td><td>{draw_number}</td><td>...balls...</td>
#   </tr>
# Ball selectors: li.ball (main), li.star-ball (Star Ball).
# If this breaks, swap the URL / selectors below without touching AU logic.
# ---------------------------------------------------------------------------

_LOTTERY_NET_BASE = "https://www.lottery.net/lotto-america/numbers"
_MONTH_MAP = {
    "January": 1, "February": 2, "March": 3, "April": 4,
    "May": 5, "June": 6, "July": 7, "August": 8,
    "September": 9, "October": 10, "November": 11, "December": 12,
}
_WEEKDAYS = ("Monday", "Tuesday", "Wednesday", "Thursday",
             "Friday", "Saturday", "Sunday")


def _parse_lotto_america_page(html: str) -> list[dict]:
    soup = BeautifulSoup(html, "html.parser")
    draws: list[dict] = []

    for row in soup.select("table tr"):
        cells = row.find_all("td")
        if len(cells) < 2:
            continue

        # Cell 0: "{Weekday}{Month} {Day}, {Year}"
        date_text = cells[0].get_text(strip=True)
        for wday in _WEEKDAYS:
            date_text = date_text.replace(wday, "")
        date_text = date_text.strip()

        # Parse "April 15, 2026" → "2026-04-15"
        parts = date_text.replace(",", "").split()
        if len(parts) != 3:
            continue
        month_name, day_str, year_str = parts
        month = _MONTH_MAP.get(month_name)
        if not month:
            continue
        try:
            draw_date = f"{int(year_str):04d}-{month:02d}-{int(day_str):02d}"
        except ValueError:
            continue

        # Cell 1: draw number
        draw_number_text = cells[1].get_text(strip=True)
        try:
            draw_number = int(draw_number_text)
        except ValueError:
            draw_number = None

        # Balls
        main = [int(li.get_text(strip=True)) for li in row.select("li.ball")]
        star = [int(li.get_text(strip=True)) for li in row.select("li.star-ball")]

        if len(main) != 5 or len(star) != 1:
            continue

        draws.append({
            "lottery_id": "us_lotto_america",
            "draw_date": draw_date,
            "draw_number": draw_number,
            "main_numbers": sorted(main),
            "supp_numbers": star,
        })

    return draws


def fetch_lotto_america(recent_draws: int | None) -> list[dict]:
    current_year = datetime.now().year
    years = [current_year] if recent_draws else list(range(current_year, 2017, -1))

    draws: list[dict] = []
    for year in years:
        url = f"{_LOTTERY_NET_BASE}/{year}"
        html = fetch_html(url)
        page_draws = _parse_lotto_america_page(html)
        draws.extend(page_draws)
        if recent_draws and len(draws) >= recent_draws:
            break
        time.sleep(0.2)

    if recent_draws:
        draws.sort(key=lambda r: r["draw_date"], reverse=True)
        draws = draws[:recent_draws]

    return draws


# ---------------------------------------------------------------------------
# CSV read / write (mirrors AU script pattern)
# ---------------------------------------------------------------------------

def read_csv_rows(game: GameConfig) -> list[dict]:
    path = Path(game.output_csv)
    if not path.exists():
        return []
    rows: list[dict] = []
    with open(path, newline="", encoding="utf-8") as fh:
        for item in csv.DictReader(fh):
            main = [int(item[f"main_{i}"]) for i in range(1, 6) if item.get(f"main_{i}")]
            supp = [int(item["supp_1"])] if item.get("supp_1") else []
            rows.append({
                "lottery_id": item["lottery_id"],
                "draw_date": item["draw_date"],
                "draw_number": int(item["draw_number"]) if item.get("draw_number") else None,
                "main_numbers": main,
                "supp_numbers": supp,
            })
    return rows


def write_csv(game: GameConfig, rows: list[dict]) -> None:
    path = Path(game.output_csv)
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        shutil.copy2(path, path.with_name(f"{path.stem}_backup{path.suffix}"))

    with open(path, "w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(CSV_HEADER)
        for row in rows:
            main = row["main_numbers"] + [""] * (5 - len(row["main_numbers"]))
            supp = row["supp_numbers"] + [""] * (1 - len(row["supp_numbers"]))
            writer.writerow([
                row["lottery_id"],
                row["draw_date"],
                row["draw_number"] or "",
                *main[:5],
                *supp[:1],
            ])


def _row_key(row: dict) -> tuple:
    return (
        row["draw_date"],
        tuple(sorted(row["main_numbers"])),
        tuple(row["supp_numbers"]),
    )


def merge_rows(existing: list[dict], incoming: list[dict]) -> list[dict]:
    merged: dict[tuple, dict] = {}
    for row in existing + incoming:
        merged[_row_key(row)] = row
    return sorted(
        merged.values(),
        key=lambda r: (r["draw_date"], r.get("draw_number") or 0),
        reverse=True,
    )


# ---------------------------------------------------------------------------
# Dart seed writer (mirrors AU script pattern)
# ---------------------------------------------------------------------------

def write_dart_seed(game: GameConfig) -> None:
    if not game.dart_file:
        return  # game not yet wired in Flutter

    rows = read_csv_rows(game)
    updated_at = datetime.now().strftime("%Y-%m-%d")
    lines = [
        "import '../models/lottery_draw.dart';",
        "",
        f"// US {game.name} — {len(rows)} draws. Updated: {updated_at}",
        f"// Source: NY Open Data / lottery.net",
        f"final List<LotteryDraw> {game.dart_symbol} = [",
    ]
    for row in rows:
        d = datetime.strptime(row["draw_date"], "%Y-%m-%d")
        bonus_expr = (
            f", bonusNumbers: [{', '.join(map(str, row['supp_numbers']))}]"
            if row["supp_numbers"] else ""
        )
        lines.append(
            f"  LotteryDraw(lotteryId: '{game.lottery_id}', "
            f"drawDate: DateTime({d.year}, {d.month}, {d.day}), "
            f"mainNumbers: [{', '.join(map(str, row['main_numbers']))}]"
            f"{bonus_expr}),"
        )
    lines.append("];")
    lines.append("")
    Path(game.dart_file).write_text("\n".join(lines), encoding="utf-8")


# ---------------------------------------------------------------------------
# Per-game sync dispatcher
# ---------------------------------------------------------------------------

def sync_game(game: GameConfig, recent_draws: int | None) -> int:
    """Returns number of new rows added. Raises on failure."""
    previous_count = len(read_csv_rows(game))

    if game.lottery_id in ("us_powerball", "us_megamillions"):
        limit = (recent_draws or 2000)
        incoming = fetch_ny_game(game, limit=limit)
    else:
        incoming = fetch_lotto_america(recent_draws)

    if recent_draws is not None:
        existing = read_csv_rows(game)
        rows = merge_rows(existing, incoming)
    else:
        # Full rebuild: dedupe incoming only
        seen: dict[tuple, dict] = {}
        for row in incoming:
            seen[_row_key(row)] = row
        rows = sorted(
            seen.values(),
            key=lambda r: (r["draw_date"], r.get("draw_number") or 0),
            reverse=True,
        )

    write_csv(game, rows)
    if game.dart_file:
        write_dart_seed(game)

    return max(len(rows) - previous_count, 0)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Sync US lottery CSVs and Dart seed files."
    )
    parser.add_argument(
        "--recent-draws",
        type=int,
        default=None,
        metavar="N",
        help="Only fetch the latest N draws per game, then merge into existing CSV.",
    )
    parser.add_argument(
        "--game",
        choices=("powerball", "mega_millions", "lotto_america", "all"),
        default="all",
        help="Which game to sync. Default: all",
    )
    return parser.parse_args()


def selected_games(game_arg: str) -> list[GameConfig]:
    if game_arg == "powerball":
        return [GAMES[0]]
    if game_arg == "mega_millions":
        return [GAMES[1]]
    if game_arg == "lotto_america":
        return [GAMES[2]]
    return list(GAMES)


def main() -> None:
    args = parse_args()
    games = selected_games(args.game)
    mode_label = (
        f"recent {args.recent_draws} draws"
        if args.recent_draws is not None
        else "full history"
    )

    failed: list[str] = []
    for game in games:
        print(f"\nSyncing {game.name} ({mode_label})...")
        try:
            new_rows = sync_game(game, args.recent_draws)
            if new_rows == 0 and args.recent_draws is not None:
                print(f"{game.name}: no new draws")
            else:
                total = len(read_csv_rows(game))
                print(f"{game.name}: +{new_rows} new draw(s) (total: {total})")
            if game.dart_file:
                print(f"  → {game.output_csv} + {game.dart_file} updated")
            else:
                print(f"  → {game.output_csv} updated (Dart seed not yet wired)")
        except Exception as exc:
            print(f"{game.name}: FAILED — {exc}")
            failed.append(game.name)

    print()
    if len(failed) == len(games):
        print(f"ERROR: all games failed: {', '.join(failed)}")
        sys.exit(1)
    elif failed:
        print(f"WARNING: partial failure — {', '.join(failed)}")
    else:
        print("All games synced successfully.")


if __name__ == "__main__":
    main()
