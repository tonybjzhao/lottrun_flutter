#!/bin/bash

echo "================================================================================"
echo "                      WORKFLOW COMPLETION VERIFICATION"
echo "================================================================================"
echo ""

cd /Users/tony/lottfun_flutter

# Fetch latest changes
echo "Fetching latest changes from GitHub..."
git fetch origin
echo ""

# Check for new github-actions commit
echo "=== 1. WORKFLOW STATUS ==="
echo ""
latest_bot_commit=$(git log origin/main --author='github-actions' --format='%H' --max-count=1)
latest_bot_commit_short=$(git log origin/main --author='github-actions' --format='%h' --max-count=1)
latest_bot_date=$(git log origin/main --author='github-actions' --format='%ci' --max-count=1)

echo "Latest github-actions[bot] commit:"
echo "  Hash: $latest_bot_commit_short"
echo "  Date: $latest_bot_date"
git log origin/main --author='github-actions' --max-count=1 --format="  Message: %s"
echo ""

# Pull if needed
if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
    echo "Pulling latest changes..."
    git pull origin main
    echo ""
fi

# Show updated files
echo "=== 2. UPDATED FILES ==="
echo ""
git log --author='github-actions' --max-count=1 --name-only --format="" | grep "\.csv\|\.dart"
echo ""

# Show latest draw dates from each CSV
echo "=== 3. LATEST DRAW DATES ==="
echo ""

python3 << 'PYEOF'
import csv
from pathlib import Path

games = [
    ("AU Powerball", "docs/powerball.csv"),
    ("AU Oz Lotto", "docs/oz_lotto.csv"),
    ("AU Saturday Lotto", "docs/saturday_lotto.csv"),
    ("US Powerball", "docs/us_powerball.csv"),
    ("US Mega Millions", "docs/us_megamillions.csv"),
    ("UK Lotto", "docs/uk_lotto.csv"),
    ("UK EuroMillions", "docs/uk_euromillions.csv"),
    ("CA Lotto Max", "docs/ca_lotto_max.csv"),
    ("CA Lotto 6/49", "docs/ca_lotto_649.csv"),
    ("DE Lotto 6aus49", "docs/de_lotto_6aus49.csv"),
    ("DE EuroJackpot", "docs/de_eurojackpot.csv"),
]

for name, path in games:
    if Path(path).exists():
        with open(path) as f:
            rows = list(csv.DictReader(f))
            first_date = rows[0]['draw_date']
            last_date = rows[-1]['draw_date']
            latest = max(first_date, last_date)
            count = len(rows)
            print(f"{name:25} | {latest:12} | {count:5} records")
PYEOF

echo ""

# Show github-actions bot commit
echo "=== 4. GITHUB-ACTIONS BOT COMMIT ==="
echo ""
git log --author='github-actions' --max-count=1 --stat
echo ""

# Generate final verification table
echo "================================================================================"
echo "                          FINAL VERIFICATION TABLE"
echo "================================================================================"
echo ""

python3 << 'PYEOF'
import csv
import subprocess
from pathlib import Path

games = {
    "AU Powerball": "docs/powerball.csv",
    "AU Oz Lotto": "docs/oz_lotto.csv",
    "AU Saturday Lotto": "docs/saturday_lotto.csv",
    "US Powerball": "docs/us_powerball.csv",
    "US Mega Millions": "docs/us_megamillions.csv",
    "UK Lotto": "docs/uk_lotto.csv",
    "UK EuroMillions": "docs/uk_euromillions.csv",
    "CA Lotto Max": "docs/ca_lotto_max.csv",
    "CA Lotto 6/49": "docs/ca_lotto_649.csv",
    "DE Lotto 6aus49": "docs/de_lotto_6aus49.csv",
    "DE EuroJackpot": "docs/de_eurojackpot.csv",
}

print(f"{'Game':<25} | {'Latest Draw':<15} | {'Auto Update Proven'}")
print("-" * 80)

# Get files changed in last bot commit
result = subprocess.run(
    ['git', 'log', '--author=github-actions', '--max-count=1', '--name-only', '--format='],
    capture_output=True,
    text=True
)
files_changed = set(result.stdout.strip().split('\n'))

for game, csv_path in games.items():
    # Read CSV
    with open(csv_path) as f:
        rows = list(csv.DictReader(f))
        first_date = rows[0]['draw_date']
        last_date = rows[-1]['draw_date']
        latest = max(first_date, last_date)

    # Check if file was in last bot commit
    if csv_path in files_changed or csv_path.replace('docs/', 'lib/data/seed_').replace('.csv', '.dart') in files_changed:
        status = "✅ PROVEN (updated by workflow)"
    else:
        # Check total bot commits
        bot_result = subprocess.run(
            ['git', 'log', '--author=github-actions', '--oneline', '--', csv_path],
            capture_output=True,
            text=True
        )
        bot_commits = len(bot_result.stdout.strip().split('\n')) if bot_result.stdout.strip() else 0

        if bot_commits > 0:
            status = f"✅ PROVEN ({bot_commits} previous commits)"
        else:
            status = "⚠️  NOT UPDATED (no bot commits)"

    print(f"{game:<25} | {latest:<15} | {status}")

print("=" * 80)
PYEOF

echo ""
echo "Verification complete!"
echo "================================================================================"
