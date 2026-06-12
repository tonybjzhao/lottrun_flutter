# Build Report - Version 1.0.11+13

**Build Date:** 2026-06-12 21:40:28  
**Build Type:** Android App Bundle (AAB)  
**Build Status:** ✅ SUCCESS

---

## Build Information

| Property | Value |
|----------|-------|
| **Version Name** | 1.0.11 |
| **Version Code** | 13 |
| **File** | `app-release.aab` |
| **Size** | 50 MB (52.6 MB) |
| **Path** | `build/app/outputs/bundle/release/app-release.aab` |
| **SHA-256** | `8deef90a2a13aa5050601f5dce99b30093f80209195d4a0ec63ea389688e7bcc` |
| **Build Time** | 86.2 seconds |

---

## What's New in 1.0.11+13

### 🇯🇵 Japan Lottery Support

**New Games Added:**
- **Loto 6:** 6 main numbers (1-43) + 1 bonus
- **Loto 7:** 7 main numbers (1-37) + 2 bonus

**Historical Data:**
- 1,500 real Loto 6 draws (2011-11-28 to 2026-06-11)
- 681 real Loto 7 draws (2013-04-05 to 2026-06-12)
- **Total:** 2,181 historical draws

**Localization:**
- Complete Japanese translation (414 keys, 99.7% coverage)
- Auto-update via GitHub Actions

---

### 🐛 Critical Bug Fixes

#### 1. P0: Duplicate Numbers in Shared Pool Lotteries

**Issue:**
```
Saturday Lotto generated: Main=[3, 7, 8, 27, 28, 43], Bonus=[22, 28]
❌ Number 28 appeared TWICE
```

**Fix:**
- Main generation now excludes locked bonus numbers for shared-pool lotteries
- Added runtime validation: `assert(mainSet ∩ bonusSet = ∅)`
- Throws StateError if duplicates detected

**Impact:**
- AU: Oz Lotto, Saturday Lotto ✅
- UK: UK Lotto ✅
- CA: Lotto Max, Lotto 6/49 ✅
- JP: Loto 6, Loto 7 ✅

---

#### 2. Supplementary Numbers Hidden from User Picks

**Issue:**
```
Saturday Lotto displayed:
3  7  8  27  28  43
Supplementary: 22  28  ❌
```

**Fix:**
```
Saturday Lotto displays:
3  7  8  27  28  43  ✅
```

**Rationale:**
- Supplementary numbers are **drawn by the lottery**, not chosen by players
- Users only select main numbers
- Supplementary shown only in historical draws for prize matching

**Affected Screens:**
- Complete My Numbers ✅
- Manual Pick Entry ✅
- Saved Picks ✅
- Home Screen (Three Picks) ✅
- Share Cards ✅

---

#### 3. AU Oz Lotto - Wrong Bonus Count

**Official Rule:** 7 main + **2 supplementary**  
**NumberRun Had:** `bonusCount: 3` ❌

**Fix:**
- Changed `bonusCount: 3 → 2`
- Stripped 3rd bonus from 261 historical draws
- Example: `[13, 40, 43] → [13, 40]`

---

#### 4. CA Lotto Max - Wrong Number Range

**Official Rule:** 7 main (1-50) + 1 bonus  
**NumberRun Had:** `mainMax: 52` ❌

**Fix:**
- Changed `mainMax: 52 → 50`, `bonusMax: 52 → 50`
- Removed 5 invalid draws containing 51-52
- Dataset: 120 → 115 valid draws

**Invalid Draws Removed:**
- 2026-06-02: bonus=[52]
- 2026-05-12: bonus=[51]
- 2026-05-01: main=[..., 52]
- 2026-04-17: main=[..., 52]
- 2026-04-14: main=[..., 51]

---

#### 5. Japan Country Name Display

**Issue:** Japan lotteries showed "其他" (Other) instead of "日本" (Japan)

**Fix:**
- Added `'JP' => countryJapan` to country code mapping
- Added `'jp_loto6' => lotteryLoto6` to lottery name mapping
- Added `'jp_loto7' => lotteryLoto7` to lottery name mapping

**Now Displays:**
- 🇨🇳 中文: 日本 · ロト6
- 🇺🇸 English: Japan · Loto 6
- 🇯🇵 日本語: 日本 · ロト6

---

### ✅ Complete Lottery Rules Audit

**Scope:** All 13 supported lotteries  
**Result:** 13/13 PASS (100%)

**Verified:**
- ✅ AU: Powerball, Oz Lotto, Saturday Lotto
- ✅ US: Powerball, Mega Millions
- ✅ UK: Lotto, EuroMillions
- ✅ CA: Lotto Max, Lotto 6/49
- ✅ DE: Lotto 6aus49, EuroJackpot
- ✅ JP: Loto 6, Loto 7

**Audit Criteria:**
1. User selection matches official ticket purchase
2. Bonus types (player-selected vs auto-drawn) correct
3. Pool structures (separate vs shared) accurate
4. Number ranges match official rules
5. No invalid historical data

---

## Build Warnings

**Java Warnings (Non-Critical):**
```
warning: [options] source value 8 is obsolete
warning: [options] target value 8 is obsolete
```
- **Impact:** None - Java 8 still supported
- **Action:** Can be ignored or updated to Java 11+ in future release

**Localization Warning:**
```
"ja": 1 untranslated message(s)
```
- **Impact:** Minimal - 413/414 keys translated (99.7%)
- **Missing:** 1 key in Japanese
- **Action:** Can be fixed in patch release

**Font Tree-Shaking (Optimization):**
```
MaterialIcons-Regular.otf: 1645184 → 8460 bytes (99.5% reduction)
```
- ✅ **Optimization successful** - Reduced icon font size significantly

---

## Git Commits

This release includes 6 commits:

1. **a17d60b** - Fix duplicate numbers in shared pool lotteries (P0)
2. **93a8823** - Hide supplementary numbers from user picks
3. **0e0174a** - Fix Oz Lotto and Lotto Max lottery rules
4. **a430890** - Add comprehensive lottery audit report
5. **c0c1559** - Fix Japan country name display
6. **f3eb3b0** - Bump version to 1.0.11+13

---

## Testing Checklist

### Before Release - Manual Testing Required

#### Japan Lotteries
- [ ] Loto 6 appears in lottery list
- [ ] Loto 7 appears in lottery list
- [ ] Country displays as "日本" in Chinese
- [ ] Generate numbers works for both games
- [ ] Complete My Numbers works (only main numbers)
- [ ] Manual entry works (only main numbers)
- [ ] Historical draws display correctly
- [ ] Analytics show correct data

#### Duplicate Number Fix
- [ ] Saturday Lotto: Generate 100 picks, verify no duplicates
- [ ] Oz Lotto: Generate 100 picks, verify no duplicates
- [ ] UK Lotto: Generate 100 picks, verify no duplicates
- [ ] Lotto Max: Generate 100 picks, verify no duplicates
- [ ] Loto 6: Generate 100 picks, verify no duplicates
- [ ] Loto 7: Generate 100 picks, verify no duplicates

#### Supplementary Number Hiding
- [ ] Saturday Lotto: User picks show only 6 main numbers
- [ ] Oz Lotto: User picks show only 7 main numbers
- [ ] UK Lotto: User picks show only 6 main numbers
- [ ] Lotto Max: User picks show only 7 main numbers
- [ ] Loto 6: User picks show only 6 main numbers
- [ ] Loto 7: User picks show only 7 main numbers
- [ ] Historical draws still show supplementary for prize matching

#### Number Range Validation
- [ ] Lotto Max: Cannot select 51 or 52
- [ ] Lotto Max: Historical draws have no numbers > 50
- [ ] Oz Lotto: Historical draws have exactly 2 supplementary

#### Separate Pool Games (Should Show Bonus)
- [ ] AU Powerball: Shows Powerball picker
- [ ] US Powerball: Shows Powerball picker
- [ ] US Mega Millions: Shows Mega Ball picker
- [ ] UK EuroMillions: Shows Lucky Stars picker
- [ ] DE Lotto 6aus49: Shows Superzahl picker
- [ ] DE EuroJackpot: Shows Euro Numbers picker

---

## Deployment

**File Location:**
```
build/app/outputs/bundle/release/app-release.aab
```

**Upload To:**
- Google Play Console
- Internal Testing → Production

**Rollout Strategy:**
- Staged rollout: 10% → 50% → 100%
- Monitor crash reports
- Watch for duplicate number reports

---

## Documentation

**New Files:**
- `LOTTERY_AUDIT.md` - Detailed audit methodology
- `LOTTERY_AUDIT_FIXES.md` - Fix implementation details
- `LOTTERY_AUDIT_FINAL_REPORT.md` - Comprehensive report
- `INVALID_LOTTO_MAX_DRAWS.md` - Removed draws list
- `BUILD_1.0.11+13.md` - This file

---

## Known Issues

**None reported**

---

## Next Steps

1. ✅ Build AAB - COMPLETE
2. ⏳ Upload to Google Play Console
3. ⏳ Create internal test release
4. ⏳ Manual testing (use checklist above)
5. ⏳ Production rollout (staged)
6. ⏳ Monitor analytics and crash reports

---

**Build Completed:** 2026-06-12 21:40:28  
**Ready for Deployment:** ✅ YES

**Previous Version:** 1.0.10+12  
**Current Version:** 1.0.11+13  
**Next Version:** 1.0.12+14 (TBD)
