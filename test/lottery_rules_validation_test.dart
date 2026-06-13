import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/data/seed_lotteries.dart';
import 'package:lottfun_flutter/services/lottery_service.dart';

void main() {
  group('Lottery Rules Validation', () {
    // Test all lottery configurations
    final allLotteries = kSeedLotteries;

    test('All lotteries have valid configuration', () {
      for (final lottery in allLotteries) {
        expect(lottery.mainCount, greaterThan(0), reason: '${lottery.id}: mainCount must be positive');
        expect(lottery.mainMin, greaterThanOrEqualTo(0), reason: '${lottery.id}: mainMin must be >= 0');
        expect(lottery.mainMax, greaterThan(lottery.mainMin), reason: '${lottery.id}: mainMax must be > mainMin');

        if (lottery.hasBonus) {
          expect(lottery.bonusCount, greaterThan(0), reason: '${lottery.id}: bonusCount must be positive');
          expect(lottery.bonusMin, isNotNull, reason: '${lottery.id}: bonusMin must not be null when hasBonus');
          expect(lottery.bonusMax, isNotNull, reason: '${lottery.id}: bonusMax must not be null when hasBonus');
          expect(lottery.bonusMax!, greaterThan(lottery.bonusMin!), reason: '${lottery.id}: bonusMax must be > bonusMin');
        }
      }
    });

    test('Pool types are correctly configured', () {
      // Separate pool lotteries (can have duplicate numbers in main and bonus)
      final separatePoolLotteries = {
        'au_powerball': true,
        'us_powerball': true,
        'us_megamillions': true,
        'uk_euromillions': true,
        'de_lotto_6aus49': true,
        'de_eurojackpot': true,
        'fr_loto': true,  // France Loto: Chance Number is separate (1-10)
        'fr_euromillions': true,  // EuroMillions: Lucky Stars are separate (1-12)
      };

      // Shared pool lotteries (CANNOT have duplicate numbers)
      final sharedPoolLotteries = {
        'au_ozlotto': false,
        'au_saturday': false,
        'uk_lotto': false,
        'ca_lotto_max': false,
        'ca_lotto_649': false,
        'jp_loto6': false,
        'jp_loto7': false,
      };

      for (final entry in separatePoolLotteries.entries) {
        final lottery = allLotteries.firstWhere((l) => l.id == entry.key);
        expect(
          lottery.hasSeparateBonusPool,
          entry.value,
          reason: '${entry.key} should have hasSeparateBonusPool=${entry.value}',
        );
      }

      for (final entry in sharedPoolLotteries.entries) {
        final lottery = allLotteries.firstWhere((l) => l.id == entry.key);
        expect(
          lottery.hasSeparateBonusPool,
          entry.value,
          reason: '${entry.key} should have hasSeparateBonusPool=${entry.value}',
        );
      }
    });

    test('France Loto rules are correct', () {
      final frLoto = allLotteries.firstWhere((l) => l.id == 'fr_loto');

      // Main numbers: 5 from 1-49
      expect(frLoto.mainCount, 5);
      expect(frLoto.mainMin, 1);
      expect(frLoto.mainMax, 49);

      // Chance Number: 1 from 1-10 (SEPARATE POOL)
      expect(frLoto.bonusCount, 1);
      expect(frLoto.bonusMin, 1);
      expect(frLoto.bonusMax, 10);
      expect(frLoto.hasSeparateBonusPool, true,
        reason: 'Chance Number is from separate pool (1-10), NOT from main pool (1-49)');
    });

    test('France EuroMillions rules are correct', () {
      final frEuro = allLotteries.firstWhere((l) => l.id == 'fr_euromillions');

      // Main numbers: 5 from 1-50
      expect(frEuro.mainCount, 5);
      expect(frEuro.mainMin, 1);
      expect(frEuro.mainMax, 50);

      // Lucky Stars: 2 from 1-12 (SEPARATE POOL)
      expect(frEuro.bonusCount, 2);
      expect(frEuro.bonusMin, 1);
      expect(frEuro.bonusMax, 12);
      expect(frEuro.hasSeparateBonusPool, true,
        reason: 'Lucky Stars are from separate pool (1-12), NOT from main pool (1-50)');
    });

    test('Historical data respects separate vs shared pool rules', () {
      final service = LotteryService.instance;

      for (final lottery in allLotteries) {
        final draws = service.getDraws(lottery.id);
        if (draws.isEmpty) continue;

        for (final draw in draws.take(10)) {  // Check first 10 draws
          // Verify main numbers are in range
          for (final num in draw.mainNumbers) {
            expect(num, greaterThanOrEqualTo(lottery.mainMin),
              reason: '${lottery.id}: main number $num below min ${lottery.mainMin}');
            expect(num, lessThanOrEqualTo(lottery.mainMax),
              reason: '${lottery.id}: main number $num above max ${lottery.mainMax}');
          }

          // Verify bonus numbers are in range
          if (draw.bonusNumbers != null && lottery.hasBonus) {
            for (final bonus in draw.bonusNumbers!) {
              expect(bonus, greaterThanOrEqualTo(lottery.bonusMin!),
                reason: '${lottery.id}: bonus $bonus below min ${lottery.bonusMin}');
              expect(bonus, lessThanOrEqualTo(lottery.bonusMax!),
                reason: '${lottery.id}: bonus $bonus above max ${lottery.bonusMax}');
            }

            // For SHARED pool lotteries, verify NO duplicates between main and bonus
            if (!lottery.hasSeparateBonusPool) {
              final mainSet = draw.mainNumbers.toSet();
              final bonusSet = draw.bonusNumbers!.toSet();
              final duplicates = mainSet.intersection(bonusSet);
              expect(
                duplicates.isEmpty,
                true,
                reason: '${lottery.id} (shared pool): Found duplicates $duplicates in draw ${draw.drawDate}. '
                    'Main: ${draw.mainNumbers}, Bonus: ${draw.bonusNumbers}',
              );
            }
          }

          // Verify no duplicates within main numbers
          expect(draw.mainNumbers.toSet().length, draw.mainNumbers.length,
            reason: '${lottery.id}: Duplicate in main numbers ${draw.mainNumbers}');

          // Verify no duplicates within bonus numbers
          if (draw.bonusNumbers != null) {
            expect(draw.bonusNumbers!.toSet().length, draw.bonusNumbers!.length,
              reason: '${lottery.id}: Duplicate in bonus numbers ${draw.bonusNumbers}');
          }
        }
      }
    });

    test('Complete My Numbers duplicate prevention logic matches pool rules', () {
      // This test verifies the logic in complete_my_numbers_screen.dart
      // The screen uses `!lottery.hasSeparateBonusPool` to check for duplicates

      for (final lottery in allLotteries.where((l) => l.hasBonus)) {
        if (lottery.hasSeparateBonusPool) {
          // Separate pool: duplicates ALLOWED (e.g., main number 5 can also be Lucky Star 5)
          expect(
            lottery.bonusMin != lottery.mainMin || lottery.bonusMax != lottery.mainMax,
            true,
            reason: '${lottery.id}: Separate pool should have different ranges',
          );
        } else {
          // Shared pool: duplicates NOT ALLOWED
          expect(lottery.bonusMin, lottery.mainMin,
            reason: '${lottery.id}: Shared pool should have same min');
          expect(lottery.bonusMax, lottery.mainMax,
            reason: '${lottery.id}: Shared pool should have same max');
        }
      }
    });

    test('France Loto historical data validation', () {
      final service = LotteryService.instance;
      final draws = service.getDraws('fr_loto');

      expect(draws.isNotEmpty, true, reason: 'France Loto should have historical data');

      for (final draw in draws.take(20)) {
        // Main numbers: must be 5 numbers from 1-49
        expect(draw.mainNumbers.length, 5);
        for (final num in draw.mainNumbers) {
          expect(num, greaterThanOrEqualTo(1));
          expect(num, lessThanOrEqualTo(49));
        }

        // Chance Number: must be 1 number from 1-10
        expect(draw.bonusNumbers, isNotNull);
        expect(draw.bonusNumbers!.length, 1);
        final chanceNumber = draw.bonusNumbers!.first;
        expect(chanceNumber, greaterThanOrEqualTo(1));
        expect(chanceNumber, lessThanOrEqualTo(10));

        // Because Chance Number pool (1-10) overlaps with main pool (1-49),
        // duplicates ARE allowed (e.g., main can be [1,2,3,4,5] and Chance can be 3)
        // This is CORRECT because hasSeparateBonusPool=true
      }
    });

    test('France EuroMillions historical data validation', () {
      final service = LotteryService.instance;
      final draws = service.getDraws('fr_euromillions');

      expect(draws.isNotEmpty, true, reason: 'France EuroMillions should have historical data');

      for (final draw in draws.take(20)) {
        // Main numbers: must be 5 numbers from 1-50
        expect(draw.mainNumbers.length, 5);
        for (final num in draw.mainNumbers) {
          expect(num, greaterThanOrEqualTo(1));
          expect(num, lessThanOrEqualTo(50));
        }

        // Lucky Stars: must be 2 numbers from 1-12
        expect(draw.bonusNumbers, isNotNull);
        expect(draw.bonusNumbers!.length, 2);
        for (final star in draw.bonusNumbers!) {
          expect(star, greaterThanOrEqualTo(1));
          expect(star, lessThanOrEqualTo(12));
        }

        // Because Lucky Stars pool (1-12) overlaps with main pool (1-50),
        // duplicates ARE allowed (e.g., main can be [1,2,3,4,5] and Stars can be [1,2])
        // This is CORRECT because hasSeparateBonusPool=true
      }
    });
  });
}
