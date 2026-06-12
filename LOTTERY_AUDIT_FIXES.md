# Lottery Audit - Required Fixes

**Date:** 2026-06-12  
**Status:** CRITICAL - Data Integrity Issues Found

---

## Issues Found

### 1. 🇦🇺 AU Oz Lotto - WRONG bonusCount

**Current Config:**
```dart
bonusCount: 3,  // ❌ WRONG
```

**Correct Config:**
```dart
bonusCount: 2,  // ✅ CORRECT
```

**Evidence:**
- Official: Oz Lotto draws 7 main + **2 supplementary** numbers
- CSV file: Has `supp_3` column but ALL values are empty
- Seed file: Contains 3 bonus numbers (e.g., `[13, 40, 43]`)

**Impact:**
- ❌ Historical data shows 3 supplementary numbers (wrong)
- ❌ Analytics calculations use wrong bonus count
- ❌ Prize matching logic may be incorrect

**Fix Required:**
1. Change `bonusCount: 3` → `bonusCount: 2` in seed_lotteries.dart
2. Strip 3rd bonus number from all Oz Lotto draws in seed_oz_lotto.dart
3. Update CSV if needed (currently has empty supp_3)

---

### 2. 🇨🇦 CA Lotto Max - WRONG Number Range

**Current Config:**
```dart
mainMax: 52,   // ❌ WRONG
bonusMax: 52,  // ❌ WRONG
```

**Correct Config:**
```dart
mainMax: 50,   // ✅ CORRECT
bonusMax: 50,  // ✅ CORRECT
```

**Evidence:**
- Official: Lotto Max is 7/50 (choose 7 from 1-50)
- Historical data contains invalid numbers:
  - 2026-06-02: main=[..., 52] ❌
  - 2026-05-01: main=[..., 52] ❌
  - 2026-04-17: main=[..., 52] ❌
- Seed file has number 52 in mainNumbers

**Impact:**
- ❌ Users can select invalid numbers (51, 52)
- ❌ Historical data contains impossible draws
- ❌ Analytics based on wrong number range

**Fix Required:**
1. Change `mainMax: 52` → `mainMax: 50`
2. Change `bonusMax: 52` → `bonusMax: 50`
3. **CRITICAL:** Audit all Lotto Max historical data
4. Remove/correct any draws containing 51 or 52
5. May need to re-scrape data from official source

---

## Historical Context

### Lotto Max Evolution
- **2009-2015:** 7/49 format (1-49)
- **May 2019:** Changed to 7/50 format (1-50)
- **NEVER:** 7/52 format ❌

**Root Cause:** Possible confusion with:
- Old 7/49 format
- Or wrong source data scraped

---

## Fix Priority

**P0 - CRITICAL:**
1. Fix Oz Lotto bonusCount (affects all historical displays)
2. Fix Lotto Max number ranges (prevents invalid user selections)

**P1 - HIGH:**
3. Audit and clean Oz Lotto seed data (remove 3rd bonus)
4. Audit and clean Lotto Max seed data (remove 51-52)

**P2 - MEDIUM:**
5. Re-scrape Lotto Max from official source if needed
6. Add data validation tests

---

## Verification Checklist

After fixes:
- [ ] Config matches official lottery rules
- [ ] No historical draws contain out-of-range numbers
- [ ] No historical draws have wrong bonus count
- [ ] Generator service respects new limits
- [ ] Manual entry prevents selecting 51-52 for Lotto Max
- [ ] Analytics use correct number ranges
- [ ] Share cards display correct bonus count

---

## Other Lotteries - VERIFIED CORRECT ✅

| Lottery | Status | Notes |
|---------|--------|-------|
| 🇦🇺 Powerball | ✅ PASS | 7 (1-35) + 1 (1-20) |
| 🇦🇺 Saturday Lotto | ✅ PASS | 6 (1-45) + 2 supp |
| 🇺🇸 Powerball | ✅ PASS | 5 (1-69) + 1 (1-26) |
| 🇺🇸 Mega Millions | ✅ PASS | 5 (1-70) + 1 (1-25) |
| 🇬🇧 Lotto | ✅ PASS | 6 (1-59) + 1 bonus |
| 🇬🇧 EuroMillions | ✅ PASS | 5 (1-50) + 2 (1-12) |
| 🇨🇦 Lotto 6/49 | ✅ PASS | 6 (1-49) + 1 bonus |
| 🇩🇪 Lotto 6aus49 | ✅ PASS | 6 (1-49) + 1 (0-9) |
| 🇩🇪 EuroJackpot | ✅ PASS | 5 (1-50) + 2 (1-12) |
| 🇯🇵 Loto 6 | ✅ PASS | 6 (1-43) + 1 bonus |
| 🇯🇵 Loto 7 | ✅ PASS | 7 (1-37) + 2 bonus |

---

## Official Sources Referenced

- **AU Oz Lotto:** thelott.com - 7 main + 2 supplementary (1-47)
- **CA Lotto Max:** olg.ca - 7 main + 1 bonus (1-50) since May 2019

---

**Next Action:** Apply fixes to seed_lotteries.dart and clean historical data.
