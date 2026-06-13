import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/data/seed_lotteries.dart';
import 'package:lottfun_flutter/data/seed_france_lotteries.dart';
import 'package:lottfun_flutter/services/lottery_service.dart';

void main() {
  group('France Lottery Tests', () {
    test('France Loto is registered in seed lotteries', () {
      final frLoto = kSeedLotteries.firstWhere((l) => l.id == 'fr_loto');
      expect(frLoto.countryCode, 'FR');
      expect(frLoto.mainCount, 5);
      expect(frLoto.mainMin, 1);
      expect(frLoto.mainMax, 49);
      expect(frLoto.bonusCount, 1);
      expect(frLoto.bonusMin, 1);
      expect(frLoto.bonusMax, 10);
      expect(frLoto.hasSeparateBonusPool, true);
    });

    test('France EuroMillions is registered in seed lotteries', () {
      final frEuro = kSeedLotteries.firstWhere((l) => l.id == 'fr_euromillions');
      expect(frEuro.countryCode, 'FR');
      expect(frEuro.mainCount, 5);
      expect(frEuro.mainMin, 1);
      expect(frEuro.mainMax, 50);
      expect(frEuro.bonusCount, 2);
      expect(frEuro.bonusMin, 1);
      expect(frEuro.bonusMax, 12);
      expect(frEuro.hasSeparateBonusPool, true);
    });

    test('France Loto has seed draw data', () {
      expect(kFrLotoDraws.isNotEmpty, true);
      expect(kFrLotoDraws.length, 500);

      final firstDraw = kFrLotoDraws.first;
      expect(firstDraw.lotteryId, 'fr_loto');
      expect(firstDraw.mainNumbers.length, 5);
      expect(firstDraw.bonusNumbers?.length, 1);

      // Verify number ranges
      for (final num in firstDraw.mainNumbers) {
        expect(num, greaterThanOrEqualTo(1));
        expect(num, lessThanOrEqualTo(49));
      }

      if (firstDraw.bonusNumbers != null) {
        for (final bonus in firstDraw.bonusNumbers!) {
          expect(bonus, greaterThanOrEqualTo(1));
          expect(bonus, lessThanOrEqualTo(10));
        }
      }
    });

    test('France EuroMillions has seed draw data', () {
      expect(kFrEuroMillionsDraws.isNotEmpty, true);
      expect(kFrEuroMillionsDraws.length, 500);

      final firstDraw = kFrEuroMillionsDraws.first;
      expect(firstDraw.lotteryId, 'fr_euromillions');
      expect(firstDraw.mainNumbers.length, 5);
      expect(firstDraw.bonusNumbers?.length, 2);

      // Verify number ranges
      for (final num in firstDraw.mainNumbers) {
        expect(num, greaterThanOrEqualTo(1));
        expect(num, lessThanOrEqualTo(50));
      }

      if (firstDraw.bonusNumbers != null) {
        for (final bonus in firstDraw.bonusNumbers!) {
          expect(bonus, greaterThanOrEqualTo(1));
          expect(bonus, lessThanOrEqualTo(12));
        }
      }
    });

    test('France draws are sorted by date (newest first)', () {
      final frLotoDraws = kFrLotoDraws;
      for (int i = 0; i < frLotoDraws.length - 1; i++) {
        expect(
          frLotoDraws[i].drawDate.isAfter(frLotoDraws[i + 1].drawDate) ||
              frLotoDraws[i].drawDate.isAtSameMomentAs(frLotoDraws[i + 1].drawDate),
          true,
          reason: 'Draws should be sorted newest first',
        );
      }
    });

    test('LotteryService can fetch France Loto draws', () {
      final service = LotteryService.instance;
      final draws = service.getDraws('fr_loto');

      expect(draws.isNotEmpty, true);
      expect(draws.length, 500);
      expect(draws.first.lotteryId, 'fr_loto');
    });

    test('LotteryService can fetch France EuroMillions draws', () {
      final service = LotteryService.instance;
      final draws = service.getDraws('fr_euromillions');

      expect(draws.isNotEmpty, true);
      expect(draws.length, 500);
      expect(draws.first.lotteryId, 'fr_euromillions');
    });

    test('France Loto numbers are sorted', () {
      for (final draw in kFrLotoDraws) {
        // Main numbers should be in ascending order
        final sortedMain = [...draw.mainNumbers]..sort();
        expect(draw.mainNumbers, sortedMain);

        // Bonus numbers should be sorted
        if (draw.bonusNumbers != null) {
          final sortedBonus = [...draw.bonusNumbers!]..sort();
          expect(draw.bonusNumbers, sortedBonus);
        }
      }
    });
  });
}
