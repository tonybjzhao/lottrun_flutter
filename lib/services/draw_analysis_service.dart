import '../models/lottery.dart';
import '../models/lottery_draw.dart';

// ── Output models ─────────────────────────────────────────────────────────────

class RecentDrawTrends {
  final int drawCount;
  final List<int> topFrequent;
  final List<int> bottomFrequent;
  final double averageSum;
  final String mostCommonOddEven;
  final String mostCommonLowHigh;
  final double avgConsecutivePairs;
  final int mostCommonConsecutiveCount;
  final TrendStrength trendStrength;
  final String summary;

  const RecentDrawTrends({
    required this.drawCount,
    required this.topFrequent,
    required this.bottomFrequent,
    required this.averageSum,
    required this.mostCommonOddEven,
    required this.mostCommonLowHigh,
    required this.avgConsecutivePairs,
    required this.mostCommonConsecutiveCount,
    required this.trendStrength,
    required this.summary,
  });
}

enum TrendStrength { strong, balanced, random }

class SavedPicksAnalysis {
  final String? bestMatchDrawDate;
  final int bestMatchCount;
  final double averageMatchCount;
  final List<int> frequentlyPickedNumbers;
  final List<int> recentlyAppearedNumbers;
  final String summary;

  const SavedPicksAnalysis({
    required this.bestMatchDrawDate,
    required this.bestMatchCount,
    required this.averageMatchCount,
    required this.frequentlyPickedNumbers,
    required this.recentlyAppearedNumbers,
    required this.summary,
  });
}

class HistoricalPatternMatch {
  final int historicalMatchScore;
  final int trendScore;
  final int hotColdAlignmentScore;
  final int oddEvenStructureScore;
  final int lowHighStructureScore;
  final int sumRangeScore;
  final int consecutiveScore;
  final int hotNumberCount;
  final int coldNumberCount;
  final int recentTrendMatchScore;
  final String oddEvenPattern;
  final String lowHighPattern;
  final String sumRangeLabel;
  final int consecutiveNumberCount;
  final List<SimilarDraw> similarPastDraws;
  final String summary;

  const HistoricalPatternMatch({
    required this.historicalMatchScore,
    required this.trendScore,
    required this.hotColdAlignmentScore,
    required this.oddEvenStructureScore,
    required this.lowHighStructureScore,
    required this.sumRangeScore,
    required this.consecutiveScore,
    required this.hotNumberCount,
    required this.coldNumberCount,
    required this.recentTrendMatchScore,
    required this.oddEvenPattern,
    required this.lowHighPattern,
    required this.sumRangeLabel,
    required this.consecutiveNumberCount,
    required this.similarPastDraws,
    required this.summary,
  });
}

class SimilarDraw {
  final LotteryDraw draw;
  final int sharedNumbers;
  final double similarityScore;

  const SimilarDraw({
    required this.draw,
    required this.sharedNumbers,
    required this.similarityScore,
  });
}

// ── Service ───────────────────────────────────────────────────────────────────

class DrawAnalysisService {
  const DrawAnalysisService._();

  // ── Phase 1: Recent Draw Trends ──────────────────────────────────────────

  static RecentDrawTrends analyzeRecentTrends({
    required Lottery lottery,
    required List<LotteryDraw> draws,
    required int drawCount,
  }) {
    final recent = draws.take(drawCount).toList();
    if (recent.isEmpty) {
      return const RecentDrawTrends(
        drawCount: 0,
        topFrequent: [],
        bottomFrequent: [],
        averageSum: 0,
        mostCommonOddEven: '—',
        mostCommonLowHigh: '—',
        avgConsecutivePairs: 0,
        mostCommonConsecutiveCount: 0,
        trendStrength: TrendStrength.random,
        summary: 'Not enough draw history for analysis.',
      );
    }

    final freq = _frequencyMap(recent);
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topFrequent = sorted.take(5).map((e) => e.key).toList();
    final bottomFrequent =
        sorted.reversed.take(5).map((e) => e.key).toList();

    final avgSum = recent
            .map((d) => d.mainNumbers.fold(0, (s, n) => s + n))
            .fold(0, (s, v) => s + v) /
        recent.length;

    final oddEvenPattern = _mostCommonOddEven(recent);
    final lowHighPattern =
        _mostCommonLowHigh(recent, lottery.mainMin, lottery.mainMax);

    final consecutiveCounts =
        recent.map((d) => _consecutivePairs(d.mainNumbers)).toList();
    final avgConsec =
        consecutiveCounts.fold(0, (s, v) => s + v) / consecutiveCounts.length;
    final mostCommonConsec = _mode(consecutiveCounts);

    final strength = _trendStrength(freq, recent.length, lottery.mainCount);

    final summary =
        _recentTrendSummary(strength, topFrequent, lottery.mainMin, lottery.mainMax);

    return RecentDrawTrends(
      drawCount: recent.length,
      topFrequent: topFrequent,
      bottomFrequent: bottomFrequent,
      averageSum: avgSum,
      mostCommonOddEven: oddEvenPattern,
      mostCommonLowHigh: lowHighPattern,
      avgConsecutivePairs: avgConsec,
      mostCommonConsecutiveCount: mostCommonConsec,
      trendStrength: strength,
      summary: summary,
    );
  }

  // ── Phase 2: Saved Picks Analysis ────────────────────────────────────────

  static SavedPicksAnalysis analyzeSavedPicks({
    required List<List<int>> savedMainNumbers,
    required List<LotteryDraw> recentDraws,
    int compareDrawCount = 20,
  }) {
    final draws = recentDraws.take(compareDrawCount).toList();

    if (savedMainNumbers.isEmpty || draws.isEmpty) {
      return const SavedPicksAnalysis(
        bestMatchDrawDate: null,
        bestMatchCount: 0,
        averageMatchCount: 0,
        frequentlyPickedNumbers: [],
        recentlyAppearedNumbers: [],
        summary: 'No saved picks or draw history to compare.',
      );
    }

    String? bestDate;
    int bestCount = 0;
    int totalMatches = 0;
    int comparisons = 0;

    for (final pick in savedMainNumbers) {
      final pickSet = pick.toSet();
      for (final draw in draws) {
        final matched = pickSet.intersection(draw.mainNumbers.toSet()).length;
        totalMatches += matched;
        comparisons++;
        if (matched > bestCount) {
          bestCount = matched;
          bestDate = draw.drawDate.toIso8601String();
        }
      }
    }

    final avgMatch = comparisons > 0 ? totalMatches / comparisons : 0.0;

    final pickFreq = <int, int>{};
    for (final pick in savedMainNumbers) {
      for (final n in pick) {
        pickFreq[n] = (pickFreq[n] ?? 0) + 1;
      }
    }
    final sortedPick = pickFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final frequentPicked = sortedPick.take(5).map((e) => e.key).toList();

    final recentDrawNumbers = draws.expand((d) => d.mainNumbers).toSet();
    final allSavedNumbers = savedMainNumbers.expand((p) => p).toSet();
    final recentlyAppeared =
        allSavedNumbers.intersection(recentDrawNumbers).toList()..sort();

    final summary = _savedPicksSummary(avgMatch, recentlyAppeared.length);

    return SavedPicksAnalysis(
      bestMatchDrawDate: bestDate,
      bestMatchCount: bestCount,
      averageMatchCount: avgMatch,
      frequentlyPickedNumbers: frequentPicked,
      recentlyAppearedNumbers: recentlyAppeared,
      summary: summary,
    );
  }

  // ── Phase 3: Historical Pattern Match ────────────────────────────────────

  static const int _minHistoryRequired = 52;

  /// Returns null if insufficient history (< 52 draws).
  static HistoricalPatternMatch? analyzeHistoricalPattern({
    required Lottery lottery,
    required LotteryDraw targetDraw,
    required List<LotteryDraw> allDraws,
    int similarDrawsLimit = 3,
  }) {
    final cutoff = targetDraw.drawDate.subtract(const Duration(days: 365 * 5));
    final history = allDraws
        .where((d) =>
            d.lotteryId == targetDraw.lotteryId &&
            d.drawDate.isBefore(targetDraw.drawDate) &&
            d.drawDate.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.drawDate.compareTo(a.drawDate));

    if (history.length < _minHistoryRequired) return null;

    final main = targetDraw.mainNumbers;
    final midpoint = (lottery.mainMin + lottery.mainMax) / 2;

    final trend = _calcTrendScore(main, history, lottery);
    final hotCold = _calcHotColdScore(main, history, lottery);
    final oddEven = _calcOddEvenScore(main, history);
    final lowHigh = _calcLowHighScore(main, history, midpoint);
    final sumRange = _calcSumRangeScore(main, history);
    final consec = _calcConsecutiveScore(main, history);

    final rawScore = 0.35 * trend +
        0.25 * hotCold +
        0.15 * oddEven +
        0.10 * lowHigh +
        0.10 * sumRange +
        0.05 * consec;

    final finalScore = rawScore.round().clamp(0, 100);

    final longTermFreq = _frequencyMap(history);
    final allNums = List.generate(
        lottery.mainMax - lottery.mainMin + 1, (i) => lottery.mainMin + i);
    final sortedByFreq = allNums.toList()
      ..sort((a, b) =>
          (longTermFreq[b] ?? 0).compareTo(longTermFreq[a] ?? 0));
    final hotThreshold = (allNums.length * 0.25).ceil();
    final coldThreshold = (allNums.length * 0.75).floor();
    final hotSet = sortedByFreq.take(hotThreshold).toSet();
    final coldSet = sortedByFreq.skip(coldThreshold).toSet();

    final hotCount = main.where(hotSet.contains).length;
    final coldCount = main.where(coldSet.contains).length;

    final oddCount = main.where((n) => n.isOdd).length;
    final evenCount = main.length - oddCount;
    final lowCount = main.where((n) => n <= midpoint).length;
    final highCount = main.length - lowCount;
    final consecCount = _consecutivePairs(main);

    final currentSum = main.fold(0, (s, n) => s + n);
    final historicalSums = history
        .map((d) => d.mainNumbers.fold(0, (s, n) => s + n))
        .toList()
      ..sort();
    final sumLabel = _sumRangeLabel(currentSum, historicalSums);

    final similar =
        _findSimilarDraws(targetDraw, history, midpoint, similarDrawsLimit);

    final summary = _historicalSummary(finalScore);

    return HistoricalPatternMatch(
      historicalMatchScore: finalScore,
      trendScore: trend.round().clamp(0, 100),
      hotColdAlignmentScore: hotCold.round().clamp(0, 100),
      oddEvenStructureScore: oddEven.round().clamp(0, 100),
      lowHighStructureScore: lowHigh.round().clamp(0, 100),
      sumRangeScore: sumRange.round().clamp(0, 100),
      consecutiveScore: consec.round().clamp(0, 100),
      hotNumberCount: hotCount,
      coldNumberCount: coldCount,
      recentTrendMatchScore: trend.round().clamp(0, 100),
      oddEvenPattern: '$oddCount odd / $evenCount even',
      lowHighPattern: '$lowCount low / $highCount high',
      sumRangeLabel: sumLabel,
      consecutiveNumberCount: consecCount,
      similarPastDraws: similar,
      summary: summary,
    );
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  static Map<int, int> _frequencyMap(List<LotteryDraw> draws) {
    final map = <int, int>{};
    for (final d in draws) {
      for (final n in d.mainNumbers) {
        map[n] = (map[n] ?? 0) + 1;
      }
    }
    return map;
  }

  static int _consecutivePairs(List<int> numbers) {
    final sorted = [...numbers]..sort();
    int count = 0;
    for (int i = 0; i < sorted.length - 1; i++) {
      if (sorted[i + 1] - sorted[i] == 1) count++;
    }
    return count;
  }

  static int _mode(List<int> values) {
    if (values.isEmpty) return 0;
    final freq = <int, int>{};
    for (final v in values) {
      freq[v] = (freq[v] ?? 0) + 1;
    }
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static String _mostCommonOddEven(List<LotteryDraw> draws) {
    final freq = <String, int>{};
    for (final d in draws) {
      final odd = d.mainNumbers.where((n) => n.isOdd).length;
      final even = d.mainNumbers.length - odd;
      final key = '$odd odd / $even even';
      freq[key] = (freq[key] ?? 0) + 1;
    }
    if (freq.isEmpty) return '—';
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static String _mostCommonLowHigh(
      List<LotteryDraw> draws, int minVal, int maxVal) {
    final midpoint = (minVal + maxVal) / 2;
    final freq = <String, int>{};
    for (final d in draws) {
      final low = d.mainNumbers.where((n) => n <= midpoint).length;
      final high = d.mainNumbers.length - low;
      final key = '$low low / $high high';
      freq[key] = (freq[key] ?? 0) + 1;
    }
    if (freq.isEmpty) return '—';
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static TrendStrength _trendStrength(
      Map<int, int> freq, int drawCount, int mainCount) {
    if (freq.isEmpty || drawCount == 0) return TrendStrength.random;
    final totalAppearances = drawCount * mainCount;
    final uniqueNumbers = freq.length;
    final expectedAvg =
        uniqueNumbers > 0 ? totalAppearances / uniqueNumbers : 1.0;
    final maxFreq = freq.values.reduce((a, b) => a > b ? a : b).toDouble();
    final ratio = maxFreq / expectedAvg;
    if (ratio >= 2.0) return TrendStrength.strong;
    if (ratio >= 1.4) return TrendStrength.balanced;
    return TrendStrength.random;
  }

  // ── Phase 3 score components ──────────────────────────────────────────────

  static double _calcTrendScore(
      List<int> main, List<LotteryDraw> history, Lottery lottery) {
    final weightedFreq = <int, double>{};
    for (int i = 0; i < history.length; i++) {
      final weight = i < 12 ? 0.6 : (i < 52 ? 0.3 : 0.1);
      for (final n in history[i].mainNumbers) {
        weightedFreq[n] = (weightedFreq[n] ?? 0) + weight;
      }
    }
    if (weightedFreq.isEmpty) return 50;

    final minW = weightedFreq.values.reduce((a, b) => a < b ? a : b);
    final maxW = weightedFreq.values.reduce((a, b) => a > b ? a : b);
    final range = maxW - minW;
    if (range == 0) return 50;

    double total = 0;
    for (final n in main) {
      final w = weightedFreq[n] ?? 0;
      total += (w - minW) / range;
    }
    return (total / main.length * 100).clamp(0, 100);
  }

  static double _calcHotColdScore(
      List<int> main, List<LotteryDraw> history, Lottery lottery) {
    final freq = _frequencyMap(history);
    final allNums = List.generate(
        lottery.mainMax - lottery.mainMin + 1, (i) => lottery.mainMin + i);
    final sorted = allNums.toList()
      ..sort((a, b) => (freq[b] ?? 0).compareTo(freq[a] ?? 0));
    final hotThreshold = (allNums.length * 0.25).ceil();
    final coldThreshold = (allNums.length * 0.75).floor();
    final hotSet = sorted.take(hotThreshold).toSet();
    final coldSet = sorted.skip(coldThreshold).toSet();

    double total = 0;
    for (final n in main) {
      if (hotSet.contains(n)) {
        total += 100;
      } else if (coldSet.contains(n)) {
        total += 40;
      } else {
        total += 60;
      }
    }
    return (total / main.length).clamp(0, 100);
  }

  static double _calcOddEvenScore(
      List<int> main, List<LotteryDraw> history) {
    final currentOdd = main.where((n) => n.isOdd).length;
    final mostCommon = _mostCommonOddEvenCount(history);
    final diff = (currentOdd - mostCommon).abs();
    if (diff == 0) return 100;
    if (diff == 1) return 75;
    if (diff == 2) return 50;
    return 25;
  }

  static int _mostCommonOddEvenCount(List<LotteryDraw> draws) {
    final freq = <int, int>{};
    for (final d in draws) {
      final odd = d.mainNumbers.where((n) => n.isOdd).length;
      freq[odd] = (freq[odd] ?? 0) + 1;
    }
    if (freq.isEmpty) return 0;
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static double _calcLowHighScore(
      List<int> main, List<LotteryDraw> history, double midpoint) {
    final currentLow = main.where((n) => n <= midpoint).length;
    final mostCommon = _mostCommonLowCount(history, midpoint);
    final diff = (currentLow - mostCommon).abs();
    if (diff == 0) return 100;
    if (diff == 1) return 75;
    if (diff == 2) return 50;
    return 25;
  }

  static int _mostCommonLowCount(List<LotteryDraw> draws, double midpoint) {
    final freq = <int, int>{};
    for (final d in draws) {
      final low = d.mainNumbers.where((n) => n <= midpoint).length;
      freq[low] = (freq[low] ?? 0) + 1;
    }
    if (freq.isEmpty) return 0;
    return freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static double _calcSumRangeScore(
      List<int> main, List<LotteryDraw> history) {
    final currentSum = main.fold(0, (s, n) => s + n);
    final sums = history
        .map((d) => d.mainNumbers.fold(0, (s, n) => s + n))
        .toList()
      ..sort();
    if (sums.isEmpty) return 50;

    final p10 = sums[((sums.length - 1) * 0.10).round()];
    final p25 = sums[((sums.length - 1) * 0.25).round()];
    final p75 = sums[((sums.length - 1) * 0.75).round()];
    final p90 = sums[((sums.length - 1) * 0.90).round()];

    if (currentSum >= p25 && currentSum <= p75) return 100;
    if (currentSum >= p10 && currentSum <= p90) return 75;
    if (currentSum >= sums.first && currentSum <= sums.last) return 50;
    return 25;
  }

  static double _calcConsecutiveScore(
      List<int> main, List<LotteryDraw> history) {
    final currentConsec = _consecutivePairs(main);
    final mostCommon = _mode(
        history.map((d) => _consecutivePairs(d.mainNumbers)).toList());
    final diff = (currentConsec - mostCommon).abs();
    if (diff == 0) return 100;
    if (diff == 1) return 70;
    return 40;
  }

  static String _sumRangeLabel(int sum, List<int> sortedSums) {
    if (sortedSums.isEmpty) return 'Unknown';
    final p25 = sortedSums[((sortedSums.length - 1) * 0.25).round()];
    final p75 = sortedSums[((sortedSums.length - 1) * 0.75).round()];
    if (sum < p25) return 'Below typical range';
    if (sum > p75) return 'Above typical range';
    return 'Within typical range';
  }

  static List<SimilarDraw> _findSimilarDraws(
      LotteryDraw target, List<LotteryDraw> history, double midpoint,
      int limit) {
    final targetMain = target.mainNumbers.toSet();
    final targetOdd = target.mainNumbers.where((n) => n.isOdd).length;
    final targetLow = target.mainNumbers.where((n) => n <= midpoint).length;
    final targetSum = target.mainNumbers.fold(0, (s, n) => s + n);
    final targetConsec = _consecutivePairs(target.mainNumbers);
    final mainCount = target.mainNumbers.length;

    final scored = history.map((d) {
      final shared = targetMain.intersection(d.mainNumbers.toSet()).length;
      final dOdd = d.mainNumbers.where((n) => n.isOdd).length;
      final dLow = d.mainNumbers.where((n) => n <= midpoint).length;
      final dSum = d.mainNumbers.fold(0, (s, n) => s + n);
      final dConsec = _consecutivePairs(d.mainNumbers);

      final sharedScore = shared / mainCount;
      final oddScore = 1 - (targetOdd - dOdd).abs() / mainCount;
      final lowScore = 1 - (targetLow - dLow).abs() / mainCount;
      final sumScore = targetSum > 0
          ? 1 - (targetSum - dSum).abs() / targetSum.toDouble()
          : 0.5;
      final consecScore = targetConsec == dConsec ? 1.0 : 0.5;

      final similarity = (sharedScore * 0.4 +
              oddScore * 0.15 +
              lowScore * 0.15 +
              sumScore.clamp(0, 1) * 0.2 +
              consecScore * 0.1) *
          100;

      return SimilarDraw(
        draw: d,
        sharedNumbers: shared,
        similarityScore: similarity.clamp(0, 100),
      );
    }).toList()
      ..sort((a, b) => b.similarityScore.compareTo(a.similarityScore));

    return scored.take(limit).toList();
  }

  // ── Summary text generators ───────────────────────────────────────────────

  static String _recentTrendSummary(
      TrendStrength strength, List<int> topNums, int minVal, int maxVal) {
    final topInMid = topNums
        .where((n) =>
            n > minVal + (maxVal - minVal) * 0.25 &&
            n < maxVal - (maxVal - minVal) * 0.25)
        .length;

    switch (strength) {
      case TrendStrength.strong:
        return 'Recent draws show higher activity among a few numbers — a notable concentration in this period.';
      case TrendStrength.balanced:
        if (topInMid >= 3) {
          return 'This period shows higher activity among several mid-range numbers.';
        }
        return 'Recent draws are fairly balanced with a moderate spread across numbers.';
      case TrendStrength.random:
        return 'Recent draws are fairly balanced with no strong pattern detected.';
    }
  }

  static String _savedPicksSummary(
      double avgMatch, int recentlyAppearedCount) {
    if (avgMatch >= 2.5) {
      return 'Your saved picks have matched recent draws moderately.';
    }
    if (recentlyAppearedCount >= 3) {
      return 'Several numbers you saved appeared in recent results.';
    }
    return 'Your saved picks show limited overlap with recent draw results.';
  }

  static String _historicalSummary(int score) {
    if (score >= 70) {
      return 'This draw aligns well with historical patterns from the past 5 years.';
    }
    if (score >= 45) {
      return 'This draw shows moderate alignment with historical distribution patterns.';
    }
    return 'This draw shows limited alignment with typical historical patterns.';
  }
}
