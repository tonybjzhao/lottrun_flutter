import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/data/seed_lotteries.dart';
import 'package:lottfun_flutter/services/lottery_service.dart';
import 'package:lottfun_flutter/services/generator_service.dart';
import 'package:lottfun_flutter/models/generated_pick.dart';
import 'package:lottfun_flutter/models/lottery_draw.dart';

void main() {
  group('Generator Duplicate Bug Test - Shared Pool Lotteries', () {
    final service = LotteryService.instance;
    final generator = GeneratorService.instance;

    // All shared pool lotteries (MUST NOT have duplicates)
    final sharedPoolLotteries = [
      'au_ozlotto',
      'au_saturday',
      'uk_lotto',
      'ca_lotto_max',
      'ca_lotto_649',
      'jp_loto6',
      'jp_loto7',
    ];

    for (final lotteryId in sharedPoolLotteries) {
      group('$lotteryId', () {
        late var lottery;
        late List<LotteryDraw> history;

        setUpAll(() {
          lottery = kSeedLotteries.firstWhere((l) => l.id == lotteryId);
          history = service.getRecentDraws(lotteryId, limit: 100);
          print('\n=== Testing $lotteryId ===');
          print('Pool: ${lottery.mainMin}-${lottery.mainMax}');
          print('Main: ${lottery.mainCount} numbers');
          print('Bonus: ${lottery.bonusCount} numbers');
          print('hasSeparateBonusPool: ${lottery.hasSeparateBonusPool}');
          print('bonusIsSupplementary: ${lottery.bonusIsSupplementary}');
        });

        test('10,000 random generations - no duplicates', () {
          final violations = <Map<String, dynamic>>[];

          for (var i = 0; i < 10000; i++) {
            final pick = generator.generate(
              lottery: lottery,
              style: PlayStyle.random,
              history: history,
            );

            if (pick.bonusNumbers != null) {
              final mainSet = pick.mainNumbers.toSet();
              final bonusSet = pick.bonusNumbers!.toSet();
              final duplicates = mainSet.intersection(bonusSet);

              if (duplicates.isNotEmpty) {
                violations.add({
                  'iteration': i,
                  'main': pick.mainNumbers,
                  'bonus': pick.bonusNumbers,
                  'duplicates': duplicates.toList(),
                });

                if (violations.length <= 5) {
                  print('❌ VIOLATION #${violations.length} at iteration $i:');
                  print('   Main: ${pick.mainNumbers}');
                  print('   Bonus: ${pick.bonusNumbers}');
                  print('   Duplicates: ${duplicates.toList()}');
                }
              }
            }
          }

          expect(violations.isEmpty, true,
            reason: '$lotteryId: Found ${violations.length} duplicate violations in 10,000 generations!\n'
                    'First violation: ${violations.isNotEmpty ? violations.first : "none"}');
        });

        test('10,000 hot generations - no duplicates', () {
          final violations = <Map<String, dynamic>>[];

          for (var i = 0; i < 10000; i++) {
            final pick = generator.generate(
              lottery: lottery,
              style: PlayStyle.hot,
              history: history,
            );

            if (pick.bonusNumbers != null) {
              final mainSet = pick.mainNumbers.toSet();
              final bonusSet = pick.bonusNumbers!.toSet();
              final duplicates = mainSet.intersection(bonusSet);

              if (duplicates.isNotEmpty) {
                violations.add({
                  'iteration': i,
                  'main': pick.mainNumbers,
                  'bonus': pick.bonusNumbers,
                  'duplicates': duplicates.toList(),
                });
              }
            }
          }

          expect(violations.isEmpty, true,
            reason: '$lotteryId: Found ${violations.length} duplicate violations in 10,000 hot generations!');
        });

        test('10,000 balanced generations - no duplicates', () {
          final violations = <Map<String, dynamic>>[];

          for (var i = 0; i < 10000; i++) {
            final pick = generator.generate(
              lottery: lottery,
              style: PlayStyle.balanced,
              history: history,
            );

            if (pick.bonusNumbers != null) {
              final mainSet = pick.mainNumbers.toSet();
              final bonusSet = pick.bonusNumbers!.toSet();
              final duplicates = mainSet.intersection(bonusSet);

              if (duplicates.isNotEmpty) {
                violations.add({
                  'iteration': i,
                  'main': pick.mainNumbers,
                  'bonus': pick.bonusNumbers,
                  'duplicates': duplicates.toList(),
                });
              }
            }
          }

          expect(violations.isEmpty, true,
            reason: '$lotteryId: Found ${violations.length} duplicate violations in 10,000 balanced generations!');
        });

        test('1,000 generations with locked main numbers', () {
          final violations = <Map<String, dynamic>>[];

          for (var i = 0; i < 1000; i++) {
            // Lock some random main numbers
            final lockedMain = [1, 2, 3];

            final pick = generator.generate(
              lottery: lottery,
              style: PlayStyle.random,
              history: history,
              lockedMainNumbers: lockedMain,
            );

            if (pick.bonusNumbers != null) {
              final mainSet = pick.mainNumbers.toSet();
              final bonusSet = pick.bonusNumbers!.toSet();
              final duplicates = mainSet.intersection(bonusSet);

              if (duplicates.isNotEmpty) {
                violations.add({
                  'iteration': i,
                  'lockedMain': lockedMain,
                  'main': pick.mainNumbers,
                  'bonus': pick.bonusNumbers,
                  'duplicates': duplicates.toList(),
                });

                if (violations.length <= 3) {
                  print('❌ LOCKED MAIN VIOLATION #${violations.length} at iteration $i:');
                  print('   Locked Main: $lockedMain');
                  print('   Final Main: ${pick.mainNumbers}');
                  print('   Bonus: ${pick.bonusNumbers}');
                  print('   Duplicates: ${duplicates.toList()}');
                }
              }
            }
          }

          expect(violations.isEmpty, true,
            reason: '$lotteryId: Found ${violations.length} duplicate violations with locked main numbers!');
        });

        test('1,000 generations with locked bonus numbers', () {
          final violations = <Map<String, dynamic>>[];

          for (var i = 0; i < 1000; i++) {
            // Lock bonus number that might conflict
            final lockedBonus = [5];

            final pick = generator.generate(
              lottery: lottery,
              style: PlayStyle.random,
              history: history,
              lockedBonusNumbers: lockedBonus,
            );

            if (pick.bonusNumbers != null) {
              final mainSet = pick.mainNumbers.toSet();
              final bonusSet = pick.bonusNumbers!.toSet();
              final duplicates = mainSet.intersection(bonusSet);

              if (duplicates.isNotEmpty) {
                violations.add({
                  'iteration': i,
                  'lockedBonus': lockedBonus,
                  'main': pick.mainNumbers,
                  'bonus': pick.bonusNumbers,
                  'duplicates': duplicates.toList(),
                });

                if (violations.length <= 3) {
                  print('❌ LOCKED BONUS VIOLATION #${violations.length} at iteration $i:');
                  print('   Locked Bonus: $lockedBonus');
                  print('   Main: ${pick.mainNumbers}');
                  print('   Final Bonus: ${pick.bonusNumbers}');
                  print('   Duplicates: ${duplicates.toList()}');
                }
              }
            }
          }

          expect(violations.isEmpty, true,
            reason: '$lotteryId: Found ${violations.length} duplicate violations with locked bonus numbers!');
        });

        test('Locked numbers appear in final result', () {
          // Verify locked numbers are actually included
          for (var i = 0; i < 100; i++) {
            final lockedMain = [1, 2];
            final lockedBonus = [5];

            final pick = generator.generate(
              lottery: lottery,
              style: PlayStyle.random,
              history: history,
              lockedMainNumbers: lockedMain,
              lockedBonusNumbers: lockedBonus,
            );

            expect(pick.mainNumbers.contains(1), true);
            expect(pick.mainNumbers.contains(2), true);

            if (pick.bonusNumbers != null) {
              expect(pick.bonusNumbers!.contains(5), true);
            }
          }
        });
      });
    }

    test('Report: Supplementary lottery behavior', () {
      print('\n=== SUPPLEMENTARY LOTTERY BEHAVIOR ===');

      for (final lotteryId in sharedPoolLotteries) {
        final lottery = kSeedLotteries.firstWhere((l) => l.id == lotteryId);
        final history = service.getRecentDraws(lotteryId, limit: 100);

        final pick = generator.generate(
          lottery: lottery,
          style: PlayStyle.random,
          history: history,
        );

        print('\n$lotteryId:');
        print('  bonusIsSupplementary: ${lottery.bonusIsSupplementary}');
        print('  Main: ${pick.mainNumbers}');
        print('  Bonus: ${pick.bonusNumbers}');
        print('  Bonus generated: ${pick.bonusNumbers != null}');
      }
    });
  });
}
