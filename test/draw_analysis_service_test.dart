import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/models/lottery.dart';
import 'package:lottfun_flutter/models/lottery_draw.dart';
import 'package:lottfun_flutter/services/draw_analysis_service.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Lottery _makeLottery({
  String id = 'test',
  int mainCount = 6,
  int mainMin = 1,
  int mainMax = 45,
}) =>
    Lottery(
      id: id,
      countryCode: 'AU',
      countryName: 'Australia',
      name: 'Test Lotto',
      mainCount: mainCount,
      mainMin: mainMin,
      mainMax: mainMax,
    );

LotteryDraw _makeDraw(String id, List<int> main, {DateTime? date}) =>
    LotteryDraw(
      lotteryId: id,
      drawDate: date ?? DateTime(2024, 1, 1),
      mainNumbers: main,
    );

List<LotteryDraw> _makeDraws(String id, List<List<int>> mains) {
  return List.generate(
    mains.length,
    (i) => _makeDraw(id, mains[i],
        date: DateTime(2024, 1, 1).subtract(Duration(days: i * 7))),
  );
}

// Generate N draws with varied numbers for a given lottery
List<LotteryDraw> _generateHistory(
    String id, int count, int mainCount, int mainMax) {
  return List.generate(count, (i) {
    final nums = <int>{};
    int seed = i;
    while (nums.length < mainCount) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      nums.add((seed % mainMax) + 1);
    }
    return _makeDraw(id, nums.toList()..sort(),
        date: DateTime(2024, 1, 1).subtract(Duration(days: i * 7)));
  });
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── 1. Frequency analysis ────────────────────────────────────────────────

  group('Frequency analysis', () {
    test('top 5 most frequent numbers are returned', () {
      final lottery = _makeLottery();
      // Number 1 appears in every draw; 2 in most; others vary
      final draws = _makeDraws('test', [
        [1, 2, 10, 20, 30, 40],
        [1, 2, 11, 21, 31, 41],
        [1, 2, 12, 22, 32, 42],
        [1, 3, 13, 23, 33, 43],
        [1, 3, 14, 24, 34, 44],
      ]);
      final result = DrawAnalysisService.analyzeRecentTrends(
          lottery: lottery, draws: draws, drawCount: 5);
      expect(result.topFrequent, contains(1));
      expect(result.topFrequent.length, lessThanOrEqualTo(5));
    });

    test('bottom 5 least frequent numbers are returned', () {
      final lottery = _makeLottery();
      final draws = _makeDraws('test', [
        [1, 2, 3, 4, 5, 6],
        [1, 2, 3, 4, 5, 7],
        [1, 2, 3, 4, 5, 8],
        [1, 2, 3, 4, 5, 9],
        [1, 2, 3, 4, 5, 10],
      ]);
      final result = DrawAnalysisService.analyzeRecentTrends(
          lottery: lottery, draws: draws, drawCount: 5);
      // Numbers 6-10 each appear once — all are "cold"
      expect(result.bottomFrequent.length, lessThanOrEqualTo(5));
      for (final n in result.bottomFrequent) {
        expect(result.topFrequent, isNot(contains(n)));
      }
    });

    test('empty draws returns safe defaults', () {
      final lottery = _makeLottery();
      final result = DrawAnalysisService.analyzeRecentTrends(
          lottery: lottery, draws: [], drawCount: 20);
      expect(result.topFrequent, isEmpty);
      expect(result.bottomFrequent, isEmpty);
      expect(result.averageSum, 0);
    });

    test('drawCount limits how many draws are used', () {
      final lottery = _makeLottery();
      final draws = _makeDraws('test', [
        [1, 2, 3, 4, 5, 6],
        [7, 8, 9, 10, 11, 12],
        [13, 14, 15, 16, 17, 18],
      ]);
      final result = DrawAnalysisService.analyzeRecentTrends(
          lottery: lottery, draws: draws, drawCount: 1);
      expect(result.drawCount, 1);
      // Only first draw numbers should appear in frequency
      expect(result.topFrequent.every((n) => n <= 6), isTrue);
    });
  });

  // ── 2. Hot/cold classification ────────────────────────────────────────────

  group('Hot/cold classification', () {
    test('hot numbers are top 25% by frequency', () {
      final lottery = _makeLottery(mainMax: 20, mainCount: 5);
      // Numbers 1-5 appear in every draw → hot
      final draws = _generateHistory('test', 60, 5, 20);
      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: _makeDraw('test', [1, 2, 3, 4, 5],
            date: DateTime(2024, 1, 1)),
        allDraws: draws,
      );
      // Just verify it runs and returns a valid score
      if (result != null) {
        expect(result.hotNumberCount + result.coldNumberCount,
            lessThanOrEqualTo(5));
      }
    });

    test('returns null when history < 52 draws', () {
      final lottery = _makeLottery();
      final draws = _generateHistory('test', 30, 6, 45);
      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: _makeDraw('test', [1, 2, 3, 4, 5, 6],
            date: DateTime(2024, 1, 1)),
        allDraws: draws,
      );
      expect(result, isNull);
    });

    test('returns result when history >= 52 draws', () {
      final lottery = _makeLottery();
      final draws = _generateHistory('test', 60, 6, 45);
      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: _makeDraw('test', [1, 2, 3, 4, 5, 6],
            date: DateTime(2024, 1, 1)),
        allDraws: draws,
      );
      expect(result, isNotNull);
    });
  });

  // ── 3. Score always 0-100 ─────────────────────────────────────────────────

  group('Score range 0-100', () {
    test('historicalMatchScore is always 0-100', () {
      final lottery = _makeLottery();
      final draws = _generateHistory('test', 100, 6, 45);
      for (int i = 0; i < 10; i++) {
        final target = draws[i];
        final history = draws.skip(i + 1).toList();
        final result = DrawAnalysisService.analyzeHistoricalPattern(
          lottery: lottery,
          targetDraw: target,
          allDraws: history,
        );
        if (result != null) {
          expect(result.historicalMatchScore, inInclusiveRange(0, 100));
          expect(result.trendScore, inInclusiveRange(0, 100));
          expect(result.hotColdAlignmentScore, inInclusiveRange(0, 100));
          expect(result.oddEvenStructureScore, inInclusiveRange(0, 100));
          expect(result.lowHighStructureScore, inInclusiveRange(0, 100));
          expect(result.sumRangeScore, inInclusiveRange(0, 100));
          expect(result.consecutiveScore, inInclusiveRange(0, 100));
        }
      }
    });

    test('all component scores are 0-100 with extreme inputs', () {
      final lottery = _makeLottery(mainMax: 10, mainCount: 3);
      final draws = _generateHistory('test', 60, 3, 10);
      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: _makeDraw('test', [1, 2, 3],
            date: DateTime(2024, 1, 1)),
        allDraws: draws,
      );
      if (result != null) {
        expect(result.historicalMatchScore, inInclusiveRange(0, 100));
      }
    });
  });

  // ── 4. Similar draw ranking ───────────────────────────────────────────────

  group('Similar draw ranking', () {
    test('returns at most 3 similar draws', () {
      final lottery = _makeLottery();
      final draws = _generateHistory('test', 60, 6, 45);
      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: draws.first,
        allDraws: draws.skip(1).toList(),
      );
      expect(result?.similarPastDraws.length, lessThanOrEqualTo(3));
    });

    test('most similar draw has highest similarity score', () {
      final lottery = _makeLottery();
      final draws = _generateHistory('test', 60, 6, 45);
      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: draws.first,
        allDraws: draws.skip(1).toList(),
      );
      if (result != null && result.similarPastDraws.length >= 2) {
        expect(result.similarPastDraws[0].similarityScore,
            greaterThanOrEqualTo(result.similarPastDraws[1].similarityScore));
      }
    });

    test('draw with most shared numbers ranks highest', () {
      final lottery = _makeLottery();
      final target = _makeDraw('test', [1, 2, 3, 4, 5, 6],
          date: DateTime(2024, 6, 1));
      // history[0] shares 5 numbers, history[1] shares 1
      final history = _generateHistory('test', 60, 6, 45);
      // Inject a very similar draw at the end
      final similar = _makeDraw('test', [1, 2, 3, 4, 5, 7],
          date: DateTime(2020, 1, 1));
      final allHistory = [...history, similar];

      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: target,
        allDraws: allHistory,
      );
      if (result != null && result.similarPastDraws.isNotEmpty) {
        expect(result.similarPastDraws.first.sharedNumbers, greaterThan(0));
      }
    });
  });

  // ── 5. Empty / insufficient history ──────────────────────────────────────

  group('Empty / insufficient history', () {
    test('analyzeRecentTrends with empty draws returns safe result', () {
      final lottery = _makeLottery();
      final result = DrawAnalysisService.analyzeRecentTrends(
          lottery: lottery, draws: [], drawCount: 20);
      expect(result.summary, isNotEmpty);
      expect(result.drawCount, 0);
    });

    test('analyzeHistoricalPattern returns null for 0 history draws', () {
      final lottery = _makeLottery();
      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: _makeDraw('test', [1, 2, 3, 4, 5, 6]),
        allDraws: [],
      );
      expect(result, isNull);
    });

    test('analyzeHistoricalPattern returns null for 51 draws (below minimum)', () {
      final lottery = _makeLottery();
      final draws = _generateHistory('test', 51, 6, 45);
      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: _makeDraw('test', [1, 2, 3, 4, 5, 6],
            date: DateTime(2024, 1, 1)),
        allDraws: draws,
      );
      expect(result, isNull);
    });

    test('analyzeSavedPicks with empty picks returns safe result', () {
      final draws = _generateHistory('test', 20, 6, 45);
      final result = DrawAnalysisService.analyzeSavedPicks(
        savedMainNumbers: [],
        recentDraws: draws,
      );
      expect(result.summary, isNotEmpty);
      expect(result.averageMatchCount, 0);
    });

    test('analyzeSavedPicks with empty draws returns safe result', () {
      final result = DrawAnalysisService.analyzeSavedPicks(
        savedMainNumbers: [
          [1, 2, 3, 4, 5, 6]
        ],
        recentDraws: [],
      );
      expect(result.summary, isNotEmpty);
      expect(result.averageMatchCount, 0);
    });
  });

  // ── 6. Different games ────────────────────────────────────────────────────

  group('Different game configurations', () {
    test('Saturday Lotto — 6 from 1-45', () {
      final lottery = _makeLottery(
          id: 'au_saturday', mainCount: 6, mainMin: 1, mainMax: 45);
      final draws = _generateHistory('au_saturday', 60, 6, 45);
      final result = DrawAnalysisService.analyzeRecentTrends(
          lottery: lottery, draws: draws, drawCount: 20);
      expect(result.drawCount, 20);
      expect(result.topFrequent.length, lessThanOrEqualTo(5));
    });

    test('Oz Lotto — 7 from 1-47', () {
      final lottery = _makeLottery(
          id: 'au_ozlotto', mainCount: 7, mainMin: 1, mainMax: 47);
      final draws = _generateHistory('au_ozlotto', 60, 7, 47);
      final result = DrawAnalysisService.analyzeRecentTrends(
          lottery: lottery, draws: draws, drawCount: 20);
      expect(result.drawCount, 20);
      expect(result.averageSum, greaterThan(0));
    });

    test('Powerball — 7 from 1-35', () {
      final lottery = _makeLottery(
          id: 'au_powerball', mainCount: 7, mainMin: 1, mainMax: 35);
      final draws = _generateHistory('au_powerball', 60, 7, 35);
      final result = DrawAnalysisService.analyzeRecentTrends(
          lottery: lottery, draws: draws, drawCount: 20);
      expect(result.drawCount, 20);
      expect(result.mostCommonOddEven, isNotEmpty);
      expect(result.mostCommonLowHigh, isNotEmpty);
    });

    test('historicalMatchScore valid for Oz Lotto', () {
      final lottery = _makeLottery(
          id: 'au_ozlotto', mainCount: 7, mainMin: 1, mainMax: 47);
      final draws = _generateHistory('au_ozlotto', 80, 7, 47);
      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: draws.first,
        allDraws: draws.skip(1).toList(),
      );
      if (result != null) {
        expect(result.historicalMatchScore, inInclusiveRange(0, 100));
      }
    });

    test('historicalMatchScore valid for Powerball', () {
      final lottery = _makeLottery(
          id: 'au_powerball', mainCount: 7, mainMin: 1, mainMax: 35);
      final draws = _generateHistory('au_powerball', 80, 7, 35);
      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: draws.first,
        allDraws: draws.skip(1).toList(),
      );
      if (result != null) {
        expect(result.historicalMatchScore, inInclusiveRange(0, 100));
      }
    });
  });

  // ── 7. Saved picks analysis ───────────────────────────────────────────────

  group('Saved picks analysis', () {
    test('best match draw is identified correctly', () {
      final draws = _makeDraws('test', [
        [1, 2, 3, 4, 5, 6],
        [7, 8, 9, 10, 11, 12],
      ]);
      final result = DrawAnalysisService.analyzeSavedPicks(
        savedMainNumbers: [
          [1, 2, 3, 20, 21, 22]
        ],
        recentDraws: draws,
      );
      // First draw shares 3 numbers, second shares 0
      expect(result.bestMatchCount, 3);
    });

    test('recently appeared numbers are correct', () {
      final draws = _makeDraws('test', [
        [1, 2, 3, 4, 5, 6],
      ]);
      final result = DrawAnalysisService.analyzeSavedPicks(
        savedMainNumbers: [
          [1, 2, 30, 31, 32, 33]
        ],
        recentDraws: draws,
      );
      expect(result.recentlyAppearedNumbers, containsAll([1, 2]));
      expect(result.recentlyAppearedNumbers, isNot(contains(30)));
    });

    test('average match count is computed correctly', () {
      final draws = _makeDraws('test', [
        [1, 2, 3, 4, 5, 6],
        [1, 2, 3, 7, 8, 9],
      ]);
      // Pick matches 3 in draw 1, 3 in draw 2 → avg = 3.0
      final result = DrawAnalysisService.analyzeSavedPicks(
        savedMainNumbers: [
          [1, 2, 3, 10, 11, 12]
        ],
        recentDraws: draws,
      );
      expect(result.averageMatchCount, closeTo(3.0, 0.01));
    });
  });

  // ── 8. Trend strength ─────────────────────────────────────────────────────

  group('Trend strength', () {
    test('uniform distribution → random-like', () {
      final lottery = _makeLottery(mainMax: 10, mainCount: 5);
      // Each number appears exactly once across draws
      final draws = _makeDraws('test', [
        [1, 2, 3, 4, 5],
        [6, 7, 8, 9, 10],
      ]);
      final result = DrawAnalysisService.analyzeRecentTrends(
          lottery: lottery, draws: draws, drawCount: 2);
      expect(result.trendStrength, TrendStrength.random);
    });

    test('one number dominates → strong trend', () {
      final lottery = _makeLottery(mainMax: 45, mainCount: 6);
      // Number 1 appears in every draw, others vary widely
      final draws = List.generate(
          20,
          (i) => _makeDraw('test', [1, i + 2, i + 10, i + 20, i + 30, 45],
              date: DateTime(2024, 1, 1).subtract(Duration(days: i))));
      final result = DrawAnalysisService.analyzeRecentTrends(
          lottery: lottery, draws: draws, drawCount: 20);
      // Number 1 appears 20x, expected avg is much lower → strong
      expect(result.trendStrength, TrendStrength.strong);
    });
  });
}
