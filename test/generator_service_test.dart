import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/data/seed_lotteries.dart';
import 'package:lottfun_flutter/models/generated_pick.dart';
import 'package:lottfun_flutter/services/generator_service.dart';

void main() {
  group('GeneratorService country configs', () {
    for (final id in [
      'uk_lotto',
      'uk_euromillions',
      'ca_lotto_max',
      'ca_lotto_649',
    ]) {
      test('$id generates configured counts and ranges', () {
        final lottery = kSeedLotteries.firstWhere((l) => l.id == id);
        final pick = GeneratorService.instance.generate(
          lottery: lottery,
          style: PlayStyle.random,
          history: const [],
        );

        expect(pick.mainNumbers, hasLength(lottery.mainCount));
        expect(pick.mainNumbers.toSet(), hasLength(lottery.mainCount));
        expect(
          pick.mainNumbers,
          everyElement(inInclusiveRange(lottery.mainMin, lottery.mainMax)),
        );

        expect(pick.bonusNumbers, hasLength(lottery.bonusCount));
        expect(pick.bonusNumbers!.toSet(), hasLength(lottery.bonusCount));
        expect(
          pick.bonusNumbers!,
          everyElement(inInclusiveRange(lottery.bonusMin!, lottery.bonusMax!)),
        );
      });
    }

    test('same-pool bonus games do not duplicate generated main numbers', () {
      final samePoolGames = ['uk_lotto', 'ca_lotto_max', 'ca_lotto_649'];

      for (final id in samePoolGames) {
        final lottery = kSeedLotteries.firstWhere((l) => l.id == id);
        for (var i = 0; i < 25; i++) {
          final pick = GeneratorService.instance.generate(
            lottery: lottery,
            style: PlayStyle.random,
            history: const [],
          );
          expect(
            pick.mainNumbers.toSet().intersection(pick.bonusNumbers!.toSet()),
            isEmpty,
          );
        }
      }
    });

    test('UK Lotto records the two-round ticket format', () {
      final lottery = kSeedLotteries.firstWhere((l) => l.id == 'uk_lotto');
      expect(lottery.drawRoundsPerTicket, 2);
      expect(lottery.mainCount, 6);
      expect(lottery.mainMax, 59);
    });

    test('EuroMillions uses Lucky Stars from a separate pool', () {
      final lottery = kSeedLotteries.firstWhere(
        (l) => l.id == 'uk_euromillions',
      );
      expect(lottery.hasSeparateBonusPool, isTrue);
      expect(lottery.bonusLabel, 'Lucky Stars');
      expect(lottery.bonusCount, 2);
      expect(lottery.bonusMax, 12);
    });
  });
}
