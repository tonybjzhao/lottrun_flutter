import requests
from bs4 import BeautifulSoup
import csv
from datetime import datetime
import time
import re

BASE_URL = "https://australia.national-lottery.com/powerball/past-results"

headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
}

rows = []
processed_urls = set()

def parse_date_from_text(link_text):
    """Extract date from link text like 'Draw 15609 April, 2026'"""
    match = re.search(r'Draw\s+\d+(\d+\s+\w+,\s+\d+)', link_text)
    if match:
        date_part = match.group(1)
        dt = datetime.strptime(date_part, "%d %B, %Y")
        return dt.strftime("%Y-%m-%d")
    return None

def scrape_result_page(url):
    """Scrape a single result page and return (date_str, numbers, powerball) or None"""
    if url in processed_urls:
        return None
    processed_urls.add(url)
    
    try:
        r = requests.get(url, headers=headers, timeout=10)
        soup = BeautifulSoup(r.text, "html.parser")
        
        # Extract numbers from balls
        balls = soup.select("ul.balls li.ball")
        if len(balls) >= 8:
            numbers = [b.text.strip() for b in balls[:7]]
            powerball = balls[7].text.strip()
            
            # Get date from page title or URL
            title = soup.title.text if soup.title else ""
            date_match = re.search(r'(\d{1,2})\s+(\w+)\s+(\d{4})', title)
            if date_match:
                day, month, year = date_match.groups()
                dt = datetime.strptime(f"{day} {month} {year}", "%d %B %Y")
                date_str = dt.strftime("%Y-%m-%d")
            else:
                # Extract from URL: /powerball/results/DD-MM-YYYY
                url_match = re.search(r'/results/(\d{2}-\d{2}-\d{4})', url)
                if url_match:
                    dt = datetime.strptime(url_match.group(1), "%d-%m-%Y")
                    date_str = dt.strftime("%Y-%m-%d")
                else:
                    return None
            
            return (date_str, numbers, powerball)
    except Exception as e:
        print(f"  Error: {e}")
    return None

# Step 1: Get links from main past-results page
print("Fetching main past results page...")
r = requests.get(BASE_URL, headers=headers, timeout=10)
soup = BeautifulSoup(r.text, "html.parser")
draw_links = soup.select('a[href^="/powerball/results/"]')
print(f"Found {len(draw_links)} recent draw links")

for link in draw_links:
    href = link['href']
    url = f"https://australia.national-lottery.com{href}"
    result = scrape_result_page(url)
    if result:
        date_str, numbers, powerball = result
        rows.append([date_str] + numbers + [powerball])
        print(f"  {date_str}: {numbers} PB: {powerball}")
    time.sleep(0.3)

# Step 2: Get archive pages for older data
archive_years = [2025, 2024, 2023, 2022, 2021]
for year in archive_years:
    print(f"\nFetching archive for {year}...")
    archive_url = f"https://australia.national-lottery.com/powerball/results-archive-{year}"
    
    try:
        r = requests.get(archive_url, headers=headers, timeout=10)
        if r.status_code != 200:
            print(f"  Status {r.status_code}, skipping")
            continue
            
        soup = BeautifulSoup(r.text, "html.parser")
        year_links = soup.select('a[href^="/powerball/results/"]')
        print(f"  Found {len(year_links)} draws")
        
        for link in year_links:
            href = link['href']
            url = f"https://australia.national-lottery.com{href}"
            result = scrape_result_page(url)
            if result:
                date_str, numbers, powerball = result
                rows.append([date_str] + numbers + [powerball])
                print(f"  {date_str}: {numbers} PB: {powerball}")
            time.sleep(0.3)
            
    except Exception as e:
        print(f"  Error fetching archive: {e}")

# Sort by date (newest first)
rows.sort(reverse=True)

# Save CSV
with open("powerball_5y.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["date", "n1", "n2", "n3", "n4", "n5", "n6", "n7", "powerball"])
    writer.writerows(rows)

print(f"\n✅ CSV generated: powerball_5y.csv ({len(rows)} rows)")
