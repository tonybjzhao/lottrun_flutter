from __future__ import annotations

import argparse
import csv
import re
import time
from dataclasses import dataclass
from datetime import date, timedelta
from pathlib import Path
from typing import Iterable, List, Optional

from playwright.sync_api import TimeoutError as PlaywrightTimeoutError
from playwright.sync_api import sync_playwright


@dataclass(frozen=True)
class GameConfig:
    name: str
    url: str
    # Stable per-draw result page used for CI-friendly incremental fetches.
    result_url_template: str
    weekday: int  # Monday=0 ... Sunday=6
    main_count: int
    supp_count: int
    output_csv: str
    min_ball: int
    max_ball: int


OZ_LOTTO = GameConfig(
    name="Oz Lotto",
    url="https://www.thelott.com/oz-lotto/results",
    result_url_template="https://australia.national-lottery.com/oz-lotto/results/{date_slug}",
    weekday=1,  # Tuesday
    main_count=7,
    supp_count=2,
    output_csv="docs/oz_lotto.csv",
    min_ball=1,
    max_ball=47,
)

SATURDAY_LOTTO = GameConfig(
    name="Saturday Lotto",
    url="https://www.thelott.com/saturday-lotto/results",
    result_url_template="https://australia.national-lottery.com/saturday-lotto/results/{date_slug}",
    weekday=5,  # Saturday
    main_count=6,
    supp_count=2,
    output_csv="docs/saturday_lotto.csv",
    min_ball=1,
    max_ball=45,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Scrape Australia Oz Lotto and Saturday Lotto results into GitHub Pages CSVs."
    )
    parser.add_argument(
        "--years",
        type=int,
        default=5,
        help="How many years of draws to target. Default: 5",
    )
    parser.add_argument(
        "--weeks",
        type=int,
        default=None,
        help="Override years and only target the last N weeks. Useful for selector validation.",
    )
    parser.add_argument(
        "--game",
        choices=("oz", "saturday", "both"),
        default="both",
        help="Which game to scrape. Default: both",
    )
    parser.add_argument(
        "--headed",
        action="store_true",
        help="Run Chromium headed so you can inspect selectors live.",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=0.6,
        help="Delay between draws in seconds. Default: 0.6",
    )
    return parser.parse_args()


def iter_weekday_dates(start_date: date, end_date: date, weekday: int) -> Iterable[date]:
    d = start_date
    while d.weekday() != weekday:
        d += timedelta(days=1)
    while d <= end_date:
        yield d
        d += timedelta(days=7)


def date_display_formats(d: date) -> List[str]:
    day = str(d.day)
    month = str(d.month)
    month_short = d.strftime("%b")
    month_long = d.strftime("%B")
    return [
        d.strftime("%d/%m/%Y"),
        f"{day}/{month}/{d.year}",
        f"{day} {month_short} {d.year}",
        d.strftime("%d %b %Y"),
        f"{day} {month_long} {d.year}",
        d.strftime("%d %B %Y"),
        d.isoformat(),
    ]


def safe_click(page, selectors: List[str]) -> bool:
    for selector in selectors:
        try:
            page.locator(selector).first.click(timeout=2000)
            return True
        except Exception:
            continue
    return False


def accept_cookies_if_present(page) -> None:
    safe_click(
        page,
        [
            "button:has-text('Accept')",
            "button:has-text('Accept All')",
            "button:has-text('I Accept')",
            "button:has-text('Got it')",
            "button:has-text('OK')",
            "#onetrust-accept-btn-handler",
        ],
    )


def fill_search_date(page, d: date) -> bool:
    text_candidates = [
        d.isoformat(),
        d.strftime("%d/%m/%Y"),
        f"{d.day}/{d.month}/{d.year}",
        d.strftime("%d %b %Y"),
        f"{d.day} {d.strftime('%b')} {d.year}",
        d.strftime("%d %B %Y"),
        f"{d.day} {d.strftime('%B')} {d.year}",
    ]

    selectors = [
        "input[type='date']",
        "input[placeholder*='date' i]",
        "input[aria-label*='date' i]",
        "input[name*='date' i]",
        "input[id*='date' i]",
        "input",
    ]

    for selector in selectors:
        try:
            loc = page.locator(selector)
            count = min(loc.count(), 10)
            for i in range(count):
                item = loc.nth(i)
                try:
                    item.wait_for(timeout=1000)
                    item.click(timeout=1000)
                    item.fill("")
                    for candidate in text_candidates:
                        try:
                            item.fill(candidate)
                            return True
                        except Exception:
                            continue
                except Exception:
                    continue
        except Exception:
            continue
    return False


def click_search(page) -> None:
    safe_click(
        page,
        [
            "button:has-text('Search')",
            "button:has-text('Find')",
            "button:has-text('Go')",
            "button[type='submit']",
            "input[type='submit']",
        ],
    )


def extract_all_numbers(text: str) -> List[int]:
    return [int(x) for x in re.findall(r"\b\d{1,2}\b", text)]


def parse_draw_block(full_text: str, target_date: date, game: GameConfig) -> Optional[dict]:
    lines = [line.strip() for line in full_text.splitlines() if line.strip()]
    if not lines:
        return None

    target_matches = set(date_display_formats(target_date))
    idx = None
    for i, line in enumerate(lines):
        low = line.lower()
        if any(fmt.lower() in low for fmt in target_matches):
            idx = i
            break

    if idx is None:
        month_short = target_date.strftime("%b").lower()
        year_text = str(target_date.year)
        day_text = str(target_date.day)
        for i, line in enumerate(lines):
            low = line.lower()
            if month_short in low and year_text in low and day_text in low:
                idx = i
                break

    if idx is None:
        return None

    block = "\n".join(lines[max(0, idx - 3) : min(len(lines), idx + 12)])

    draw_number = None
    match = re.search(r"\b(?:draw|draw number)\s*#?\s*(\d{3,6})\b", block, re.IGNORECASE)
    if match:
        draw_number = int(match.group(1))

    main_numbers: List[int] = []
    supp_numbers: List[int] = []

    main_patterns = [
        r"winning numbers?\s*[:\-]?\s*([0-9,\s]+)",
        r"results?\s*[:\-]?\s*([0-9,\s]+)",
    ]
    supp_patterns = [
        r"(?:supplementary|supplementaries|bonus|powerball)\s*(?:numbers?)?\s*[:\-]?\s*([0-9,\s]+)",
    ]

    for pattern in main_patterns:
        match = re.search(pattern, block, re.IGNORECASE)
        if match:
            main_numbers = [int(x) for x in re.findall(r"\b\d{1,2}\b", match.group(1))]
            if len(main_numbers) >= game.main_count:
                main_numbers = main_numbers[: game.main_count]
                break

    for pattern in supp_patterns:
        match = re.search(pattern, block, re.IGNORECASE)
        if match:
            supp_numbers = [int(x) for x in re.findall(r"\b\d{1,2}\b", match.group(1))]
            if len(supp_numbers) >= game.supp_count:
                supp_numbers = supp_numbers[: game.supp_count]
                break

    if len(main_numbers) < game.main_count:
        filtered = [
            n
            for n in extract_all_numbers(block)
            if game.min_ball <= n <= game.max_ball
        ]

        deduped: List[int] = []
        for n in filtered:
            if n not in deduped:
                deduped.append(n)

        if len(deduped) >= game.main_count + game.supp_count:
            main_numbers = deduped[: game.main_count]
            supp_numbers = deduped[game.main_count : game.main_count + game.supp_count]

    if len(main_numbers) < game.main_count:
        return None

    supp_numbers = supp_numbers[: game.supp_count]

    return {
        "game": game.name,
        "draw_date": target_date.isoformat(),
        "draw_number": draw_number,
        "main_numbers": main_numbers,
        "supp_numbers": supp_numbers,
        "raw_block": block,
    }


def search_one_draw(page, game: GameConfig, d: date) -> Optional[dict]:
    date_slug = d.strftime("%d-%m-%Y")
    result_url = game.result_url_template.format(date_slug=date_slug)
    page.goto(result_url, wait_until="domcontentloaded", timeout=60000)
    page.wait_for_timeout(800)

    ball_values = [
        value.strip()
        for value in page.locator("ul.balls li.ball").all_inner_texts()
        if value.strip().isdigit()
    ]
    required = game.main_count + game.supp_count
    if len(ball_values) < required:
        return None

    title = page.title()
    match = re.search(r"Draw\s+(\d+)", title, re.IGNORECASE)
    draw_number = int(match.group(1)) if match else None
    numbers = [int(value) for value in ball_values[:required]]

    return {
        "game": game.name,
        "draw_date": d.isoformat(),
        "draw_number": draw_number,
        "main_numbers": numbers[: game.main_count],
        "supp_numbers": numbers[game.main_count : required],
    }


def read_existing_rows(game: GameConfig) -> List[dict]:
    output_path = Path(game.output_csv)
    if not output_path.exists():
        return []

    rows: List[dict] = []
    with output_path.open(newline="", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        for item in reader:
            rows.append(
                {
                    "game": item["game"],
                    "draw_date": item["draw_date"],
                    "draw_number": int(item["draw_number"]) if item["draw_number"] else None,
                    "main_numbers": [
                        int(item[f"main_{i + 1}"])
                        for i in range(game.main_count)
                        if item.get(f"main_{i + 1}")
                    ],
                    "supp_numbers": [
                        int(item[f"supp_{i + 1}"])
                        for i in range(game.supp_count)
                        if item.get(f"supp_{i + 1}")
                    ],
                }
            )
    return rows


def save_csv(rows: List[dict], game: GameConfig) -> None:
    main_cols = [f"main_{i + 1}" for i in range(game.main_count)]
    supp_cols = [f"supp_{i + 1}" for i in range(game.supp_count)]

    output_path = Path(game.output_csv)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with output_path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["game", "draw_date", "draw_number", *main_cols, *supp_cols])

        for row in rows:
            main_vals = row["main_numbers"] + [""] * (game.main_count - len(row["main_numbers"]))
            supp_vals = row["supp_numbers"] + [""] * (game.supp_count - len(row["supp_numbers"]))
            writer.writerow(
                [
                    row["game"],
                    row["draw_date"],
                    row["draw_number"] or "",
                    *main_vals,
                    *supp_vals,
                ]
            )


def target_dates_for_game(game: GameConfig, *, years: int, weeks: Optional[int]) -> List[date]:
    end_date = date.today()
    if weeks is not None:
        start_date = end_date - timedelta(weeks=weeks, days=7)
    else:
        start_date = end_date - timedelta(days=years * 365 + 5)
    return list(iter_weekday_dates(start_date, end_date, game.weekday))


def scrape_game(game: GameConfig, *, years: int, weeks: Optional[int], headed: bool, delay: float) -> List[dict]:
    existing_rows = read_existing_rows(game)
    target_dates = target_dates_for_game(game, years=years, weeks=weeks)

    if existing_rows:
        latest_existing = max(date.fromisoformat(row["draw_date"]) for row in existing_rows)
        target_dates = [draw_date for draw_date in target_dates if draw_date > latest_existing]

    print(f"\n=== {game.name} ===")
    print(f"Existing rows: {len(existing_rows)}")
    print(f"Missing draw dates: {len(target_dates)}")

    if not target_dates:
        print(f"{game.name} is already up to date.")
        return sorted(existing_rows, key=lambda row: row["draw_date"])

    rows: List[dict] = list(existing_rows)

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=not headed)
        context = browser.new_context(
            locale="en-AU",
            user_agent=(
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/124.0.0.0 Safari/537.36"
            ),
            viewport={"width": 1440, "height": 2000},
        )
        page = context.new_page()
        for index, draw_date in enumerate(target_dates, start=1):
            print(f"[{index}/{len(target_dates)}] {game.name} {draw_date} ... ", end="", flush=True)
            try:
                row = search_one_draw(page, game, draw_date)
                if row:
                    rows.append(row)
                    print("OK")
                else:
                    print("MISS")
            except PlaywrightTimeoutError:
                print("TIMEOUT")
            except Exception as exc:
                print(f"ERROR: {exc}")
            time.sleep(delay)

        browser.close()

    deduped = {row["draw_date"]: row for row in rows}
    final_rows = [deduped[key] for key in sorted(deduped.keys())]
    save_csv(final_rows, game)
    print(f"Saved {len(final_rows)} rows to {game.output_csv}")
    return final_rows


def selected_games(game_arg: str) -> List[GameConfig]:
    if game_arg == "oz":
        return [OZ_LOTTO]
    if game_arg == "saturday":
        return [SATURDAY_LOTTO]
    return [OZ_LOTTO, SATURDAY_LOTTO]


def main() -> None:
    args = parse_args()
    csv_paths: List[Path] = []

    for game in selected_games(args.game):
        rows = scrape_game(
            game,
            years=args.years,
            weeks=args.weeks,
            headed=args.headed,
            delay=args.delay,
        )
        csv_paths.append(Path(game.output_csv))
        print(f"{game.name} rows: {len(rows)} -> {game.output_csv}")

    print("\nDone.")
    print("Generated:")
    for path in csv_paths:
        print(f"- {path}")


if __name__ == "__main__":
    main()
