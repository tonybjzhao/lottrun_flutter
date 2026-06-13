# Shared Dataset Implementation Plan

**Date:** 2026-06-13  
**Goal:** Eliminate duplicate EuroMillions/EuroJackpot datasets while keeping country-based navigation

---

## Design Principles

✅ **Keep country-based UI** - Users still select "France · EuroMillions", "UK · EuroMillions"  
✅ **Share backend data** - Single dataset reused across countries  
✅ **Zero user impact** - Transparent implementation detail  
✅ **Easy expansion** - Adding Spain requires 10-line config only  

❌ **No "Euro" country** - Bad UX, confusing grouping  
❌ **No duplicate datasets** - Waste storage and create sync issues  

---

## Architecture

### Data Flow

```
User selects: "France · EuroMillions"
       ↓
Lottery ID: 'fr_euromillions'
       ↓
Lottery.sharedDatasetId: 'euromillions'
       ↓
LotteryService._getSharedDraws('euromillions')
       ↓
Returns: kSharedEuroMillionsDraws (500 draws)
```

### Directory Structure

```
lib/data/
├── seed_lotteries.dart              # All lottery configs (UI list)
├── seed_shared_euromillions.dart    # ← NEW: 500 EuroMillions draws
├── seed_shared_eurojackpot.dart     # ← NEW: 500 EuroJackpot draws
├── seed_us_lotteries.dart           # US-specific: Powerball, Mega Millions
├── seed_au_lotteries.dart           # AU-specific: Powerball, Oz Lotto, Saturday
├── seed_uk_lotteries.dart           # UK-specific: UK Lotto ONLY (remove EuroMillions)
├── seed_france_lotteries.dart       # FR-specific: France Loto ONLY (remove EuroMillions)
├── seed_germany_lotteries.dart      # DE-specific: Lotto 6aus49 ONLY (remove EuroJackpot)
├── seed_canada_lotteries.dart       # CA-specific: Lotto Max, Lotto 6/49
└── seed_jp_loto*.dart               # JP-specific: Loto 6, Loto 7

docs/
├── euromillions.csv                 # ← NEW: Single source (500 draws)
├── eurojackpot.csv                  # ← NEW: Single source (500 draws)
├── uk_lotto.csv                     # Country-specific only
├── fr_loto.csv
└── de_lotto_6aus49.csv
```

---

## Implementation Steps

### Step 1: Add `sharedDatasetId` to Lottery Model

**File:** `lib/models/lottery.dart`

```dart
class Lottery {
  final String id;
  final String countryCode;
  final String countryName;
  final String name;
  final String? sharedDatasetId;  // ← NEW: Optional field
  
  // ... other fields
  
  const Lottery({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.name,
    this.sharedDatasetId,  // ← Add to constructor
    // ... other params
  });
}
```

**Impact:** Non-breaking change (optional field, defaults to null)

---

### Step 2: Create Shared Dataset Files

#### File: `lib/data/seed_shared_euromillions.dart`

```dart
import '../models/lottery_draw.dart';

/// Shared EuroMillions draw history used by:
/// - UK EuroMillions (id: 'uk_euromillions')
/// - France EuroMillions (id: 'fr_euromillions')
/// - Future: Spain, Ireland, Belgium, etc.
///
/// Source: Official FDJ API (France)
/// Updated daily via GitHub Actions
final kSharedEuroMillionsDraws = <LotteryDraw>[
  // 500 most recent draws
  LotteryDraw(
    lotteryId: 'euromillions',  // ← Generic ID for shared dataset
    drawDate: DateTime(2026, 6, 12),
    mainNumbers: [4, 7, 14, 22, 23],
    bonusNumbers: [1, 7],
  ),
  // ... 499 more draws
];
```

#### File: `lib/data/seed_shared_eurojackpot.dart`

```dart
import '../models/lottery_draw.dart';

/// Shared EuroJackpot draw history used by:
/// - Germany EuroJackpot (id: 'de_eurojackpot')
/// - Future: Finland, Italy, Sweden, Spain, etc.
///
/// Source: Official EuroJackpot API
/// Updated daily via GitHub Actions
final kSharedEuroJackpotDraws = <LotteryDraw>[
  // 500 most recent draws
  LotteryDraw(
    lotteryId: 'eurojackpot',  // ← Generic ID for shared dataset
    drawDate: DateTime(2026, 6, 13),
    mainNumbers: [5, 12, 18, 29, 44],
    bonusNumbers: [3, 9],
  ),
  // ... 499 more draws
];
```

---

### Step 3: Update Lottery Configurations

**File:** `lib/data/seed_lotteries.dart`

```dart
final kSeedLotteries = [
  // ────────────────────────────────────────────────────────────
  // UK Lotteries
  // ────────────────────────────────────────────────────────────
  
  Lottery(
    id: 'uk_lotto',
    countryCode: 'GB',
    countryName: _l10n.countryUnitedKingdom,
    name: _l10n.lotteryUkLotto,
    // NO sharedDatasetId - uses country-specific data
    mainCount: 6,
    mainMin: 1,
    mainMax: 59,
    bonusCount: 1,
    bonusMin: 1,
    bonusMax: 59,
    hasSeparateBonusPool: false,
    bonusIsSupplementary: true,
  ),
  
  Lottery(
    id: 'uk_euromillions',
    sharedDatasetId: 'euromillions',  // ← NEW: Points to shared dataset
    countryCode: 'GB',
    countryName: _l10n.countryUnitedKingdom,
    name: _l10n.lotteryEuroMillions,
    mainCount: 5,
    mainMin: 1,
    mainMax: 50,
    bonusCount: 2,
    bonusMin: 1,
    bonusMax: 12,
    hasSeparateBonusPool: true,
    bonusLabel: _l10n.bonusLuckyStars,
  ),
  
  // ────────────────────────────────────────────────────────────
  // France Lotteries
  // ────────────────────────────────────────────────────────────
  
  Lottery(
    id: 'fr_loto',
    countryCode: 'FR',
    countryName: _l10n.countryFrance,
    name: _l10n.lotteryFranceLoto,
    // NO sharedDatasetId - uses country-specific data
    mainCount: 5,
    mainMin: 1,
    mainMax: 49,
    bonusCount: 1,
    bonusMin: 1,
    bonusMax: 10,
    hasSeparateBonusPool: true,
    bonusLabel: _l10n.bonusChanceNumber,
  ),
  
  Lottery(
    id: 'fr_euromillions',
    sharedDatasetId: 'euromillions',  // ← NEW: Same dataset as UK
    countryCode: 'FR',
    countryName: _l10n.countryFrance,
    name: _l10n.lotteryFranceEuroMillions,
    mainCount: 5,
    mainMin: 1,
    mainMax: 50,
    bonusCount: 2,
    bonusMin: 1,
    bonusMax: 12,
    hasSeparateBonusPool: true,
    bonusLabel: _l10n.bonusLuckyStars,
  ),
  
  // ────────────────────────────────────────────────────────────
  // Germany Lotteries
  // ────────────────────────────────────────────────────────────
  
  Lottery(
    id: 'de_lotto_6aus49',
    countryCode: 'DE',
    countryName: _l10n.countryGermany,
    name: _l10n.lotteryLotto6aus49,
    // NO sharedDatasetId - uses country-specific data
    mainCount: 6,
    mainMin: 1,
    mainMax: 49,
    bonusCount: 1,
    bonusMin: 0,
    bonusMax: 9,
    hasSeparateBonusPool: true,
    bonusLabel: _l10n.bonusSuperzahl,
  ),
  
  Lottery(
    id: 'de_eurojackpot',
    sharedDatasetId: 'eurojackpot',  // ← NEW: Points to shared dataset
    countryCode: 'DE',
    countryName: _l10n.countryGermany,
    name: _l10n.lotteryEuroJackpot,
    mainCount: 5,
    mainMin: 1,
    mainMax: 50,
    bonusCount: 2,
    bonusMin: 1,
    bonusMax: 12,
    hasSeparateBonusPool: true,
    bonusLabel: _l10n.bonusEuroNumbers,
  ),
];
```

---

### Step 4: Update Lottery Service

**File:** `lib/services/lottery_service.dart`

```dart
import '../data/seed_shared_euromillions.dart';
import '../data/seed_shared_eurojackpot.dart';
// ... other imports

class LotteryService {
  static final instance = LotteryService._();
  LotteryService._();

  /// Returns all historical draws for the given lottery.
  /// 
  /// For multi-country lotteries (EuroMillions, EuroJackpot),
  /// returns the shared dataset regardless of country variant.
  List<LotteryDraw> getDraws(String lotteryId) {
    // NEW: Check if lottery uses shared dataset
    final lottery = kSeedLotteries.firstWhere(
      (l) => l.id == lotteryId,
      orElse: () => throw ArgumentError('Unknown lottery: $lotteryId'),
    );
    
    if (lottery.sharedDatasetId != null) {
      return _getSharedDraws(lottery.sharedDatasetId!);
    }
    
    // Fallback to country-specific datasets
    switch (lotteryId) {
      case 'au_powerball':
        return kAuPowerballDraws;
      case 'au_ozlotto':
        return kAuOzLottoDraws;
      case 'au_saturday':
        return kSaturdayLottoDraws;
      case 'us_powerball':
        return kUsPowerballDraws;
      case 'us_megamillions':
        return kUsMegaMillionsDraws;
      case 'uk_lotto':
        return kUkLottoDraws;
      case 'ca_lotto_max':
        return kCaLottoMaxDraws;
      case 'ca_lotto_649':
        return kCaLotto649Draws;
      case 'de_lotto_6aus49':
        return kDeLotto6aus49Draws;
      case 'jp_loto6':
        return kJpLoto6Draws;
      case 'jp_loto7':
        return kJpLoto7Draws;
      case 'fr_loto':
        return kFrLotoDraws;
      default:
        return [];
    }
  }
  
  /// Returns shared dataset for multi-country lotteries
  List<LotteryDraw> _getSharedDraws(String datasetId) {
    switch (datasetId) {
      case 'euromillions':
        return kSharedEuroMillionsDraws;
      case 'eurojackpot':
        return kSharedEuroJackpotDraws;
      default:
        throw ArgumentError('Unknown shared dataset: $datasetId');
    }
  }

  /// Returns the most recent [limit] draws for frequency analysis.
  List<LotteryDraw> getRecentDraws(String lotteryId, {int limit = 50}) {
    final draws = getDraws(lotteryId);
    return draws.take(limit).toList();
  }
}
```

---

### Step 5: Update CSV Service

**File:** `lib/services/lottery_history_csv_service.dart`

```dart
class LotteryHistoryCsvService {
  static const _baseUrl = 'https://tonybjzhao.github.io/lottrun_flutter';
  
  static const _csvUrls = <String, String>{
    // Country-specific lotteries
    'au_powerball': '$_baseUrl/au_powerball.csv',
    'au_ozlotto': '$_baseUrl/au_ozlotto.csv',
    'au_saturday': '$_baseUrl/au_saturday.csv',
    'us_powerball': '$_baseUrl/us_powerball.csv',
    'us_megamillions': '$_baseUrl/us_megamillions.csv',
    'uk_lotto': '$_baseUrl/uk_lotto.csv',
    'ca_lotto_max': '$_baseUrl/ca_lotto_max.csv',
    'ca_lotto_649': '$_baseUrl/ca_lotto_649.csv',
    'de_lotto_6aus49': '$_baseUrl/de_lotto_6aus49.csv',
    'jp_loto6': '$_baseUrl/jp_loto6.csv',
    'jp_loto7': '$_baseUrl/jp_loto7.csv',
    'fr_loto': '$_baseUrl/fr_loto.csv',
    
    // Shared multi-country datasets
    'euromillions': '$_baseUrl/euromillions.csv',      // ← NEW
    'eurojackpot': '$_baseUrl/eurojackpot.csv',        // ← NEW
  };
  
  String? getCsvUrl(String lotteryId) {
    // NEW: Check if lottery uses shared dataset
    final lottery = kSeedLotteries.firstWhere(
      (l) => l.id == lotteryId,
      orElse: () => null,
    );
    
    if (lottery?.sharedDatasetId != null) {
      return _csvUrls[lottery!.sharedDatasetId];  // Use shared URL
    }
    
    return _csvUrls[lotteryId];  // Use lottery-specific URL
  }
}
```

---

### Step 6: Create Shared Dataset Update Script

**File:** `tools/sync_shared_lottery_history.py`

```python
#!/usr/bin/env python3
"""
Sync shared multi-country lottery history.

This script downloads draw history for lotteries that are shared across
multiple countries (EuroMillions, EuroJackpot) and generates:
1. CSV files (docs/euromillions.csv, docs/eurojackpot.csv)
2. Dart seed files (lib/data/seed_shared_euromillions.dart, etc.)

Usage:
    python tools/sync_shared_lottery_history.py --limit 500
"""

import argparse
import requests
from bs4 import BeautifulSoup
from datetime import datetime

def download_euromillions(limit=500):
    """
    Download EuroMillions history from official FDJ API.
    
    Source: https://www.fdj.fr (France official lottery)
    Returns: List of draws sorted by date descending
    """
    print(f"Downloading EuroMillions history (limit: {limit})...")
    
    # Download from official FDJ API
    url = "https://www.fdj.fr/generated/euromillions/euromillions.zip"
    response = requests.get(url)
    
    # Parse ZIP, extract CSV, parse draws
    # ... (similar to sync_fr_lottery_history.py)
    
    draws = []  # Parse draws from FDJ data
    
    # Generate CSV
    with open('docs/euromillions.csv', 'w') as f:
        f.write('lottery_id,draw_date,draw_number,main_1,main_2,main_3,main_4,main_5,supp_1,supp_2\n')
        for draw in draws[:limit]:
            f.write(f"euromillions,{draw['date']},{draw['number']},...")
    
    # Generate Dart seed file
    generate_dart_seed('euromillions', draws[:limit])
    
    print(f"✓ EuroMillions: {len(draws[:limit])} draws")

def download_eurojackpot(limit=500):
    """
    Download EuroJackpot history from official API.
    
    Source: https://www.eurojackpot.org (Official EuroJackpot)
    Returns: List of draws sorted by date descending
    """
    print(f"Downloading EuroJackpot history (limit: {limit})...")
    
    # Download from official EuroJackpot API
    # ... implementation
    
    draws = []  # Parse draws
    
    # Generate CSV and Dart seed
    with open('docs/eurojackpot.csv', 'w') as f:
        # ... write CSV
    
    generate_dart_seed('eurojackpot', draws[:limit])
    
    print(f"✓ EuroJackpot: {len(draws[:limit])} draws")

def generate_dart_seed(lottery_id, draws):
    """Generate Dart seed file for shared dataset."""
    
    filename = f"lib/data/seed_shared_{lottery_id}.dart"
    
    with open(filename, 'w') as f:
        f.write("import '../models/lottery_draw.dart';\n\n")
        f.write(f"/// Shared {lottery_id.title()} draw history\n")
        f.write(f"final kShared{lottery_id.title()}Draws = <LotteryDraw>[\n")
        
        for draw in draws:
            f.write(f"  LotteryDraw(\n")
            f.write(f"    lotteryId: '{lottery_id}',\n")
            f.write(f"    drawDate: DateTime({draw['year']}, {draw['month']}, {draw['day']}),\n")
            f.write(f"    mainNumbers: {draw['main']},\n")
            f.write(f"    bonusNumbers: {draw['bonus']},\n")
            f.write(f"  ),\n")
        
        f.write("];\n")
    
    print(f"✓ Generated: {filename}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--limit', type=int, default=500)
    args = parser.parse_args()
    
    download_euromillions(args.limit)
    download_eurojackpot(args.limit)
```

---

### Step 7: Update GitHub Actions

**File:** `.github/workflows/update_lotto.yml`

```yaml
name: Update Lottery History

on:
  schedule:
    - cron: '0 12 * * *'  # Daily at 12:00 UTC
  workflow_dispatch:

jobs:
  update:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install requests beautifulsoup4 lxml playwright
          playwright install chromium
      
      # ── NEW: Shared multi-country lotteries ──────────────────────
      - name: Update shared lottery CSVs (EuroMillions, EuroJackpot)
        run: python tools/sync_shared_lottery_history.py --limit 500
      
      # ── Country-specific lotteries ───────────────────────────────
      - name: Update AU lottery CSVs
        run: python tools/sync_au_lottery_history.py --limit 120
      
      - name: Update US lottery CSVs
        run: python tools/sync_us_lottery_history.py --limit 120
      
      - name: Update UK lottery CSVs
        run: python tools/sync_uk_lottery_history.py --limit 120
        # NOTE: Now only downloads UK Lotto (not EuroMillions)
      
      - name: Update France lottery CSVs
        run: python tools/sync_fr_lottery_history.py --limit 500
        # NOTE: Now only downloads France Loto (not EuroMillions)
      
      - name: Update Germany lottery CSVs
        run: python tools/sync_de_lottery_history.py --limit 500
        # NOTE: Now only downloads Lotto 6aus49 (not EuroJackpot)
      
      - name: Update Canada lottery CSVs
        run: python tools/sync_ca_lottery_history.py --limit 120
      
      - name: Update Japan lottery CSVs
        run: python tools/sync_jp_lottery_history.py --limit 500
      
      # ── Commit and push ───────────────────────────────────────────
      - name: Commit and push changes
        run: |
          git config --local user.email "github-actions[bot]@users.noreply.github.com"
          git config --local user.name "github-actions[bot]"
          git add docs/*.csv lib/data/seed_*.dart
          git diff --quiet && git diff --staged --quiet || \
            git commit -m "chore: update lottery history data [automated]"
          git push
```

---

### Step 8: Update Existing Scripts

**Modify:** `tools/sync_uk_lottery_history.py`
```python
# Remove UK EuroMillions scraping
# Only keep UK Lotto
```

**Modify:** `tools/sync_fr_lottery_history.py`
```python
# Remove France EuroMillions scraping
# Only keep France Loto
```

**Modify:** `tools/sync_de_lottery_history.py`
```python
# Remove Germany EuroJackpot scraping
# Only keep Lotto 6aus49
```

---

### Step 9: Remove Duplicate Data

**Delete from:** `lib/data/seed_uk_lotteries.dart`
```dart
// Remove: final kUkEuroMillionsDraws = <LotteryDraw>[...];
```

**Delete from:** `lib/data/seed_france_lotteries.dart`
```dart
// Remove: final kFrEuroMillionsDraws = <LotteryDraw>[...];
```

**Delete from:** `lib/data/seed_germany_lotteries.dart` (if exists)
```dart
// Remove: final kDeEuroJackpotDraws = <LotteryDraw>[...];
```

**Delete files:**
```bash
rm docs/uk_euromillions.csv
rm docs/fr_euromillions.csv
rm docs/de_eurojackpot.csv
```

---

## Future Expansion Examples

### Adding Spain EuroMillions

**Just add config** (10 lines):

```dart
Lottery(
  id: 'es_euromillions',
  sharedDatasetId: 'euromillions',  // ← Reuses existing dataset!
  countryCode: 'ES',
  countryName: _l10n.countrySpain,
  name: _l10n.lotteryEuroMillions,
  mainCount: 5,
  mainMin: 1,
  mainMax: 50,
  bonusCount: 2,
  bonusMin: 1,
  bonusMax: 12,
  hasSeparateBonusPool: true,
  bonusLabel: _l10n.bonusLuckyStars,
),
```

**No code changes needed!** The shared dataset is already downloaded and ready.

### Adding Finland EuroJackpot

```dart
Lottery(
  id: 'fi_eurojackpot',
  sharedDatasetId: 'eurojackpot',  // ← Reuses existing dataset!
  countryCode: 'FI',
  countryName: _l10n.countryFinland,
  name: _l10n.lotteryEuroJackpot,
  // ... same config as de_eurojackpot
),
```

---

## User Experience

### Before (Current)

**Lottery Selector:**
```
🇺🇸 United States · Powerball
🇺🇸 United States · Mega Millions
🇦🇺 Australia · Powerball
🇦🇺 Australia · Oz Lotto
🇦🇺 Australia · Saturday Lotto
🇬🇧 United Kingdom · UK Lotto
🇬🇧 United Kingdom · EuroMillions     ← 120 draws
🇨🇦 Canada · Lotto Max
🇨🇦 Canada · Lotto 6/49
🇩🇪 Germany · Lotto 6aus49
🇩🇪 Germany · EuroJackpot
🇯🇵 Japan · ロト6
🇯🇵 Japan · ロト7
🇫🇷 France · France Loto
🇫🇷 France · EuroMillions              ← 500 draws (inconsistent!)
```

### After (Normalized)

**Lottery Selector:**
```
🇺🇸 United States · Powerball
🇺🇸 United States · Mega Millions
🇦🇺 Australia · Powerball
🇦🇺 Australia · Oz Lotto
🇦🇺 Australia · Saturday Lotto
🇬🇧 United Kingdom · UK Lotto
🇬🇧 United Kingdom · EuroMillions     ← 500 draws ✅
🇨🇦 Canada · Lotto Max
🇨🇦 Canada · Lotto 6/49
🇩🇪 Germany · Lotto 6aus49
🇩🇪 Germany · EuroJackpot             ← 500 draws ✅
🇯🇵 Japan · ロト6
🇯🇵 Japan · ロト7
🇫🇷 France · France Loto
🇫🇷 France · EuroMillions              ← 500 draws (same dataset as UK!)
```

**User selects "🇬🇧 United Kingdom · EuroMillions":**
- Backend: Loads `kSharedEuroMillionsDraws` (500 draws from FDJ)
- User sees: 500 historical draws for analysis ✅

**User selects "🇫🇷 France · EuroMillions":**
- Backend: Loads `kSharedEuroMillionsDraws` (same 500 draws)
- User sees: Identical dataset, consistent experience ✅

**Storage saved:** ~21 KB (19% reduction)  
**User impact:** ZERO (transparent backend optimization)  

---

## Testing Checklist

- [ ] Unit test: `sharedDatasetId` field in Lottery model
- [ ] Unit test: LotteryService returns shared dataset for UK/FR EuroMillions
- [ ] Unit test: LotteryService returns country-specific data for UK Lotto
- [ ] Integration test: UK and FR EuroMillions return identical draws
- [ ] Integration test: CSV service returns correct URL for shared datasets
- [ ] UI test: Lottery selector still shows country-based list
- [ ] UI test: Frequency analysis works with shared datasets
- [ ] UI test: History screen loads correctly for both UK and FR EuroMillions
- [ ] Build test: AAB size reduced by ~20 KB
- [ ] GitHub Actions test: Shared dataset script runs successfully
- [ ] Regression test: All existing lotteries still work

---

## Rollout Plan

### Phase 1: Implementation (Week 1)
- [ ] Add `sharedDatasetId` field to Lottery model
- [ ] Create `seed_shared_euromillions.dart`
- [ ] Create `seed_shared_eurojackpot.dart`
- [ ] Update lottery configs
- [ ] Update LotteryService
- [ ] Update CSV service
- [ ] Run unit tests

### Phase 2: Script Migration (Week 1)
- [ ] Create `sync_shared_lottery_history.py`
- [ ] Update existing scripts to remove EuroMillions/EuroJackpot
- [ ] Test scripts locally
- [ ] Update GitHub Actions workflow

### Phase 3: Cleanup (Week 2)
- [ ] Remove duplicate seed data from country files
- [ ] Delete duplicate CSV files
- [ ] Build and test AAB
- [ ] Verify storage savings

### Phase 4: Deployment (Week 2)
- [ ] Bump version to 1.0.13+15
- [ ] Deploy to internal testing
- [ ] Verify GitHub Actions runs successfully
- [ ] Deploy to production

---

## Success Criteria

✅ **Storage:** AAB size reduced by ~20 KB  
✅ **Consistency:** UK and FR EuroMillions show identical draws  
✅ **User Experience:** No visible changes to UI or behavior  
✅ **Maintenance:** Single script updates both UK and FR  
✅ **Scalability:** Adding Spain requires <10 lines of code  

---

**Implementation Ready**  
*Plan approved on 2026-06-13*
