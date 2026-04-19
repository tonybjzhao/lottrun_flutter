import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/data/seed_lotteries.dart';
import 'package:lottfun_flutter/models/generated_pick.dart';
import 'package:lottfun_flutter/models/lottery_draw.dart';
import 'package:lottfun_flutter/services/pick_result_service.dart';

// ── Test fixtures ─────────────────────────────────────────────────────────────

final _saturdayLottery = kSeedLotteries.firstWhere((l) => l.id == 'au_saturday');
final _ozLottery       = kSeedLotteries.firstWhere((l) => l.id == 'au_ozlotto');
final _auPowerball     = kSeedLotteries.firstWhere((l) => l.id == 'au_powerball');

final _drawDate = DateTime(2024, 6, 1);

GeneratedPick _pick({
  required String lotteryId,
  required List<int> main,
  List<int>? bonus,
}) =>
    GeneratedPick(
      lotteryId: lotteryId,
      style: PlayStyle.balanced,
      mainNumbers: main,
      bonusNumbers: bonus,
      createdAt: DateTime(2024, 5, 28),
      drawDate: _drawDate,
    );

LotteryDraw _draw({
  required String lotteryId,
  required List<int> main,
  List<int>? supp,
}) =>
    LotteryDraw(
      lotteryId: lotteryId,
      drawDate: _drawDate,
      mainNumbers: main,
      bonusNumbers: supp,
    );

// ── Legacy / pending ──────────────────────────────────────────────────────────

void main() {
  group('checkPickResult — legacy & pending', () {
    test('returns null for pick with no drawDate', () {
      final pick = GeneratedPick(
        lotteryId: 'au_saturday',
        style: PlayStyle.balanced,
        mainNumbers: [1, 2, 3, 4, 5, 6],
        createdAt: DateTime.now(),
      );
      expect(checkPickResult(pick, _saturdayLottery, []), isNull);
    });

    test('returns pending when draw date not in history', () {
      final pick = _pick(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 6]);
      final result = checkPickResult(pick, _saturdayLottery, []);
      expect(result?.isPending, isTrue);
    });
  });

  // ── Saturday Lotto ────────────────────────────────────────────────────────

  group('Saturday Lotto (mainCount=6, supplementary)', () {
    test('no match at all', () {
      final pick = _pick(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 6], bonus: [7, 8]);
      final draw = _draw(lotteryId: 'au_saturday', main: [10, 20, 30, 40, 41, 42], supp: [43, 44]);
      final r = checkPickResult(pick, _saturdayLottery, [draw])!;
      expect(r.isPending, isFalse);
      expect(r.matchedMain, 0);
      expect(r.suppHits, 0);
      expect(r.matchedBonus, 0);
      expect(r.emotionalText(_saturdayLottery),
          'No match this time — luck is building 🤞');
    });

    test('3 main matched', () {
      final pick = _pick(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 6]);
      final draw = _draw(lotteryId: 'au_saturday', main: [1, 2, 3, 10, 20, 30], supp: [31, 32]);
      final r = checkPickResult(pick, _saturdayLottery, [draw])!;
      expect(r.matchedMain, 3);
      expect(r.suppHits, 0);
      expect(r.emotionalText(_saturdayLottery), '3 main matched — almost! 🤞');
    });

    test('3 main + 1 supp', () {
      final pick = _pick(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 6]);
      final draw = _draw(lotteryId: 'au_saturday', main: [1, 2, 3, 10, 20, 30], supp: [4, 32]);
      final r = checkPickResult(pick, _saturdayLottery, [draw])!;
      expect(r.matchedMain, 3);
      expect(r.suppHits, 1);
      expect(r.matchedMainInDrawSupp, contains(4));
      expect(r.emotionalText(_saturdayLottery), '😮 3 main + 1 supp matched — almost!');
    });

    test('4 main (Division 4 tier) — "So close"', () {
      final pick = _pick(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 6]);
      final draw = _draw(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 20, 30], supp: [31, 32]);
      final r = checkPickResult(pick, _saturdayLottery, [draw])!;
      expect(r.matchedMain, 4);
      expect(r.suppHits, 0);
      // mainCount-2 = 4 → "So close"
      expect(r.emotionalText(_saturdayLottery), '😮 So close — 4 main matched!');
    });

    test('5 main = Division 3', () {
      final pick = _pick(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 6]);
      final draw = _draw(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 30], supp: [31, 32]);
      final r = checkPickResult(pick, _saturdayLottery, [draw])!;
      expect(r.matchedMain, 5);
      expect(r.suppHits, 0);
      expect(r.emotionalText(_saturdayLottery), '🔥 Division 3! 5 main matched!');
    });

    test('5 main + 1 supp = Division 2', () {
      final pick = _pick(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 6]);
      final draw = _draw(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 30], supp: [6, 32]);
      final r = checkPickResult(pick, _saturdayLottery, [draw])!;
      expect(r.matchedMain, 5);
      expect(r.suppHits, 1);
      expect(r.emotionalText(_saturdayLottery), '🏆 Division 2! 5 main + 1 supp matched!');
    });

    test('6 main = Division 1', () {
      final pick = _pick(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 6]);
      final draw = _draw(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 6], supp: [31, 32]);
      final r = checkPickResult(pick, _saturdayLottery, [draw])!;
      expect(r.matchedMain, 6);
      expect(r.emotionalText(_saturdayLottery), '🏆 Division 1! All 6 matched!');
    });

    test('supp pick hit a draw main number', () {
      final pick = _pick(lotteryId: 'au_saturday', main: [10, 20, 30, 40, 41, 42], bonus: [1, 2]);
      final draw = _draw(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 6], supp: [31, 32]);
      final r = checkPickResult(pick, _saturdayLottery, [draw])!;
      expect(r.matchedMain, 0);
      expect(r.matchedBonusInDrawMain, containsAll([1, 2]));
    });
  });

  // ── Oz Lotto ──────────────────────────────────────────────────────────────

  group('Oz Lotto (mainCount=7, supplementary)', () {
    test('6 main + 1 supp = Division 2', () {
      final pick = _pick(lotteryId: 'au_ozlotto', main: [1, 2, 3, 4, 5, 6, 7]);
      final draw = _draw(lotteryId: 'au_ozlotto', main: [1, 2, 3, 4, 5, 6, 30], supp: [7, 32, 33]);
      final r = checkPickResult(pick, _ozLottery, [draw])!;
      expect(r.matchedMain, 6);
      expect(r.suppHits, 1);
      expect(r.emotionalText(_ozLottery), '🏆 Division 2! 6 main + 1 supp matched!');
    });

    test('7 main = Division 1', () {
      final pick = _pick(lotteryId: 'au_ozlotto', main: [1, 2, 3, 4, 5, 6, 7]);
      final draw = _draw(lotteryId: 'au_ozlotto', main: [1, 2, 3, 4, 5, 6, 7], supp: [31, 32, 33]);
      final r = checkPickResult(pick, _ozLottery, [draw])!;
      expect(r.matchedMain, 7);
      expect(r.emotionalText(_ozLottery), '🏆 Division 1! All 7 matched!');
    });
  });

  // ── AU Powerball ──────────────────────────────────────────────────────────

  group('AU Powerball (bonusIsSupplementary=false)', () {
    test('no cross-pool contamination: pick.main vs draw.bonus ignored', () {
      // pick main includes draw bonus number (26) — should NOT count as supp hit
      final pick = _pick(lotteryId: 'au_powerball', main: [1, 2, 3, 4, 5, 6, 26], bonus: [5]);
      final draw = _draw(lotteryId: 'au_powerball', main: [10, 20, 30, 40, 41, 42, 43], supp: [5, 26]);
      final r = checkPickResult(pick, _auPowerball, [draw])!;
      expect(r.matchedMain, 0);
      expect(r.suppHits, 0);
      expect(r.matchedMainInDrawSupp, isEmpty);
    });

    test('bonus ball match', () {
      final pick = _pick(lotteryId: 'au_powerball', main: [1, 2, 3, 4, 5, 6, 7], bonus: [5]);
      final draw = _draw(lotteryId: 'au_powerball', main: [10, 20, 30, 40, 41, 42, 43], supp: [5]);
      final r = checkPickResult(pick, _auPowerball, [draw])!;
      expect(r.matchedBonus, 1);
      expect(r.matchedMain, 0);
      expect(r.emotionalText(_auPowerball), 'Powerball matched! — keep going 🙌');
    });

    test('4 main matched', () {
      final pick = _pick(lotteryId: 'au_powerball', main: [1, 2, 3, 4, 5, 6, 7], bonus: [9]);
      final draw = _draw(lotteryId: 'au_powerball', main: [1, 2, 3, 4, 10, 20, 30], supp: [11]);
      final r = checkPickResult(pick, _auPowerball, [draw])!;
      expect(r.matchedMain, 4);
      expect(r.emotionalText(_auPowerball), '🔥 Wow — 4 matched!');
    });
  });

  // ── Score ranking ─────────────────────────────────────────────────────────

  group('score', () {
    test('supp hits contribute to score with lower weight than main', () {
      final pick = _pick(lotteryId: 'au_saturday', main: [1, 2, 3, 4, 5, 6]);
      final draw = _draw(lotteryId: 'au_saturday', main: [1, 2, 3, 10, 20, 30], supp: [4, 32]);
      final r = checkPickResult(pick, _saturdayLottery, [draw])!;
      // 3 main × 2 = 6, 1 supp × 1 = 1 → total 7
      expect(r.score, 7);
    });
  });
}
