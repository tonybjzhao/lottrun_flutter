import 'dart:math';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';

class GeneratorService {
  static final GeneratorService _instance = GeneratorService._();
  GeneratorService._();
  static GeneratorService get instance => _instance;

  final _rng = Random();

  GeneratedPick generate({
    required Lottery lottery,
    required PlayStyle style,
    required List<LotteryDraw> history,
  }) {
    // Sort newest-first so recency weights are applied correctly.
    final sorted = [...history]
      ..sort((a, b) => b.drawDate.compareTo(a.drawDate));

    final main = _generateMain(lottery, style, sorted);
    final bonus = lottery.hasBonus
        ? _generateBonus(lottery, style, sorted, exclude: main)
        : null;
    return GeneratedPick(
      lotteryId: lottery.id,
      style: style,
      mainNumbers: main,
      bonusNumbers: bonus,
      createdAt: DateTime.now(),
    );
  }

  // ── Main numbers ─────────────────────────────────────────────────────────

  List<int> _generateMain(
    Lottery lottery,
    PlayStyle style,
    List<LotteryDraw> history, // newest-first
  ) {
    final allMain = history.map((d) => d.mainNumbers).toList();
    switch (style) {
      case PlayStyle.random:
        return _pickRandom(lottery.mainMin, lottery.mainMax, lottery.mainCount);
      case PlayStyle.hot:
        return _pickByScore(
          lottery.mainMin, lottery.mainMax, lottery.mainCount, allMain,
          favourHigh: true,
        );
      case PlayStyle.cold:
        return _pickByScore(
          lottery.mainMin, lottery.mainMax, lottery.mainCount, allMain,
          favourHigh: false,
        );
      case PlayStyle.balanced:
        return _pickBalanced(lottery.mainMin, lottery.mainMax, lottery.mainCount);
    }
  }

  // ── Bonus numbers ────────────────────────────────────────────────────────

  List<int> _generateBonus(
    Lottery lottery,
    PlayStyle style,
    List<LotteryDraw> history, {
    required List<int> exclude,
  }) {
    final allBonus = history
        .where((d) => d.bonusNumbers != null)
        .map((d) => d.bonusNumbers!)
        .toList();
    final count = lottery.bonusCount!;
    final min = lottery.bonusMin!;
    final max = lottery.bonusMax!;

    switch (style) {
      case PlayStyle.random:
        return _pickRandom(min, max, count, exclude: exclude);
      case PlayStyle.hot:
        return allBonus.isEmpty
            ? _pickRandom(min, max, count, exclude: exclude)
            : _pickByScore(min, max, count, allBonus,
                favourHigh: true, exclude: exclude);
      case PlayStyle.cold:
        return allBonus.isEmpty
            ? _pickRandom(min, max, count, exclude: exclude)
            : _pickByScore(min, max, count, allBonus,
                favourHigh: false, exclude: exclude);
      case PlayStyle.balanced:
        return _pickRandom(min, max, count, exclude: exclude);
    }
  }

  // ── Recency-weighted scoring ──────────────────────────────────────────────
  //
  // Draws are already sorted newest-first.
  // Window tiers:
  //   index  0–11  → 70% of total signal  ("recent trend")
  //   index 12–51  → 20%                  ("medium term")
  //   index 52+    → 10%                  ("background")
  //
  // Each draw within its tier contributes equally to that tier's share.

  Map<int, double> _scoreNumbers(
    int min,
    int max,
    List<List<int>> history, // newest-first
  ) {
    final scores = {for (var i = min; i <= max; i++) i: 0.0};
    if (history.isEmpty) return scores;

    final n1 = history.length.clamp(0, 12);
    final n2 = (history.length - 12).clamp(0, 40);
    final n3 = (history.length - 52).clamp(0, history.length);

    for (var i = 0; i < history.length; i++) {
      final double w;
      if (i < 12) {
        w = n1 > 0 ? 0.70 / n1 : 0.0;
      } else if (i < 52) {
        w = n2 > 0 ? 0.20 / n2 : 0.0;
      } else {
        w = n3 > 0 ? 0.10 / n3 : 0.0;
      }
      for (final n in history[i]) {
        if (scores.containsKey(n)) scores[n] = scores[n]! + w;
      }
    }
    return scores;
  }

  // ── Strategies ───────────────────────────────────────────────────────────

  List<int> _pickRandom(int min, int max, int count,
      {List<int> exclude = const []}) {
    final pool = [for (var i = min; i <= max; i++) i]
      ..removeWhere(exclude.contains)
      ..shuffle(_rng);
    return (pool.take(count).toList()..sort());
  }

  /// Pick numbers biased by recency-weighted score.
  /// [favourHigh]=true → hot (high scores preferred);
  /// [favourHigh]=false → cold (low scores preferred).
  List<int> _pickByScore(
    int min,
    int max,
    int count,
    List<List<int>> history, {
    required bool favourHigh,
    List<int> exclude = const [],
  }) {
    final scores = _scoreNumbers(min, max, history);
    scores.removeWhere((k, _) => exclude.contains(k));

    // Sort: hot wants highest scores first, cold wants lowest
    final sorted = scores.entries.toList()
      ..sort((a, b) => favourHigh
          ? b.value.compareTo(a.value)
          : a.value.compareTo(b.value));

    // Build weighted pool: rank 1 gets weight = sorted.length, last gets 1.
    // This gives a soft bias — even rank-1 can lose to a lucky lower-rank pick.
    final pool = <int>[];
    for (var i = 0; i < sorted.length; i++) {
      final weight = sorted.length - i;
      for (var w = 0; w < weight; w++) {
        pool.add(sorted[i].key);
      }
    }
    pool.shuffle(_rng);

    final result = <int>[];
    for (final n in pool) {
      if (!result.contains(n)) {
        result.add(n);
        if (result.length == count) break;
      }
    }

    if (result.length < count) {
      result.addAll(_pickRandom(min, max, count - result.length,
          exclude: [...exclude, ...result]));
    }
    return result..sort();
  }

  List<int> _pickBalanced(int min, int max, int count) {
    final range = max - min + 1;
    final bucketSize = range / count;
    final result = <int>[];

    for (var i = 0; i < count; i++) {
      final bucketMin = min + (i * bucketSize).round();
      final bucketMax = (i == count - 1)
          ? max
          : min + ((i + 1) * bucketSize).round() - 1;
      final candidates = [
        for (var n = bucketMin; n <= bucketMax; n++)
          if (!result.contains(n)) n,
      ];
      if (candidates.isEmpty) {
        result.addAll(_pickRandom(min, max, 1, exclude: result));
      } else {
        result.add(candidates[_rng.nextInt(candidates.length)]);
      }
    }
    return result..sort();
  }
}
