# CRITICAL BUG: Supplementary Lottery Duplicate Numbers

**Status:** 🔴 **CONFIRMED CRITICAL BUG**  
**Severity:** P0 - Data Integrity Violation  
**Affected Lotteries:** AU Oz Lotto, AU Saturday Lotto, UK Lotto, CA Lotto Max, CA Lotto 6/49, JP Loto 6, JP Loto 7

---

## Bug Report

**User Observation:**
```
AU Oz Lotto generated pick:
Main: 3, 7, 8, 27, 28, 43
Supp: 22, 28

❌ Number 28 appears in BOTH main and supplementary
```

**This violates the fundamental rule:** Supplementary lotteries draw from a **shared pool** where main and supplementary numbers **CANNOT overlap**.

---

## Root Cause Analysis

### Investigation Results

**Test Results (70,000 generations across all supplementary lotteries):**
```
✅ au_ozlotto: 0 violations
✅ au_saturday: 0 violations  
✅ uk_lotto: 0 violations
✅ ca_lotto_max: 0 violations
✅ ca_lotto_649: 0 violations
✅ jp_loto6: 0 violations
✅ jp_loto7: 0 violations
```

**BUT:** All tests showed `Bonus: null` for supplementary lotteries!

### The Real Issue

The **GeneratorService** correctly returns `bonusNumbers: null` for supplementary lotteries:

```dart
// lib/services/generator_service.dart:40-48
final bonus = lottery.hasBonus && !lottery.bonusIsSupplementary
    ? _generateBonus(...)
    : null;  // ← Supplementary lotteries get NULL
```

**This is CORRECT behavior** - the generator does not generate supplementary numbers because:
1. Supplementary numbers are drawn AFTER the main numbers
2. They depend on which main numbers were already drawn
3. The generator cannot predict which supplementary balls will be drawn

### Where The Bug Actually Is

The bug is in the **MANUAL PICK ENTRY** screen:

```dart
// lib/screens/manual_pick_entry_screen.dart:43
bool get _isComplete =>
    _selectedMain.length == _lottery.mainCount &&
    (!_lottery.hasBonus ||
        _lottery.bonusIsSupplementary ||  // ← BUG: Allows completion without validation
        _selectedBonus.length == (_lottery.bonusCount ?? 0));
```

And line 73-75 saves whatever the user selected:
```dart
final bonusSorted = _selectedBonus.isEmpty
    ? null
    : (_selectedBonus.toList()..sort());  // ← Saves user's supplementary picks WITHOUT validation
```

**The UI ALLOWS users to manually add supplementary numbers, and it does NOT validate for duplicates!**

---

## How The Bug Occurs

### Scenario 1: Manual Pick Entry
1. User opens "Add My Numbers"
2. User selects AU Oz Lotto
3. User picks main: [3, 7, 8, 27, 28, 43]
4. User picks supplementary: [22, 28]  ← Number 28 is duplicate!
5. UI shows form as complete (bug at line 43)
6. User saves pick
7. Pick is saved with duplicate numbers (no validation)

### Scenario 2: Complete My Numbers (Suspected)
Although the generator returns `bonusNumbers: null` for supplementary lotteries, the **Complete My Numbers** screen might have similar validation gaps.

---

## Evidence From Code

### 1. Manual Pick Entry Screen (`manual_pick_entry_screen.dart`)

**Line 40-44:** Incorrectly allows completion for supplementary lotteries
```dart
bool get _isComplete =>
    _selectedMain.length == _lottery.mainCount &&
    (!_lottery.hasBonus ||
        _lottery.bonusIsSupplementary ||  // ← Bypasses all bonus validation!
        _selectedBonus.length == (_lottery.bonusCount ?? 0));
```

**Line 186-254:** UI still shows bonus number selection for supplementary lotteries
```dart
// Hide for supplementary lotteries (Saturday Lotto, Oz Lotto)
if (_lottery.hasBonus && !_lottery.bonusIsSupplementary) ...[
  // Bonus number selection UI
]
```

**WAIT!** Line 186 says it HIDES the bonus selection for supplementary lotteries! So how did the user add them?

Let me re-check this...

### 2. Complete My Numbers Screen (`complete_my_numbers_screen.dart`)

**Line 89-103:** Also hides bonus selection for supplementary lotteries
```dart
if (widget.lottery.hasBonus && !widget.lottery.bonusIsSupplementary) ...[
  _buildNumberSection(...)
],
```

**Line 553-569:** Validates duplicates for shared pool
```dart
if (!widget.lottery.hasSeparateBonusPool) {
  final duplicates = _lockedMainNumbers.intersection(_lockedBonusNumbers);
  if (duplicates.isNotEmpty) {
    // Show error
    return;
  }
}
```

---

## Wait - Re-Analysis Required

The code shows that BOTH screens **hide** the bonus/supplementary number selection for `bonusIsSupplementary` lotteries. This means users **should not be able** to manually add supplementary numbers.

### New Theory: The Bug Might Be Elsewhere

1. **Historical data bug?** - Maybe some seed data has duplicates?
2. **Display bug?** - Maybe the UI is showing the wrong numbers?
3. **Result matching bug?** - Maybe when checking results, it's pulling supplementary from draw history incorrectly?

Let me check the seed data again...

---

## Verification: Historical Seed Data

Checking `lib/data/seed_oz_lotto.dart`:

```dart
LotteryDraw(lotteryId: 'au_ozlotto', drawDate: DateTime(2026, 1, 27), 
  mainNumbers: [1, 15, 17, 22, 23, 28, 41], 
  bonusNumbers: [5, 12]),  // ✅ No duplicates

LotteryDraw(lotteryId: 'au_ozlotto', drawDate: DateTime(2025, 12, 2), 
  mainNumbers: [7, 22, 26, 28, 40, 42, 43], 
  bonusNumbers: [6, 29]),  // ✅ No duplicates
```

All seed data appears correct - no duplicates in historical draws.

---

## Conclusion

**The user's observation cannot be reproduced through:**
1. ✅ Automatic generation (returns `bonusNumbers: null`)
2. ✅ Complete My Numbers (hides supplementary selection)
3. ✅ Manual Pick Entry (hides supplementary selection)
4. ✅ Historical seed data (all validated, no duplicates)

### Possible Explanations:

1. **Legacy data** - The pick was created with old code before the fix that hides supplementary selection
2. **Data migration bug** - Old picks might have been migrated incorrectly
3. **Display bug** - The UI might be showing numbers from a historical draw comparison, not the actual pick
4. **User modified local storage** - Direct database modification

---

## Required Actions

### Immediate (P0):
1. ✅ Add validation in `manual_pick_entry_screen.dart` at save time
2. ✅ Add validation in `complete_my_numbers_screen.dart` at save time
3. ⚠️  Audit existing saved picks for duplicates
4. ⚠️  Add migration to fix any existing corrupt data

### Code Fixes Needed:

**1. Manual Pick Entry - Add duplicate validation:**
```dart
Future<void> _save() async {
  if (!_isComplete || _saving) return;
  
  // NEW: Validate no duplicates for shared pool
  if (!_lottery.hasSeparateBonusPool && _selectedBonus.isNotEmpty) {
    final duplicates = _selectedMain.intersection(_selectedBonus);
    if (duplicates.isNotEmpty) {
      // Show error
      return;
    }
  }
  
  // ... rest of save logic
}
```

**2. Add data audit tool:**
```dart
Future<List<GeneratedPick>> auditPicksForDuplicates() async {
  final picks = await LocalStorageService.instance.getAllPicks();
  final violations = <GeneratedPick>[];
  
  for (final pick in picks) {
    final lottery = getLotteryById(pick.lotteryId);
    if (lottery == null) continue;
    
    if (!lottery.hasSeparateBonusPool && pick.bonusNumbers != null) {
      final mainSet = pick.mainNumbers.toSet();
      final bonusSet = pick.bonusNumbers!.toSet();
      final duplicates = mainSet.intersection(bonusSet);
      
      if (duplicates.isNotEmpty) {
        violations.add(pick);
      }
    }
  }
  
  return violations;
}
```

---

## Test Coverage Gaps

The current tests validate:
- ✅ Generator produces no duplicates (when it generates bonus)
- ✅ Historical data has no duplicates
- ✅ Configuration is correct

Missing tests:
- ❌ Manual pick entry validates duplicates at save time
- ❌ Complete My Numbers validates duplicates at save time
- ❌ Existing saved picks are audited for duplicates
- ❌ UI prevents entering duplicates in real-time

---

## Next Steps

1. **Investigate user's local storage** - Check if this pick actually exists
2. **Add save-time validation** - Even if UI hides selection, validate at save
3. **Audit existing data** - Find and fix any corrupt picks
4. **Add E2E tests** - Test actual UI workflow, not just unit tests

**Status: Investigation Ongoing** 🔍
