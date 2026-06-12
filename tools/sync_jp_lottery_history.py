from __future__ import annotations

import argparse
import csv
import re
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


@dataclass(frozen=True)
class GameConfig:
    lottery_id: str
    name: str
    archive_url: str
    output_csv: str
    dart_file: str
    dart_symbol: str
    main_count: int
    bonus_count: int
    year_start: int


GAMES = [
    GameConfig(
        lottery_id="jp_loto6",
        name="Japan Loto 6",
        archive_url="https://www.lotto.net/japan-loto-6/results/{year}",
        output_csv="docs/jp_loto6.csv",
        dart_file="lib/data/seed_jp_loto6.dart",
        dart_symbol="kJpLoto6Draws",
        main_count=6,
        bonus_count=1,
        year_start=2000,
    ),
    GameConfig(
        lottery_id="jp_loto7",
        name="Japan Loto 7",
        archive_url="https://www.lotto.net/japan-loto-7/results/{year}",
        output_csv="docs/jp_loto7.csv",
        dart_file="lib/data/seed_jp_loto7.dart",
        dart_symbol="kJpLoto7Draws",
        main_count=7,
        bonus_count=2,
        year_start=2013,
    ),
]

# Date pattern for English date format: "Friday March 7th 2025"
DATE_RE = re.compile(
    r"\b(?:Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)\s+"
    r"(January|February|March|April|May|June|July|August|September|October|November|December)\s+"
    r"(\d{1,2})(?:st|nd|rd|th)?\s+(\d{4})\b"
)

MONTHS = {
    "January": 1, "February": 2, "March": 3, "April": 4,
    "May": 5, "June": 6, "July": 7, "August": 8,
    "September": 9, "October": 10, "November": 11, "December": 12,
}


def fetch_html(url: str, retries: int = 3) -> str:
    """Fetch HTML with retries."""
    for attempt in range(retries):
        try:
            response = requests.get(url, headers=HEADERS, timeout=20)
            response.raise_for_status()
            return response.text
        except Exception as e:
            if attempt == retries - 1:
                raise RuntimeError(f"Failed to fetch {url} after {retries} attempts: {e}")
            time.sleep(2 ** attempt)
    return ""


def parse_archive_page(html: str, game: GameConfig) -> list[dict]:
    """Parse lotto.net archive page and extract draw results."""
    soup = BeautifulSoup(html, "html.parser")
    text = soup.get_text("\n", strip=True)

    # Find all date matches
    date_matches = list(DATE_RE.finditer(text))
    if not date_matches:
        return []

    rows: list[dict] = []

    # Extract numbers - look for number patterns near dates
    # lotto.net typically shows: "1 2 3 4 5 6 Bonus: 7"
    lines = text.split("\n")

    for i, line in enumerate(lines):
        # Look for date in line
        date_match = DATE_RE.search(line)
        if not date_match:
            continue

        month_name, day, year = date_match.groups()
        draw_date = f"{year}-{MONTHS[month_name]:02d}-{int(day):02d}"

        # Look for numbers in nearby lines (within next 5 lines)
        for j in range(i, min(i + 5, len(lines))):
            # Find sequences of numbers
            numbers = re.findall(r'\b(\d{1,2})\b', lines[j])
            numbers = [int(n) for n in numbers if 1 <= int(n) <= 50]  # Filter valid range

            if len(numbers) >= game.main_count + game.bonus_count:
                main_numbers = numbers[:game.main_count]
                bonus_numbers = numbers[game.main_count:game.main_count + game.bonus_count]

                row = {
                    "game_id": game.lottery_id,
                    "country_code": "JP",
                    "draw_date": draw_date,
                    "draw_number": "",  # Will be set later
                    "main": main_numbers,
                    "bonus": bonus_numbers,
                }
                rows.append(row)
                break

    return rows


def fetch_all_draws(game: GameConfig, limit: int) -> list[dict]:
    """Fetch draws across multiple years."""
    current_year = datetime.now().year
    all_draws: list[dict] = []

    print(f"\n📥 Fetching {game.name}...")

    for year in range(current_year, game.year_start - 1, -1):
        if len(all_draws) >= limit:
            break

        url = game.archive_url.format(year=year)
        print(f"  🔍 {year}: {url}")

        try:
            html = fetch_html(url)
            draws = parse_archive_page(html, game)

            if draws:
                all_draws.extend(draws)
                print(f"  ✓ Found {len(draws)} draws from {year}")
            else:
                print(f"  ⚠ No draws found for {year}")
        except Exception as e:
            print(f"  ✗ Error fetching {year}: {e}")
            continue

        time.sleep(1)  # Be polite to the server

    # Sort by date (newest first) and limit
    all_draws.sort(key=lambda x: x["draw_date"], reverse=True)
    all_draws = all_draws[:limit]

    # Assign draw numbers (descending from most recent)
    for idx, draw in enumerate(all_draws):
        draw["draw_number"] = str(len(all_draws) - idx)

    return all_draws


def write_csv(draws: list[dict], output_path: Path, game: GameConfig) -> None:
    """Write draws to CSV file."""
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with output_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)

        # Header
        main_cols = [f"main_{i+1}" for i in range(7)]
        bonus_cols = [f"bonus_{i+1}" for i in range(2)]
        header = ["game_id", "country_code", "draw_date", "draw_number"] + main_cols + bonus_cols
        writer.writerow(header)

        # Data rows
        for draw in draws:
            main = draw["main"]
            bonus = draw["bonus"]

            # Pad to 7 main numbers and 2 bonus numbers
            main_padded = main + [""] * (7 - len(main))
            bonus_padded = bonus + [""] * (2 - len(bonus))

            row = [
                draw["game_id"],
                draw["country_code"],
                draw["draw_date"],
                draw["draw_number"],
            ] + main_padded + bonus_padded

            writer.writerow(row)


def generate_dart_file(draws: list[dict], dart_path: Path, dart_symbol: str) -> None:
    """Generate Flutter seed file."""
    dart_path.parent.mkdir(parents=True, exist_ok=True)

    lines = [
        "import '../models/lottery_draw.dart';",
        "",
        f"final List<LotteryDraw> {dart_symbol} = [",
    ]

    for draw in draws:
        main_str = ", ".join(str(n) for n in draw["main"])
        bonus_str = ", ".join(str(n) for n in draw["bonus"])

        lines.append(
            f'  LotteryDraw(date: "{draw["draw_date"]}", '
            f'drawNumber: "{draw["draw_number"]}", '
            f'main: [{main_str}], bonus: [{bonus_str}]),'
        )

    lines.append("];")
    lines.append("")

    dart_path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Sync Japan lottery history")
    parser.add_argument("--limit", type=int, default=500, help="Max draws per game")
    args = parser.parse_args()

    print("=" * 80)
    print("JAPAN LOTTERY DATA SYNC")
    print("=" * 80)

    for game in GAMES:
        try:
            # Fetch draws
            draws = fetch_all_draws(game, args.limit)

            if not draws:
                print(f"\n❌ {game.name}: No draws found!")
                continue

            # Write CSV
            csv_path = Path(game.output_csv)
            write_csv(draws, csv_path, game)
            print(f"\n✅ CSV: {csv_path} ({len(draws)} draws)")

            # Generate Dart file
            dart_path = Path(game.dart_file)
            generate_dart_file(draws, dart_path, game.dart_symbol)
            print(f"✅ Dart: {dart_path}")

            # Summary
            if draws:
                latest = draws[0]["draw_date"]
                oldest = draws[-1]["draw_date"]
                print(f"📅 Date range: {oldest} to {latest}")

        except Exception as e:
            print(f"\n❌ {game.name} failed: {e}")
            import traceback
            traceback.print_exc()

    print("\n" + "=" * 80)
    print("SYNC COMPLETE")
    print("=" * 80)


if __name__ == "__main__":
    main()
