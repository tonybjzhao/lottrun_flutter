#!/usr/bin/env python3
"""
Sync France lottery historical data from official FDJ (Française des Jeux) API.

Fetches historical CSVs for:
- France Loto (fr_loto): 5 main (1-49) + 1 Chance Number (1-10)
- EuroMillions (fr_euromillions): 5 main (1-50) + 2 Lucky Stars (1-12)

Data source: https://www.fdj.fr official API
"""

from __future__ import annotations

import argparse
import csv
import io
import time
import zipfile
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

import requests


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
    zip_urls: list[str]  # FDJ API ZIP file URLs (ordered newest to oldest)
    output_csv: str
    dart_file: str
    dart_symbol: str
    main_count: int
    bonus_count: int


GAMES = [
    GameConfig(
        lottery_id="fr_loto",
        name="France Loto",
        zip_urls=[
            # November 2019 – June 2026
            "https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afp6",
            # February 2019 – November 2019
            "https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afo6",
            # March 2017 – February 2019
            "https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afn6",
            # October 2008 – March 2017
            "https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afm6",
            # May 1976 – October 2008
            "https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afl6",
        ],
        output_csv="docs/fr_loto.csv",
        dart_file="lib/data/seed_france_lotteries.dart",
        dart_symbol="kFrLotoDraws",
        main_count=5,
        bonus_count=1,
    ),
    GameConfig(
        lottery_id="fr_euromillions",
        name="France EuroMillions",
        zip_urls=[
            # February 2020 – June 2026
            "https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afe6",
            # March 2019 – February 2020
            "https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afd6",
            # September 2016 – February 2019
            "https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afc6",
            # February 2014 – September 2016
            "https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afb6",
            # May 2011 – February 2014
            "https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afa9",
            # February 2004 – May 2011
            "https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afa8",
        ],
        output_csv="docs/fr_euromillions.csv",
        dart_file="lib/data/seed_france_lotteries.dart",
        dart_symbol="kFrEuroMillionsDraws",
        main_count=5,
        bonus_count=2,
    ),
]


def fetch_zip_content(url: str, retries: int = 3) -> bytes:
    """Download ZIP file from FDJ API."""
    for attempt in range(retries):
        try:
            response = requests.get(url, headers=HEADERS, timeout=30)
            response.raise_for_status()
            return response.content
        except Exception:
            if attempt == retries - 1:
                raise
            time.sleep(2 ** attempt)
    return b""


def parse_fdj_csv(zip_content: bytes, game: GameConfig) -> list[dict]:
    """Extract and parse CSV from FDJ ZIP archive."""
    rows: list[dict] = []

    with zipfile.ZipFile(io.BytesIO(zip_content)) as zf:
        # Get first CSV file in archive
        csv_files = [name for name in zf.namelist() if name.endswith('.csv')]
        if not csv_files:
            return rows

        csv_data = zf.read(csv_files[0]).decode('utf-8')
        reader = csv.DictReader(io.StringIO(csv_data), delimiter=';')

        for row in reader:
            try:
                # Parse date (format: DD/MM/YYYY)
                date_str = row.get('date_de_tirage', '')
                if not date_str:
                    continue
                day, month, year = date_str.split('/')
                draw_date = datetime(int(year), int(month), int(day)).date()

                # Extract numbers
                if game.lottery_id == 'fr_loto':
                    # France Loto: boule_1 to boule_5, numero_chance
                    main_numbers = [
                        int(row[f'boule_{i}'])
                        for i in range(1, game.main_count + 1)
                    ]
                    bonus_numbers = [int(row['numero_chance'])]

                elif game.lottery_id == 'fr_euromillions':
                    # EuroMillions: boule_1 to boule_5, etoile_1, etoile_2
                    main_numbers = [
                        int(row[f'boule_{i}'])
                        for i in range(1, game.main_count + 1)
                    ]
                    bonus_numbers = [
                        int(row['etoile_1']),
                        int(row['etoile_2'])
                    ]
                else:
                    continue

                rows.append({
                    "lottery_id": game.lottery_id,
                    "draw_date": draw_date.isoformat(),
                    "draw_number": row.get('annee_numero_de_tirage', ''),
                    "main_numbers": sorted(main_numbers),
                    "bonus_numbers": sorted(bonus_numbers),
                })

            except (KeyError, ValueError, AttributeError) as e:
                # Skip malformed rows
                continue

    return rows


def scrape_game(game: GameConfig, limit: int) -> list[dict]:
    """Download and parse all ZIP archives for a game."""
    all_rows: list[dict] = []
    seen: set[tuple[str, tuple[int, ...], tuple[int, ...]]] = set()

    for zip_url in game.zip_urls:
        print(f"Fetching {game.name} from {zip_url.split('/')[-1]}...")
        zip_content = fetch_zip_content(zip_url)
        rows = parse_fdj_csv(zip_content, game)

        for row in rows:
            key = (
                row["draw_date"],
                tuple(row["main_numbers"]),
                tuple(row["bonus_numbers"]),
            )
            if key in seen:
                continue
            seen.add(key)
            all_rows.append(row)

        print(f"  → {len(rows)} draws parsed, {len(all_rows)} total unique")

        # Check if we have enough
        if len(all_rows) >= limit:
            break

        time.sleep(0.5)

    # Sort by date descending (newest first)
    all_rows.sort(key=lambda item: item["draw_date"], reverse=True)
    return all_rows[:limit]


def csv_header(game: GameConfig) -> list[str]:
    """Generate CSV header row."""
    return (
        ["lottery_id", "draw_date", "draw_number"]
        + [f"main_{i}" for i in range(1, game.main_count + 1)]
        + [f"supp_{i}" for i in range(1, game.bonus_count + 1)]
    )


def write_csv(game: GameConfig, rows: list[dict]) -> None:
    """Write rows to CSV file."""
    path = Path(game.output_csv)
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(csv_header(game))
        for row in rows:
            writer.writerow([
                row["lottery_id"],
                row["draw_date"],
                row["draw_number"],
                *row["main_numbers"],
                *row["bonus_numbers"],
            ])


def write_dart_seed(rows_by_game: dict[str, list[dict]]) -> None:
    """Write combined Dart seed file for both France lotteries."""
    # Use the first game's dart_file path
    first_game = GAMES[0]
    path = Path(first_game.dart_file)
    updated_at = datetime.now().strftime("%Y-%m-%d")

    lines = [
        "import '../models/lottery_draw.dart';",
        "",
        f"const String kFranceLotteriesUpdatedAt = '{updated_at}';",
        "",
    ]

    # Write each game's draws
    for game in GAMES:
        rows = rows_by_game.get(game.lottery_id, [])
        lines.append(f"/// {len(rows)} real {game.name} draws from FDJ official API.")
        lines.append(f"final List<LotteryDraw> {game.dart_symbol} = [")

        for row in rows:
            draw_date = datetime.strptime(row["draw_date"], "%Y-%m-%d")
            bonus_expr = (
                f", bonusNumbers: [{', '.join(map(str, row['bonus_numbers']))}]"
                if row["bonus_numbers"]
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

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Download France lottery history from official FDJ API"
    )
    parser.add_argument("--limit", type=int, default=500,
                       help="Maximum draws per lottery (default: 500)")
    args = parser.parse_args()

    rows_by_game: dict[str, list[dict]] = {}

    for game in GAMES:
        print(f"\n{'='*60}")
        print(f"Processing {game.name}...")
        print(f"{'='*60}")

        rows = scrape_game(game, args.limit)

        if len(rows) < min(args.limit, 100):
            raise RuntimeError(f"{game.name}: only scraped {len(rows)} draws")

        rows_by_game[game.lottery_id] = rows
        write_csv(game, rows)
        print(f"✓ {game.name}: {len(rows)} draws → {game.output_csv}")

    # Write combined Dart seed file
    write_dart_seed(rows_by_game)
    print(f"\n✓ Combined Dart seed → {GAMES[0].dart_file}")
    print(f"\nTotal draws: {sum(len(r) for r in rows_by_game.values())}")


if __name__ == "__main__":
    main()
