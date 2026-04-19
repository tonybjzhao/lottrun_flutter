import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';

class PickMatchResult {
  final bool isPending;

  /// pick.mainNumbers ∩ draw.mainNumbers
  final int matchedMain;
  final List<int> matchedMainNumbers;

  /// pick.mainNumbers ∩ draw.bonusNumbers (supp lotteries only)
  final List<int> matchedMainInDrawSupp;

  /// pick.bonusNumbers ∩ draw.bonusNumbers
  final int matchedBonus;
  final List<int> matchedBonusNumbers;

  /// pick.bonusNumbers ∩ draw.mainNumbers
  final List<int> matchedBonusInDrawMain;

  final List<int> drawMainNumbers;
  final List<int>? drawBonusNumbers;
  final DateTime? drawDate;

  const PickMatchResult({
    required this.isPending,
    required this.matchedMain,
    required this.matchedBonus,
    this.matchedMainNumbers = const [],
    this.matchedMainInDrawSupp = const [],
    this.matchedBonusNumbers = const [],
    this.matchedBonusInDrawMain = const [],
    this.drawMainNumbers = const [],
    this.drawBonusNumbers,
    this.drawDate,
  });

  static const pending = PickMatchResult(
    isPending: true,
    matchedMain: 0,
    matchedBonus: 0,
  );

  int get suppHits => matchedMainInDrawSupp.length;

  /// Higher score = better pick. Used for "Best Pick" badge ranking.
  int get score =>
      matchedMain * 2 +
      suppHits +
      matchedBonus * 2 +
      matchedBonusInDrawMain.length;

  /// Total supp-category hits: pick.main∩draw.supp + pick.supp∩draw.main.
  int suppCategoryHits(Lottery lottery) => lottery.bonusIsSupplementary
      ? suppHits + matchedBonusInDrawMain.length
      : 0;

  /// Total effective matches for level calculation.
  int _levelTotal(Lottery lottery) =>
      matchedMain +
      (lottery.bonusIsSupplementary
          ? suppHits + matchedBonusInDrawMain.length
          : matchedBonus);

  /// Factual match summary — no prize or win language.
  /// e.g. "3 matched", "4 matched (incl. 1 supp)", "1 matched (supp)",
  ///      "No numbers matched", "4 matched + Powerball"
  String matchSummary(Lottery lottery) {
    if (isPending) return '';

    if (lottery.bonusIsSupplementary) {
      final totalSupp = suppCategoryHits(lottery);
      final total = matchedMain + totalSupp;
      if (total == 0) return 'No numbers matched';
      if (matchedMain == 0) return '$total matched (supp)';
      if (totalSupp == 0) return '$matchedMain matched';
      return '$total matched (incl. $totalSupp supp)';
    }

    // Powerball / inline-bonus lotteries
    final m = matchedMain;
    final b = matchedBonus > 0;
    final label = lottery.bonusLabel ?? '+';
    if (m == 0 && !b) return 'No numbers matched';
    if (m == 0) return '$label matched';
    if (!b) return '$m matched';
    return '$m matched + $label';
  }

  /// Gamification level label based on total effective matches.
  /// Uses neutral language — no prize implication.
  String levelLabel(Lottery lottery) {
    final total = _levelTotal(lottery);
    return switch (total) {
      0 => 'No match',
      1 => 'Light hit',
      2 => 'Nice',
      3 => 'Solid',
      4 => 'Strong',
      _ => 'Great',
    };
  }
}

/// Returns null if the pick has no draw context (legacy pick).
/// Returns [PickMatchResult.pending] if the draw result isn't in history yet.
/// Returns full match detail once the draw is found.
PickMatchResult? checkPickResult(
  GeneratedPick pick,
  Lottery lottery,
  List<LotteryDraw> draws,
) {
  if (pick.drawDate == null) return null;
  final target = pick.drawDate!;
  final draw = draws.where((d) =>
    d.drawDate.year == target.year &&
    d.drawDate.month == target.month &&
    d.drawDate.day == target.day,
  ).firstOrNull;

  if (draw == null) return PickMatchResult.pending;

  final drawMainSet = draw.mainNumbers.toSet();
  final drawSuppSet = draw.bonusNumbers?.toSet() ?? const <int>{};

  // pick.main vs draw.main
  final matchedMain = pick.mainNumbers.where(drawMainSet.contains).toList();

  // pick.main vs draw.supp — only prize-relevant for supplementary lotteries
  final matchedMainInDrawSupp = lottery.bonusIsSupplementary && drawSuppSet.isNotEmpty
      ? pick.mainNumbers.where(drawSuppSet.contains).toList()
      : <int>[];

  // pick.bonus vs draw.bonus
  final matchedBonus = (pick.bonusNumbers != null && drawSuppSet.isNotEmpty)
      ? pick.bonusNumbers!.where(drawSuppSet.contains).toList()
      : <int>[];

  // pick.bonus vs draw.main (bonus pick happened to hit a main draw number)
  final matchedBonusInDrawMain = pick.bonusNumbers != null
      ? pick.bonusNumbers!.where(drawMainSet.contains).toList()
      : <int>[];

  return PickMatchResult(
    isPending: false,
    matchedMain: matchedMain.length,
    matchedBonus: matchedBonus.length,
    matchedMainNumbers: matchedMain,
    matchedMainInDrawSupp: matchedMainInDrawSupp,
    matchedBonusNumbers: matchedBonus,
    matchedBonusInDrawMain: matchedBonusInDrawMain,
    drawMainNumbers: draw.mainNumbers,
    drawBonusNumbers: draw.bonusNumbers,
    drawDate: draw.drawDate,
  );
}
