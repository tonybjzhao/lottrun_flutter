#!/usr/bin/env python3
"""
Sync Japan lottery (Loto 6 & Loto 7) historical data from Lottolyzer.

Data source: https://en.lottolyzer.com/history/japan/
- Loto 6: ~1,750 draws available (35 pages × 50 draws)
- Loto 7: ~700 draws available (14 pages × 50 draws)

Usage:
    python tools/sync_jp_lottery_history.py --limit 1000
"""

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
    base_url: str
    output_csv: str
    dart_file: str
    dart_symbol: str
    main_count: int
    bonus_count: int


GAMES = [
    GameConfig(
        lottery_id="jp_loto6",
        name="Japan Loto 6",
        base_url="https://en.lottolyzer.com/history/japan/lotto-6/page/{page}/per-page/50/number-view",
        output_csv="docs/jp_loto6.csv",
        dart_file="lib/data/seed_jp_loto6.dart",
        dart_symbol="kJpLoto6Draws",
        main_count=6,
        bonus_count=1,
    ),
    GameConfig(
        lottery_id="jp_loto7",
        name="Japan Loto 7",
        base_url="https://en.lottolyzer.com/history/japan/lotto-7/page/{page}/per-page/50/number-view",
        output_csv="docs/jp_loto7.csv",
        dart_file="lib/data/seed_jp_loto7.dart",
        dart_symbol="kJpLoto7Draws",
        main_count=7,
        bonus_count=2,
    ),
]


def fetch_html(url: str, retries: int = 3) -> str:
    """Fetch HTML with retries."""
    for attempt in range(retries):
        try:
            response = requests.get(url, headers=HEADERS, timeout=30)
            response.raise_for_status()
            return response.text
        except Exception as e:
            if attempt == retries - 1:
                raise RuntimeError(f"Failed to fetch {url} after {retries} attempts: {e}")
            time.sleep(2 ** attempt)
    return ""


def parse_lottolyzer_page(html: str, game: GameConfig) -> list[dict]:
    """Parse Lottolyzer results page and extract draws."""
    soup = BeautifulSoup(html, "html.parser")
    draws = []

    # Find all text elements that say "Draw XXXX"
    draw_pattern = re.compile(r"^Draw \d+$")
    draw_elements = soup.find_all(string=draw_pattern)

    for elem in draw_elements:
        try:
            draw_text = elem.strip()

            # Navigate up the DOM to find the container that has both date and numbers
            parent = elem.parent
            container = None

            # Go up max 10 levels to find a div containing numbers
            for _ in range(10):
                if not parent or parent.name != "div":
                    parent = parent.parent if parent else None
                    continue

                # Check if this parent has a numbers div
                nums_div = parent.find("div", class_="numbers")
                if nums_div:
                    container = parent
                    break

                parent = parent.parent

            if not container:
                continue

            # Find date
            date_div = container.find("div", class_="date")
            if not date_div:
                continue

            date_text = date_div.get_text(strip=True)
            draw_date = parse_date(date_text)
            if not draw_date:
                continue

            # Extract numbers from ball images
            ball_imgs = nums_div.find_all("img", class_="ball")
            numbers = []

            for img in ball_imgs:
                alt_text = img.get("alt", "")
                if alt_text and alt_text.isdigit():
                    num = int(alt_text)
                    # Filter valid numbers for this game
                    if game.lottery_id == "jp_loto6":
                        if 1 <= num <= 43:
                            numbers.append(num)
                    else:  # jp_loto7
                        if 1 <= num <= 37:
                            numbers.append(num)

            # We need main_count + bonus_count numbers
            required_total = game.main_count + game.bonus_count

            if len(numbers) >= required_total:
                main_numbers = numbers[:game.main_count]
                bonus_numbers = numbers[game.main_count:game.main_count + game.bonus_count]

                draw = {
                    "game_id": game.lottery_id,
                    "country_code": "JP",
                    "draw_date": draw_date,
                    "draw_number": "",  # Will be assigned later
                    "main": main_numbers,
                    "bonus": bonus_numbers,
                }
                draws.append(draw)

        except (ValueError, IndexError, AttributeError):
            # Skip invalid draws
            continue

    return draws


def parse_date(date_str: str) -> str | None:
    """Parse date string to YYYY-MM-DD format."""
    date_str = date_str.strip()

    # Try multiple date formats
    formats = [
        "%d %b %Y",       # 11 Jun 2026 (Lottolyzer format)
        "%d %B %Y",       # 11 June 2026
        "%b %d, %Y",      # Jun 12, 2026
        "%B %d, %Y",      # June 12, 2026
        "%Y-%m-%d",       # 2026-06-12
        "%d/%m/%Y",       # 12/06/2026
        "%m/%d/%Y",       # 06/12/2026
        "%d.%m.%Y",       # 12.06.2026
    ]

    for fmt in formats:
        try:
            dt = datetime.strptime(date_str, fmt)
            return dt.strftime("%Y-%m-%d")
        except ValueError:
            continue

    return None


def fetch_all_draws(game: GameConfig, limit: int) -> list[dict]:
    """Fetch draws across multiple pages."""
    all_draws: list[dict] = []
    page = 1
    max_pages = 50  # Safety limit

    print(f"\n📥 Fetching {game.name}...")

    while len(all_draws) < limit and page <= max_pages:
        url = game.base_url.format(page=page)
        print(f"  🔍 Page {page}: {url}")

        try:
            html = fetch_html(url)
            draws = parse_lottolyzer_page(html, game)

            if not draws:
                print(f"  ⚠ No draws found on page {page}, stopping")
                break

            all_draws.extend(draws)
            print(f"  ✓ Found {len(draws)} draws (total: {len(all_draws)})")

            page += 1
            time.sleep(1.5)  # Be polite to the server

        except Exception as e:
            print(f"  ✗ Error fetching page {page}: {e}")
            break

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
        f"const String {dart_symbol}UpdatedAt = '{datetime.now().strftime('%Y-%m-%d')}';",
        "",
        f"/// {len(draws)} real Japan lottery draws from Lottolyzer",
        f"final List<LotteryDraw> {dart_symbol} = [",
    ]

    for draw in draws:
        date_parts = draw["draw_date"].split("-")
        year, month, day = int(date_parts[0]), int(date_parts[1]), int(date_parts[2])

        main_str = ", ".join(str(n) for n in draw["main"])
        bonus_str = ", ".join(str(n) for n in draw["bonus"])

        lottery_id = draw["game_id"]

        lines.append(
            f'  LotteryDraw(lotteryId: \'{lottery_id}\', '
            f'drawDate: DateTime({year}, {month}, {day}), '
            f'mainNumbers: [{main_str}], bonusNumbers: [{bonus_str}]),'
        )

    lines.append("];")
    lines.append("")

    dart_path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Sync Japan lottery history from Lottolyzer")
    parser.add_argument("--limit", type=int, default=1000, help="Max draws per game")
    args = parser.parse_args()

    print("=" * 80)
    print("JAPAN LOTTERY DATA SYNC - LOTTOLYZER SOURCE")
    print("=" * 80)

    results = []

    for game in GAMES:
        try:
            # Fetch draws
            draws = fetch_all_draws(game, args.limit)

            if not draws:
                print(f"\n❌ {game.name}: No draws found!")
                results.append({
                    "game": game.name,
                    "records": 0,
                    "earliest": "N/A",
                    "latest": "N/A",
                    "status": "FAILED"
                })
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
            latest = draws[0]["draw_date"]
            earliest = draws[-1]["draw_date"]
            print(f"📅 Date range: {earliest} to {latest}")

            results.append({
                "game": game.name,
                "records": len(draws),
                "earliest": earliest,
                "latest": latest,
                "status": "SUCCESS"
            })

        except Exception as e:
            print(f"\n❌ {game.name} failed: {e}")
            import traceback
            traceback.print_exc()
            results.append({
                "game": game.name,
                "records": 0,
                "earliest": "N/A",
                "latest": "N/A",
                "status": "ERROR"
            })

    # Final summary table
    print("\n" + "=" * 80)
    print("SYNC COMPLETE - SUMMARY")
    print("=" * 80)
    print(f"{'Game':<20} {'Records':<10} {'Earliest Draw':<15} {'Latest Draw':<15} {'Status':<10}")
    print("-" * 80)
    for r in results:
        print(f"{r['game']:<20} {r['records']:<10} {r['earliest']:<15} {r['latest']:<15} {r['status']:<10}")
    print("=" * 80)


if __name__ == "__main__":
    main()
