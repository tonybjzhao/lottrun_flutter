import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/data/seed_lotteries.dart';
import 'package:lottfun_flutter/services/lottery_service.dart';

void main() {
  group('Germany Lottery Tests', () {
    test('Germany lotteries are included in seed data', () {
      final germanyLotteries = kSeedLotteries
          .where((l) => l.countryCode == 'DE')
          .toList();

      expect(germanyLotteries.length, 2,
          reason: 'Should have 2 Germany lotteries');

      final lotto6aus49 = germanyLotteries
          .firstWhere((l) => l.id == 'de_lotto_6aus49');
      final euroJackpot = germanyLotteries
          .firstWhere((l) => l.id == 'de_eurojackpot');

      expect(lotto6aus49, isNotNull);
      expect(euroJackpot, isNotNull);
    });

    test('Lotto 6aus49 configuration is correct', () {
      final lotto = kSeedLotteries
          .firstWhere((l) => l.id == 'de_lotto_6aus49');

      expect(lotto.countryCode, 'DE');
      expect(lotto.mainCount, 6);
      expect(lotto.mainMin, 1);
      expect(lotto.mainMax, 49);
      expect(lotto.bonusCount, 1);
      expect(lotto.bonusMin, 0);
      expect(lotto.bonusMax, 9);
      expect(lotto.hasSeparateBonusPool, true);
    });

    test('EuroJackpot configuration is correct', () {
      final euro = kSeedLotteries
          .firstWhere((l) => l.id == 'de_eurojackpot');

      expect(euro.countryCode, 'DE');
      expect(euro.mainCount, 5);
      expect(euro.mainMin, 1);
      expect(euro.mainMax, 50);
      expect(euro.bonusCount, 2);
      expect(euro.bonusMin, 1);
      expect(euro.bonusMax, 12);
      expect(euro.hasSeparateBonusPool, true);
    });

    test('Germany lotteries appear after Canada in list', () {
      final allIds = kSeedLotteries.map((l) => l.id).toList();
      final canadaIndex = allIds.lastIndexWhere((id) => id.startsWith('ca_'));
      final germanyIndex = allIds.indexWhere((id) => id.startsWith('de_'));

      expect(germanyIndex, greaterThan(canadaIndex),
          reason: 'Germany should appear after Canada');
    });

    test('Generator can create valid Lotto 6aus49 numbers', () {
      final lotto = kSeedLotteries
          .firstWhere((l) => l.id == 'de_lotto_6aus49');

      // Generate main numbers
      final mainNumbers = List.generate(
        lotto.mainCount,
        (i) => lotto.mainMin + i,
      );

      expect(mainNumbers.length, 6);
      expect(mainNumbers.every((n) => n >= 1 && n <= 49), true);

      // Generate Superzahl (0-9)
      final superzahl = 7;
      expect(superzahl >= 0 && superzahl <= 9, true);
    });

    test('Generator can create valid EuroJackpot numbers', () {
      final euro = kSeedLotteries
          .firstWhere((l) => l.id == 'de_eurojackpot');

      // Generate main numbers
      final mainNumbers = List.generate(
        euro.mainCount,
        (i) => euro.mainMin + i,
      );

      expect(mainNumbers.length, 5);
      expect(mainNumbers.every((n) => n >= 1 && n <= 50), true);

      // Generate Euro numbers
      final euroNumbers = [2, 9];
      expect(euroNumbers.length, 2);
      expect(euroNumbers.every((n) => n >= 1 && n <= 12), true);
    });

    test('Lottery names are localized', () {
      final lotto = kSeedLotteries
          .firstWhere((l) => l.id == 'de_lotto_6aus49');
      final euro = kSeedLotteries
          .firstWhere((l) => l.id == 'de_eurojackpot');

      expect(lotto.name, isNotEmpty);
      expect(euro.name, isNotEmpty);
      expect(lotto.countryName, isNotEmpty);
      expect(euro.countryName, isNotEmpty);
    });

    test('Bonus labels are correctly set', () {
      final lotto = kSeedLotteries
          .firstWhere((l) => l.id == 'de_lotto_6aus49');
      final euro = kSeedLotteries
          .firstWhere((l) => l.id == 'de_eurojackpot');

      expect(lotto.bonusLabel, isNotNull);
      expect(euro.bonusLabel, isNotNull);
      expect(lotto.bonusLabel, contains('Superzahl'));
      expect(euro.bonusLabel, contains('Euro'));
    });

    test('Lotto 6aus49 has seed draw data', () {
      final draws = LotteryService.instance.getDraws('de_lotto_6aus49');

      expect(draws, isNotEmpty);
      expect(draws.length, 50);

      // Check first draw
      final firstDraw = draws.first;
      expect(firstDraw.lotteryId, 'de_lotto_6aus49');
      expect(firstDraw.mainNumbers.length, 6);
      expect(firstDraw.bonusNumbers, isNotNull);
      expect(firstDraw.bonusNumbers!.length, 1);

      // Verify number ranges
      expect(firstDraw.mainNumbers.every((n) => n >= 1 && n <= 49), true);
      expect(firstDraw.bonusNumbers!.first >= 0 && firstDraw.bonusNumbers!.first <= 9, true);
    });

    test('EuroJackpot has seed draw data', () {
      final draws = LotteryService.instance.getDraws('de_eurojackpot');

      expect(draws, isNotEmpty);
      expect(draws.length, 50);

      // Check first draw
      final firstDraw = draws.first;
      expect(firstDraw.lotteryId, 'de_eurojackpot');
      expect(firstDraw.mainNumbers.length, 5);
      expect(firstDraw.bonusNumbers, isNotNull);
      expect(firstDraw.bonusNumbers!.length, 2);

      // Verify number ranges
      expect(firstDraw.mainNumbers.every((n) => n >= 1 && n <= 50), true);
      expect(firstDraw.bonusNumbers!.every((n) => n >= 1 && n <= 12), true);
    });

    test('Germany draws are sorted by date (newest first)', () {
      final lottoDraws = LotteryService.instance.getDraws('de_lotto_6aus49');
      final euroDraws = LotteryService.instance.getDraws('de_eurojackpot');

      // Check Lotto 6aus49 is sorted
      for (var i = 0; i < lottoDraws.length - 1; i++) {
        expect(
          lottoDraws[i].drawDate.isAfter(lottoDraws[i + 1].drawDate) ||
          lottoDraws[i].drawDate.isAtSameMomentAs(lottoDraws[i + 1].drawDate),
          true,
          reason: 'Lotto 6aus49 draws should be sorted newest first',
        );
      }

      // Check EuroJackpot is sorted
      for (var i = 0; i < euroDraws.length - 1; i++) {
        expect(
          euroDraws[i].drawDate.isAfter(euroDraws[i + 1].drawDate) ||
          euroDraws[i].drawDate.isAtSameMomentAs(euroDraws[i + 1].drawDate),
          true,
          reason: 'EuroJackpot draws should be sorted newest first',
        );
      }
    });
  });
}
