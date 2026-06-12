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

MONTHS = {
    "January": 1,
    "February": 2,
    "March": 3,
    "April": 4,
    "May": 5,
    "June": 6,
    "July": 7,
    "August": 8,
    "September": 9,
    "October": 10,
    "November": 11,
    "December": 12,
}

DATE_RE = re.compile(
    r"\b(?:Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)\s+"
    r"(January|February|March|April|May|June|July|August|September|October|November|December)\s+"
    r"(\d{1,2})(?:st|nd|rd|th)?\s+(\d{4})\b"
)


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
        lottery_id="de_lotto_6aus49",
        name="German Lotto",
        archive_url="https://www.lotto.net/german-lotto/results/{year}",
        output_csv="docs/de_lotto_6aus49.csv",
        dart_file="lib/data/seed_de_lotto_6aus49.dart",
        dart_symbol="kDeLotto6aus49Draws",
        main_count=6,
        bonus_count=1,
        year_start=1955,
    ),
    GameConfig(
        lottery_id="de_eurojackpot",
        name="EuroJackpot",
        archive_url="https://www.lotto.net/eurojackpot/results/{year}",
        output_csv="docs/de_eurojackpot.csv",
        dart_file="lib/data/seed_de_eurojackpot.dart",
        dart_symbol="kDeEuroJackpotDraws",
        main_count=5,
        bonus_count=2,
        year_start=2012,
    ),
]


def fetch_html(url: str, retries: int = 3) -> str:
    for attempt in range(retries):
        try:
            response = requests.get(url, headers=HEADERS, timeout=20)
            response.raise_for_status()
            return response.text
        except Exception:
            if attempt == retries - 1:
                raise
            time.sleep(2 ** attempt)
    return ""


def parse_archive_page(html: str, game: GameConfig) -> list[dict]:
    text = BeautifulSoup(html, "html.parser").get_text("\n", strip=True)
    matches = list(DATE_RE.finditer(text))
    rows: list[dict] = []

    for index, match in enumerate(matches):
        month_name, day, year = match.groups()
        draw_date = datetime(int(year), MONTHS[month_name], int(day)).date()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        section = text[match.end() : end]
        numbers = [int(value) for value in re.findall(r"(?m)^\d{1,2}$", section)]
        needed = game.main_count + game.bonus_count
        if len(numbers) < needed:
            continue

        rows.append(
            {
                "lottery_id": game.lottery_id,
                "draw_date": draw_date.isoformat(),
                "draw_number": "",
                "main_numbers": numbers[: game.main_count],
                "bonus_numbers": numbers[game.main_count : needed],
            }
        )

    return rows


def scrape_game(game: GameConfig, limit: int) -> list[dict]:
    current_year = datetime.now().year
    rows: list[dict] = []
    seen: set[tuple[str, tuple[int, ...], tuple[int, ...]]] = set()

    for year in range(current_year, game.year_start - 1, -1):
        html = fetch_html(game.archive_url.format(year=year))
        for row in parse_archive_page(html, game):
            key = (
                row["draw_date"],
                tuple(row["main_numbers"]),
                tuple(row["bonus_numbers"]),
            )
            if key in seen:
                continue
            seen.add(key)
            rows.append(row)

        rows.sort(key=lambda item: item["draw_date"], reverse=True)
        print(f"{game.name}: {len(rows)} draws after {year}")
        if len(rows) >= limit:
            break
        time.sleep(0.2)

    return rows[:limit]


def csv_header(game: GameConfig) -> list[str]:
    return (
        ["lottery_id", "draw_date", "draw_number"]
        + [f"main_{index}" for index in range(1, game.main_count + 1)]
        + [f"supp_{index}" for index in range(1, game.bonus_count + 1)]
    )


def write_csv(game: GameConfig, rows: list[dict]) -> None:
    path = Path(game.output_csv)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(csv_header(game))
        for row in rows:
            writer.writerow(
                [
                    row["lottery_id"],
                    row["draw_date"],
                    row["draw_number"],
                    *row["main_numbers"],
                    *row["bonus_numbers"],
                ]
            )


def write_dart_seed(game: GameConfig, rows: list[dict]) -> None:
    path = Path(game.dart_file)
    updated_at = datetime.now().strftime("%Y-%m-%d")

    lines = [
        "import '../models/lottery_draw.dart';",
        "",
        f"const String {game.dart_symbol}UpdatedAt = '{updated_at}';",
        "",
        f"/// {len(rows)} real {game.name} draws from lotto.net archives.",
        f"final List<LotteryDraw> {game.dart_symbol} = [",
    ]

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

    lines.extend(["];", ""])

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=120)
    args = parser.parse_args()

    for game in GAMES:
        rows = scrape_game(game, args.limit)
        if len(rows) < min(args.limit, 100):
            raise RuntimeError(f"{game.name}: only scraped {len(rows)} draws")
        write_csv(game, rows)
        write_dart_seed(game, rows)
        print(f"✓ {game.name}: {len(rows)} draws → {game.output_csv} + {game.dart_file}")


if __name__ == "__main__":
    main()
