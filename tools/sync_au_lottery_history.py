from __future__ import annotations

import argparse
import csv
import re
import shutil
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

CSV_HEADER = [
    "lottery_id",
    "draw_date",
    "draw_number",
    "main_1",
    "main_2",
    "main_3",
    "main_4",
    "main_5",
    "main_6",
    "main_7",
    "supp_1",
    "supp_2",
]


@dataclass(frozen=True)
class GameConfig:
    lottery_id: str
    name: str
    slug: str
    output_csv: str
    dart_file: str
    dart_symbol: str
    main_count: int
    supp_count: int


GAMES = [
    GameConfig(
        lottery_id="au_powerball",
        name="Powerball",
        slug="powerball",
        output_csv="powerball_5y.csv",
        dart_file="lib/data/seed_powerball.dart",
        dart_symbol="kPowerballDraws",
        main_count=7,
        supp_count=1,
    ),
    GameConfig(
        lottery_id="au_ozlotto",
        name="Oz Lotto",
        slug="oz-lotto",
        output_csv="oz_lotto_5y.csv",
        dart_file="lib/data/seed_oz_lotto.dart",
        dart_symbol="kOzLottoDraws",
        main_count=7,
        supp_count=2,
    ),
    GameConfig(
        lottery_id="au_saturday",
        name="Saturday Lotto",
        slug="saturday-lotto",
        output_csv="saturday_lotto_5y.csv",
        dart_file="lib/data/seed_saturday_lotto.dart",
        dart_symbol="kSaturdayLottoDraws",
        main_count=6,
        supp_count=2,
    ),
]


def fetch(url: str) -> str:
    response = requests.get(url, headers=HEADERS, timeout=20)
    response.raise_for_status()
    return response.text


def archive_years(years: int = 5) -> list[int]:
    current_year = datetime.now().year
    return list(range(current_year, current_year - years - 1, -1))


def extract_result_urls(html: str, game: GameConfig) -> list[str]:
    pattern = re.compile(rf'href="(/(?:{re.escape(game.slug)})/results/\d{{2}}-\d{{2}}-\d{{4}})"')
    return [
        f"https://australia.national-lottery.com{match}"
        for match in pattern.findall(html)
    ]


def collect_result_urls(game: GameConfig) -> list[str]:
    urls: set[str] = set()
    pages = [f"https://australia.national-lottery.com/{game.slug}/past-results"]
    pages.extend(
        f"https://australia.national-lottery.com/{game.slug}/results-archive-{year}"
        for year in archive_years()
    )

    for page_url in pages:
        html = fetch(page_url)
        for url in extract_result_urls(html, game):
            urls.add(url)
        time.sleep(0.15)

    return sorted(urls)


def collect_recent_result_urls(game: GameConfig, recent_draws: int) -> list[str]:
    html = fetch(f"https://australia.national-lottery.com/{game.slug}/past-results")
    urls: list[str] = []
    seen: set[str] = set()
    for url in extract_result_urls(html, game):
        if url in seen:
            continue
        seen.add(url)
        urls.append(url)
        if len(urls) >= recent_draws:
            break
    return urls


def parse_draw(url: str, game: GameConfig) -> dict | None:
    html = fetch(url)
    soup = BeautifulSoup(html, "html.parser")
    ball_text = [item.get_text(strip=True) for item in soup.select("ul.balls li.ball")]
    if len(ball_text) < game.main_count + game.supp_count:
        return None

    values = [int(value) for value in ball_text[: game.main_count + game.supp_count]]
    date_match = re.search(r"/results/(\d{2})-(\d{2})-(\d{4})", url)
    if not date_match:
        return None
    day, month, year = date_match.groups()
    draw_date = f"{year}-{month}-{day}"

    title = soup.title.get_text(" ", strip=True) if soup.title else ""
    draw_match = re.search(r"Draw\s+(\d+)", title, re.IGNORECASE)
    draw_number = int(draw_match.group(1)) if draw_match else None

    return {
        "lottery_id": game.lottery_id,
        "draw_date": draw_date,
        "draw_number": draw_number,
        "main_numbers": values[: game.main_count],
        "supp_numbers": values[game.main_count : game.main_count + game.supp_count],
    }


def scrape_game(game: GameConfig) -> list[dict]:
    rows: list[dict] = []
    for index, url in enumerate(collect_result_urls(game), start=1):
        row = parse_draw(url, game)
        if row:
            rows.append(row)
        if index % 25 == 0:
            print(f"{game.name}: parsed {index} result pages")
        time.sleep(0.15)

    deduped = {row["draw_date"]: row for row in rows}
    return [deduped[key] for key in sorted(deduped.keys(), reverse=True)]


def scrape_recent_draws(game: GameConfig, recent_draws: int) -> list[dict]:
    rows: list[dict] = []
    for url in collect_recent_result_urls(game, recent_draws):
        row = parse_draw(url, game)
        if row:
            rows.append(row)
        time.sleep(0.15)
    return rows


def write_csv(game: GameConfig, rows: list[dict]) -> None:
    csv_path = Path(game.output_csv)
    if csv_path.exists():
        backup_path = csv_path.with_name(f"{csv_path.stem}_backup{csv_path.suffix}")
        shutil.copy2(csv_path, backup_path)

    with open(game.output_csv, "w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(CSV_HEADER)
        for row in rows:
            main = row["main_numbers"] + [""] * (7 - len(row["main_numbers"]))
            supp = row["supp_numbers"] + [""] * (2 - len(row["supp_numbers"]))
            writer.writerow(
                [
                    row["lottery_id"],
                    row["draw_date"],
                    row["draw_number"] or "",
                    *main[:7],
                    *supp[:2],
                ]
            )


def read_csv_rows(game: GameConfig) -> list[dict]:
    rows: list[dict] = []
    with open(game.output_csv, newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        for item in reader:
            main_numbers = [
                int(item[f"main_{index}"])
                for index in range(1, 8)
                if item[f"main_{index}"]
            ]
            supp_numbers = [
                int(item[f"supp_{index}"])
                for index in range(1, 3)
                if item[f"supp_{index}"]
            ]
            rows.append(
                {
                    "lottery_id": item["lottery_id"],
                    "draw_date": item["draw_date"],
                    "draw_number": int(item["draw_number"]) if item["draw_number"] else None,
                    "main_numbers": main_numbers,
                    "supp_numbers": supp_numbers,
                }
            )
    return rows


def merge_rows(existing_rows: list[dict], incoming_rows: list[dict]) -> list[dict]:
    merged: dict[tuple[str | int | None, str], dict] = {}

    for row in existing_rows + incoming_rows:
        key = (row.get("draw_number"), row["draw_date"])
        merged[key] = row

    return sorted(
        merged.values(),
        key=lambda row: (row["draw_date"], row.get("draw_number") or 0),
        reverse=True,
    )


def write_dart_seed(game: GameConfig) -> None:
    rows = read_csv_rows(game)
    updated_at = datetime.now().strftime("%Y-%m-%d")
    lines = [
        "import '../models/lottery_draw.dart';",
        "",
        f"const String {game.dart_symbol}UpdatedAt = '{updated_at}';",
        "",
        f"/// {len(rows)} real AU {game.name} draws.",
        f"final List<LotteryDraw> {game.dart_symbol} = [",
    ]

    for row in rows:
        draw_date = datetime.strptime(row["draw_date"], "%Y-%m-%d")
        bonus_expr = (
            f", bonusNumbers: [{', '.join(map(str, row['supp_numbers']))}]"
            if row["supp_numbers"]
            else ""
        )
        lines.append(
            "  LotteryDraw("
            f"lotteryId: '{game.lottery_id}', "
            f"drawDate: DateTime({draw_date.year}, {draw_date.month}, {draw_date.day}), "
            f"mainNumbers: [{', '.join(map(str, row['main_numbers']))}]"
            f"{bonus_expr}),"
        )

    lines.append("];")
    lines.append("")
    Path(game.dart_file).write_text("\n".join(lines), encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Sync AU lottery CSVs and Dart seed files."
    )
    parser.add_argument(
        "--recent-draws",
        type=int,
        default=None,
        help="Only fetch the latest N draws per lottery, then merge into the existing CSV.",
    )
    parser.add_argument(
        "--game",
        choices=("powerball", "ozlotto", "saturday", "all"),
        default="all",
        help="Which lottery to sync. Default: all",
    )
    return parser.parse_args()


def selected_games(game_arg: str) -> list[GameConfig]:
    if game_arg == "powerball":
        return [GAMES[0]]
    if game_arg == "ozlotto":
        return [GAMES[1]]
    if game_arg == "saturday":
        return [GAMES[2]]
    return GAMES


def main() -> None:
    args = parse_args()

    for game in selected_games(args.game):
        mode_label = (
            f"recent {args.recent_draws} draws"
            if args.recent_draws is not None
            else "full history"
        )
        print(f"\nSyncing {game.name} ({mode_label})...")

        previous_count = len(read_csv_rows(game)) if Path(game.output_csv).exists() else 0
        if args.recent_draws is None:
            rows = scrape_game(game)
        else:
            existing_rows = read_csv_rows(game) if Path(game.output_csv).exists() else []
            incoming_rows = scrape_recent_draws(game, args.recent_draws)
            rows = merge_rows(existing_rows, incoming_rows)

        write_csv(game, rows)
        write_dart_seed(game)
        new_rows = len(rows) - previous_count
        if args.recent_draws is not None and new_rows == 0:
            print(f"No new draws found. {game.name} data already up to date.")
        else:
            print(f"{game.name}: +{max(new_rows, 0)} new draw(s) (total: {len(rows)})")
        print(f"{game.output_csv}: {len(rows)} rows")
        print(f"{game.dart_file}: updated")


if __name__ == "__main__":
    main()
