import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/models/generated_pick.dart';

void main() {
  group('Defensive Validation Tests', () {
    test('GeneratedPick constructor rejects duplicate main numbers', () {
      expect(
        () => GeneratedPick(
          lotteryId: 'test',
          style: PlayStyle.random,
          mainNumbers: [1, 2, 3, 3, 4], // Duplicate 3
          createdAt: DateTime.now(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('GeneratedPick constructor rejects duplicate bonus numbers', () {
      expect(
        () => GeneratedPick(
          lotteryId: 'test',
          style: PlayStyle.random,
          mainNumbers: [1, 2, 3, 4, 5],
          bonusNumbers: [1, 1], // Duplicate 1
          createdAt: DateTime.now(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('GeneratedPick constructor accepts valid picks', () {
      final pick = GeneratedPick(
        lotteryId: 'au_ozlotto',
        style: PlayStyle.random,
        mainNumbers: [1, 2, 3, 4, 5, 6, 7],
        bonusNumbers: null, // Supplementary lotteries should have null
        createdAt: DateTime.now(),
      );

      expect(pick.mainNumbers, [1, 2, 3, 4, 5, 6, 7]);
      expect(pick.bonusNumbers, null);
    });

    test('GeneratedPick constructor accepts separate pool with overlapping numbers', () {
      // For separate pool lotteries (e.g., US Powerball), duplicates ARE allowed
      final pick = GeneratedPick(
        lotteryId: 'us_powerball',
        style: PlayStyle.random,
        mainNumbers: [1, 2, 3, 4, 5],
        bonusNumbers: [3], // 3 appears in both - OK for separate pools
        createdAt: DateTime.now(),
      );

      expect(pick.mainNumbers, [1, 2, 3, 4, 5]);
      expect(pick.bonusNumbers, [3]);
      // Note: The constructor doesn't validate cross-pool duplicates
      // That's handled by the generator and save-time validation
    });

    test('GeneratedPick constructor accepts properly sorted numbers', () {
      final pick = GeneratedPick(
        lotteryId: 'test',
        style: PlayStyle.random,
        mainNumbers: [1, 5, 10, 15, 20],
        bonusNumbers: [2, 8],
        createdAt: DateTime.now(),
      );

      expect(pick.mainNumbers, [1, 5, 10, 15, 20]);
      expect(pick.bonusNumbers, [2, 8]);
    });
  });
}
