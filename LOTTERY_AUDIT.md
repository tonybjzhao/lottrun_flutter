# Complete Lottery Rules Audit

**Date:** 2026-06-12  
**Auditor:** Claude Sonnet 4.5  
**Purpose:** Verify NumberRun matches official ticket purchase rules

---

## Audit Methodology

For each lottery, verify:

1. **What numbers users select when buying a ticket**
2. **Whether bonus/supplementary numbers are player-selected or auto-drawn**
3. **Whether main and bonus share the same pool**
4. **Whether duplicates between main and bonus are allowed**
5. **Whether NumberRun configuration is correct**

---

## 🇦🇺 AUSTRALIA

### AU Powerball
- **Official Rules:** Choose 7 numbers (1-35) + 1 Powerball (1-20)
- **Main Pool:** 1-35 (choose 7)
- **Powerball Pool:** 1-20 (choose 1) - **SEPARATE POOL**
- **User Selects Bonus:** ✅ YES - Powerball is chosen by player
- **Shared Pool:** ❌ NO - Separate pools (main 1-35, Powerball 1-20)
- **Duplicates Allowed:** ✅ YES - Same number can appear in both (e.g., main=7, Powerball=7)

**NumberRun Config:**
```dart
mainCount: 7, mainMin: 1, mainMax: 35,
bonusCount: 1, bonusMin: 1, bonusMax: 20,
hasSeparateBonusPool: true,
bonusLabel: "Powerball",
```

**Status:** ✅ **CORRECT**

---

### AU Oz Lotto
- **Official Rules:** Choose 7 numbers (1-47). Supplementary numbers drawn by lottery.
- **Main Pool:** 1-47 (choose 7)
- **Supplementary Numbers:** 2 numbers auto-drawn from remaining 40 numbers
- **User Selects Bonus:** ❌ NO - Supplementary numbers are machine-drawn
- **Shared Pool:** ✅ YES - Same pool (1-47), but drawn AFTER main
- **Duplicates Allowed:** ❌ NO - Supplementary cannot duplicate main (drawn from remaining)

**NumberRun Config:**
```dart
mainCount: 7, mainMin: 1, mainMax: 47,
bonusCount: 3, bonusMin: 1, bonusMax: 47,  // ⚠️ WRONG: should be 2, not 3
hasSeparateBonusPool: false,
bonusLabel: null,  // ✅ CORRECT (supplementary style)
```

**Status:** ⚠️ **INCORRECT - bonusCount should be 2, not 3**

---

### AU Saturday Lotto
- **Official Rules:** Choose 6 numbers (1-45). Supplementary numbers drawn by lottery.
- **Main Pool:** 1-45 (choose 6)
- **Supplementary Numbers:** 2 numbers auto-drawn from remaining 39 numbers
- **User Selects Bonus:** ❌ NO - Supplementary numbers are machine-drawn
- **Shared Pool:** ✅ YES - Same pool (1-45), but drawn AFTER main
- **Duplicates Allowed:** ❌ NO - Supplementary cannot duplicate main

**NumberRun Config:**
```dart
mainCount: 6, mainMin: 1, mainMax: 45,
bonusCount: 2, bonusMin: 1, bonusMax: 45,  // ✅ CORRECT
hasSeparateBonusPool: false,
bonusLabel: null,  // ✅ CORRECT (supplementary style)
```

**Status:** ✅ **CORRECT**

---

## 🇺🇸 UNITED STATES

### US Powerball
- **Official Rules:** Choose 5 white balls (1-69) + 1 red Powerball (1-26)
- **Main Pool:** 1-69 (choose 5)
- **Powerball Pool:** 1-26 (choose 1) - **SEPARATE POOL**
- **User Selects Bonus:** ✅ YES - Powerball is chosen by player
- **Shared Pool:** ❌ NO - Separate pools
- **Duplicates Allowed:** ✅ YES - e.g., white=26, Powerball=26 is valid

**NumberRun Config:**
```dart
mainCount: 5, mainMin: 1, mainMax: 69,
bonusCount: 1, bonusMin: 1, bonusMax: 26,
hasSeparateBonusPool: true,
bonusLabel: "Powerball",
```

**Status:** ✅ **CORRECT**

---

### US Mega Millions
- **Official Rules:** Choose 5 white balls (1-70) + 1 gold Mega Ball (1-25)
- **Main Pool:** 1-70 (choose 5)
- **Mega Ball Pool:** 1-25 (choose 1) - **SEPARATE POOL**
- **User Selects Bonus:** ✅ YES - Mega Ball is chosen by player
- **Shared Pool:** ❌ NO - Separate pools
- **Duplicates Allowed:** ✅ YES

**NumberRun Config:**
```dart
mainCount: 5, mainMin: 1, mainMax: 70,
bonusCount: 1, bonusMin: 1, bonusMax: 25,
hasSeparateBonusPool: true,
bonusLabel: "Mega Ball",
```

**Status:** ✅ **CORRECT**

---

## 🇬🇧 UNITED KINGDOM

### UK Lotto
- **Official Rules:** Choose 6 numbers (1-59). Bonus Ball drawn by lottery.
- **Main Pool:** 1-59 (choose 6)
- **Bonus Ball:** 1 number auto-drawn from remaining 53 numbers
- **User Selects Bonus:** ❌ NO - Bonus Ball is machine-drawn
- **Shared Pool:** ✅ YES - Same pool (1-59), drawn AFTER main
- **Duplicates Allowed:** ❌ NO

**NumberRun Config:**
```dart
mainCount: 6, mainMin: 1, mainMax: 59,
bonusCount: 1, bonusMin: 1, bonusMax: 59,  // ✅ CORRECT
hasSeparateBonusPool: false,
bonusLabel: null,  // ✅ CORRECT (supplementary style)
```

**Status:** ✅ **CORRECT**

---

### UK EuroMillions
- **Official Rules:** Choose 5 main numbers (1-50) + 2 Lucky Stars (1-12)
- **Main Pool:** 1-50 (choose 5)
- **Lucky Stars Pool:** 1-12 (choose 2) - **SEPARATE POOL**
- **User Selects Bonus:** ✅ YES - Lucky Stars are chosen by player
- **Shared Pool:** ❌ NO - Separate pools
- **Duplicates Allowed:** ✅ YES

**NumberRun Config:**
```dart
mainCount: 5, mainMin: 1, mainMax: 50,
bonusCount: 2, bonusMin: 1, bonusMax: 12,
hasSeparateBonusPool: true,
bonusLabel: "Lucky Stars",
```

**Status:** ✅ **CORRECT**

---

## 🇨🇦 CANADA

### CA Lotto Max
- **Official Rules:** Choose 7 numbers (1-50). Bonus number drawn by lottery.
- **Main Pool:** 1-50 (choose 7)
- **Bonus Number:** 1 number auto-drawn from remaining 43 numbers
- **User Selects Bonus:** ❌ NO - Bonus is machine-drawn
- **Shared Pool:** ✅ YES - Same pool (1-50), drawn AFTER main
- **Duplicates Allowed:** ❌ NO

**NumberRun Config:**
```dart
mainCount: 7, mainMin: 1, mainMax: 52,  // ⚠️ WRONG: should be 50, not 52
bonusCount: 1, bonusMin: 1, bonusMax: 52,  // ⚠️ WRONG: should be 50
hasSeparateBonusPool: false,
bonusLabel: null,  // ✅ CORRECT (supplementary style)
```

**Status:** ⚠️ **INCORRECT - mainMax and bonusMax should be 50, not 52**

---

### CA Lotto 6/49
- **Official Rules:** Choose 6 numbers (1-49). Bonus number drawn by lottery.
- **Main Pool:** 1-49 (choose 6)
- **Bonus Number:** 1 number auto-drawn from remaining 43 numbers
- **User Selects Bonus:** ❌ NO - Bonus is machine-drawn
- **Shared Pool:** ✅ YES - Same pool (1-49), drawn AFTER main
- **Duplicates Allowed:** ❌ NO

**NumberRun Config:**
```dart
mainCount: 6, mainMin: 1, mainMax: 49,
bonusCount: 1, bonusMin: 1, bonusMax: 49,  // ✅ CORRECT
hasSeparateBonusPool: false,
bonusLabel: null,  // ✅ CORRECT (supplementary style)
```

**Status:** ✅ **CORRECT**

---

## 🇩🇪 GERMANY

### DE Lotto 6aus49
- **Official Rules:** Choose 6 numbers (1-49) + 1 Superzahl (0-9)
- **Main Pool:** 1-49 (choose 6)
- **Superzahl Pool:** 0-9 (choose 1) - **SEPARATE POOL**
- **User Selects Bonus:** ✅ YES - Superzahl is chosen by player
- **Shared Pool:** ❌ NO - Separate pools
- **Duplicates Allowed:** N/A (different ranges)

**NumberRun Config:**
```dart
mainCount: 6, mainMin: 1, mainMax: 49,
bonusCount: 1, bonusMin: 0, bonusMax: 9,
hasSeparateBonusPool: true,
bonusLabel: "Superzahl",
```

**Status:** ✅ **CORRECT**

---

### DE EuroJackpot
- **Official Rules:** Choose 5 main numbers (1-50) + 2 Euro numbers (1-12)
- **Main Pool:** 1-50 (choose 5)
- **Euro Numbers Pool:** 1-12 (choose 2) - **SEPARATE POOL**
- **User Selects Bonus:** ✅ YES - Euro numbers are chosen by player
- **Shared Pool:** ❌ NO - Separate pools
- **Duplicates Allowed:** ✅ YES

**NumberRun Config:**
```dart
mainCount: 5, mainMin: 1, mainMax: 50,
bonusCount: 2, bonusMin: 1, bonusMax: 12,
hasSeparateBonusPool: true,
bonusLabel: "Euro Numbers",
```

**Status:** ✅ **CORRECT**

---

## 🇯🇵 JAPAN

### JP Loto 6
- **Official Rules:** Choose 6 numbers (1-43). Bonus number drawn by lottery.
- **Main Pool:** 1-43 (choose 6)
- **Bonus Number:** 1 number auto-drawn from remaining 37 numbers
- **User Selects Bonus:** ❌ NO - Bonus is machine-drawn
- **Shared Pool:** ✅ YES - Same pool (1-43), drawn AFTER main
- **Duplicates Allowed:** ❌ NO

**NumberRun Config:**
```dart
mainCount: 6, mainMin: 1, mainMax: 43,
bonusCount: 1, bonusMin: 1, bonusMax: 43,  // ✅ CORRECT
hasSeparateBonusPool: false,
bonusLabel: null,  // ✅ CORRECT (supplementary style)
```

**Status:** ✅ **CORRECT**

---

### JP Loto 7
- **Official Rules:** Choose 7 numbers (1-37). 2 bonus numbers drawn by lottery.
- **Main Pool:** 1-37 (choose 7)
- **Bonus Numbers:** 2 numbers auto-drawn from remaining 30 numbers
- **User Selects Bonus:** ❌ NO - Bonus numbers are machine-drawn
- **Shared Pool:** ✅ YES - Same pool (1-37), drawn AFTER main
- **Duplicates Allowed:** ❌ NO

**NumberRun Config:**
```dart
mainCount: 7, mainMin: 1, mainMax: 37,
bonusCount: 2, bonusMin: 1, bonusMax: 37,  // ✅ CORRECT
hasSeparateBonusPool: false,
bonusLabel: null,  // ✅ CORRECT (supplementary style)
```

**Status:** ✅ **CORRECT**

---

## Summary Table

| Lottery | Main Numbers | Bonus User Selects? | Shared Pool? | Current Config | Status |
|---------|--------------|---------------------|--------------|----------------|--------|
| 🇦🇺 Powerball | 7 (1-35) | ✅ YES (1-20) | ❌ NO | Separate pool ✅ | ✅ PASS |
| 🇦🇺 Oz Lotto | 7 (1-47) | ❌ NO (2 supp) | ✅ YES | bonusCount=3 ❌ | ❌ **FAIL** |
| 🇦🇺 Saturday Lotto | 6 (1-45) | ❌ NO (2 supp) | ✅ YES | Supplementary ✅ | ✅ PASS |
| 🇺🇸 Powerball | 5 (1-69) | ✅ YES (1-26) | ❌ NO | Separate pool ✅ | ✅ PASS |
| 🇺🇸 Mega Millions | 5 (1-70) | ✅ YES (1-25) | ❌ NO | Separate pool ✅ | ✅ PASS |
| 🇬🇧 Lotto | 6 (1-59) | ❌ NO (1 bonus) | ✅ YES | Supplementary ✅ | ✅ PASS |
| 🇬🇧 EuroMillions | 5 (1-50) | ✅ YES 2 (1-12) | ❌ NO | Separate pool ✅ | ✅ PASS |
| 🇨🇦 Lotto Max | 7 (1-50) | ❌ NO (1 bonus) | ✅ YES | mainMax=52 ❌ | ❌ **FAIL** |
| 🇨🇦 Lotto 6/49 | 6 (1-49) | ❌ NO (1 bonus) | ✅ YES | Supplementary ✅ | ✅ PASS |
| 🇩🇪 Lotto 6aus49 | 6 (1-49) | ✅ YES (0-9) | ❌ NO | Separate pool ✅ | ✅ PASS |
| 🇩🇪 EuroJackpot | 5 (1-50) | ✅ YES 2 (1-12) | ❌ NO | Separate pool ✅ | ✅ PASS |
| 🇯🇵 Loto 6 | 6 (1-43) | ❌ NO (1 bonus) | ✅ YES | Supplementary ✅ | ✅ PASS |
| 🇯🇵 Loto 7 | 7 (1-37) | ❌ NO (2 bonus) | ✅ YES | Supplementary ✅ | ✅ PASS |

---

## CRITICAL ISSUES FOUND

### 1. ❌ AU Oz Lotto - INCORRECT bonusCount
**Current:** `bonusCount: 3`  
**Correct:** `bonusCount: 2`  
**Impact:** HIGH - Displays wrong number of supplementary balls in historical results

**Official Source:** Oz Lotto draws 7 main + 2 supplementary numbers

---

### 2. ❌ CA Lotto Max - INCORRECT mainMax and bonusMax
**Current:** `mainMax: 52, bonusMax: 52`  
**Correct:** `mainMax: 50, bonusMax: 50`  
**Impact:** HIGH - Allows users to select invalid numbers (50-52)

**Official Source:** Lotto Max changed from 1-50 in May 2019 (NOT 1-52)

---

## Fix Plan

### Priority 1: Data Integrity

1. **Fix AU Oz Lotto bonusCount**
   - Change from 3 to 2
   - Audit historical draw data (docs/au_ozlotto.csv)
   - Regenerate seed file if needed

2. **Fix CA Lotto Max ranges**
   - Change mainMax from 52 to 50
   - Change bonusMax from 52 to 50
   - Audit historical draw data (docs/ca_lotto_max.csv)
   - Regenerate seed file if needed

### Priority 2: Verification

3. **Verify all CSV data matches new config**
4. **Test generator service with corrected ranges**
5. **Test analytics with corrected data**

---

## FINAL VERDICT

**PASS:** 11/13 lotteries (84.6%)  
**FAIL:** 2/13 lotteries (15.4%)

**Failed Games:**
1. 🇦🇺 Oz Lotto - Wrong supplementary count
2. 🇨🇦 Lotto Max - Wrong number range

**Recommendation:** Fix both issues before production deployment.

---

**Audit Completed:** 2026-06-12  
**Next Steps:** Apply fixes and re-audit
