import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/data/seed_lotteries.dart';
import 'package:lottfun_flutter/services/lottery_service.dart';

void main() {
  group('Shared Dataset Tests', () {
    final service = LotteryService.instance;

    test('UK and France EuroMillions use shared dataset', () {
      final ukLottery = kSeedLotteries.firstWhere((l) => l.id == 'uk_euromillions');
      final frLottery = kSeedLotteries.firstWhere((l) => l.id == 'fr_euromillions');

      // Both should have sharedDatasetId
      expect(ukLottery.sharedDatasetId, 'euromillions');
      expect(frLottery.sharedDatasetId, 'euromillions');
    });

    test('UK and France EuroMillions return identical draws', () {
      final ukDraws = service.getDraws('uk_euromillions');
      final frDraws = service.getDraws('fr_euromillions');

      // Should be identical (same object reference)
      expect(identical(ukDraws, frDraws), true);

      // Verify data equality
      expect(ukDraws.length, frDraws.length);
      expect(ukDraws.length, greaterThan(0));

      for (var i = 0; i < ukDraws.length; i++) {
        expect(ukDraws[i].drawDate, frDraws[i].drawDate,
            reason: 'Draw $i dates should match');
        expect(ukDraws[i].mainNumbers, frDraws[i].mainNumbers,
            reason: 'Draw $i main numbers should match');
        expect(ukDraws[i].bonusNumbers, frDraws[i].bonusNumbers,
            reason: 'Draw $i bonus numbers should match');
      }
    });

    test('Germany EuroJackpot uses shared dataset', () {
      final deLottery = kSeedLotteries.firstWhere((l) => l.id == 'de_eurojackpot');

      // Should have sharedDatasetId
      expect(deLottery.sharedDatasetId, 'eurojackpot');
    });

    test('Germany EuroJackpot returns shared draws', () {
      final draws = service.getDraws('de_eurojackpot');

      // Should have draws from shared dataset
      expect(draws.length, greaterThan(0));

      // Verify first draw is valid
      expect(draws[0].mainNumbers.length, 5);
      expect(draws[0].bonusNumbers?.length, 2);
    });

    test('Country-specific lotteries do NOT use shared dataset', () {
      final ukLotto = kSeedLotteries.firstWhere((l) => l.id == 'uk_lotto');
      final frLoto = kSeedLotteries.firstWhere((l) => l.id == 'fr_loto');
      final deLotto = kSeedLotteries.firstWhere((l) => l.id == 'de_lotto_6aus49');

      // Should NOT have sharedDatasetId
      expect(ukLotto.sharedDatasetId, null);
      expect(frLoto.sharedDatasetId, null);
      expect(deLotto.sharedDatasetId, null);
    });

    test('Country-specific lotteries return different draws', () {
      final ukLottoDraws = service.getDraws('uk_lotto');
      final frLotoDraws = service.getDraws('fr_loto');

      // Should NOT be identical
      expect(identical(ukLottoDraws, frLotoDraws), false);

      // Different lottery configurations
      expect(ukLottoDraws[0].mainNumbers.length, 6); // UK Lotto: 6 main
      expect(frLotoDraws[0].mainNumbers.length, 5); // FR Loto: 5 main
    });

    test('EuroMillions draws have correct structure', () {
      final draws = service.getDraws('uk_euromillions');

      expect(draws.length, 500); // France source has 500 draws

      final latest = draws.first;
      expect(latest.lotteryId, 'euromillions'); // Generic ID for shared dataset
      expect(latest.mainNumbers.length, 5);
      expect(latest.bonusNumbers?.length, 2);

      // Verify numbers are in valid range
      for (var num in latest.mainNumbers) {
        expect(num, greaterThanOrEqualTo(1));
        expect(num, lessThanOrEqualTo(50));
      }

      for (var num in latest.bonusNumbers!) {
        expect(num, greaterThanOrEqualTo(1));
        expect(num, lessThanOrEqualTo(12));
      }
    });

    test('EuroJackpot draws have correct structure', () {
      final draws = service.getDraws('de_eurojackpot');

      expect(draws.length, greaterThan(0));

      final latest = draws.first;
      expect(latest.lotteryId, 'eurojackpot'); // Generic ID for shared dataset
      expect(latest.mainNumbers.length, 5);
      expect(latest.bonusNumbers?.length, 2);

      // Verify numbers are in valid range
      for (var num in latest.mainNumbers) {
        expect(num, greaterThanOrEqualTo(1));
        expect(num, lessThanOrEqualTo(50));
      }

      for (var num in latest.bonusNumbers!) {
        expect(num, greaterThanOrEqualTo(1));
        expect(num, lessThanOrEqualTo(12));
      }
    });

    test('Storage optimization: UK EuroMillions now has 500 draws instead of 120', () {
      final ukDraws = service.getDraws('uk_euromillions');

      // Before: UK had only 120 draws
      // After: UK uses France dataset with 500 draws
      expect(ukDraws.length, 500);
    });
  });
}
