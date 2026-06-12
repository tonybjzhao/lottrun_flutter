# Invalid Lotto Max Draws Found

**Issue:** CA Lotto Max has max number range 1-50, but 5 draws contain 51 or 52

---

## Invalid Draws (MUST BE REMOVED OR CORRECTED)

1. **2026-06-02:** main=[6, 7, 23, 28, 34, 40, 43], bonus=[**52**] ❌
2. **2026-05-12:** main=[6, 12, 18, 24, 32, 34, 45], bonus=[**51**] ❌
3. **2026-05-01:** main=[9, 13, 15, 25, 27, 35, **52**], bonus=[39] ❌
4. **2026-04-17:** main=[7, 12, 29, 38, 39, 44, **52**], bonus=[35] ❌
5. **2026-04-14:** main=[4, 13, 20, 31, 37, 43, **51**], bonus=[9] ❌

---

## Action Required

**Option 1: DELETE** (Safest - if source is unreliable)
- Remove these 5 draws from seed file
- 120 draws → 115 draws

**Option 2: RE-SCRAPE** (Best - if we can get real data)
- Re-scrape these specific dates from olg.ca
- Correct the numbers

**Option 3: MANUAL CORRECTION** (Risky - could introduce errors)
- Look up each draw manually
- Replace 51→ ? and 52→ ?

---

## Recommendation

**DELETE** these 5 draws for now. Reason:
- Data source was clearly wrong (used 1-52 instead of 1-50)
- Better to have 115 correct draws than 120 with 5 invalid
- Can re-scrape later from official source

---

## Impact

- Loss of 5 draws (4.2% of dataset)
- Remaining 115 draws still covers 2+ years of data
- Analytics will still be accurate with correct number range
