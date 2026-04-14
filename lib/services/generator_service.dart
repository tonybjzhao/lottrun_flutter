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
    final main = _generateMain(lottery, style, history);
    final bonus = lottery.hasBonus
        ? _generateBonus(lottery, style, history, exclude: main)
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
    List<LotteryDraw> history,
  ) {
    final allMain = history.map((d) => d.mainNumbers).toList();
    switch (style) {
      case PlayStyle.random:
        return _pickRandom(lottery.mainMin, lottery.mainMax, lottery.mainCount);
      case PlayStyle.hot:
        return _pickWeighted(
          lottery.mainMin, lottery.mainMax, lottery.mainCount, allMain,
          favourHigh: true,
        );
      case PlayStyle.cold:
        return _pickWeighted(
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

    List<int> result;
    switch (style) {
      case PlayStyle.random:
        result = _pickRandom(min, max, count, exclude: exclude);
      case PlayStyle.hot:
        result = allBonus.isEmpty
            ? _pickRandom(min, max, count, exclude: exclude)
            : _pickWeighted(min, max, count, allBonus,
                favourHigh: true, exclude: exclude);
      case PlayStyle.cold:
        result = allBonus.isEmpty
            ? _pickRandom(min, max, count, exclude: exclude)
            : _pickWeighted(min, max, count, allBonus,
                favourHigh: false, exclude: exclude);
      case PlayStyle.balanced:
        result = _pickRandom(min, max, count, exclude: exclude);
    }
    return result;
  }

  // ── Strategies ───────────────────────────────────────────────────────────

  List<int> _pickRandom(int min, int max, int count, {List<int> exclude = const []}) {
    final pool = [for (var i = min; i <= max; i++) i]
      ..removeWhere(exclude.contains)
      ..shuffle(_rng);
    return (pool.take(count).toList()..sort());
  }

  List<int> _pickWeighted(
    int min,
    int max,
    int count,
    List<List<int>> history, {
    required bool favourHigh,
    List<int> exclude = const [],
  }) {
    // Build frequency map
    final freq = {for (var i = min; i <= max; i++) i: 0};
    for (final draw in history) {
      for (final n in draw) {
        if (freq.containsKey(n)) freq[n] = freq[n]! + 1;
      }
    }
    freq.removeWhere((k, _) => exclude.contains(k));

    // Sort by frequency
    final sorted = freq.entries.toList()
      ..sort((a, b) => favourHigh
          ? b.value.compareTo(a.value)
          : a.value.compareTo(b.value));

    // Build weighted pool: rank 1 gets weight = sorted.length, last gets weight = 1
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

    // Fallback if pool was too small (shouldn't happen with valid lottery config)
    if (result.length < count) {
      final fallback = _pickRandom(min, max, count - result.length,
          exclude: [...exclude, ...result]);
      result.addAll(fallback);
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
        // bucket exhausted — fall back to any remaining number
        final fallback = _pickRandom(min, max, 1, exclude: result);
        result.addAll(fallback);
      } else {
        result.add(candidates[_rng.nextInt(candidates.length)]);
      }
    }
    return result..sort();
  }
}
