import '../models/generated_pick.dart';
import '../models/lottery_draw.dart';

class PickMatchResult {
  final bool isPending;
  final int matchedMain;
  final int matchedBonus;

  const PickMatchResult({
    required this.isPending,
    required this.matchedMain,
    required this.matchedBonus,
  });

  static const pending = PickMatchResult(
    isPending: true,
    matchedMain: 0,
    matchedBonus: 0,
  );

  String summary(String lotteryId) {
    if (isPending) return '';
    final bonusPart = matchedBonus > 0
        ? switch (lotteryId) {
            'us_powerball'    => ' + PB',
            'us_megamillions' => ' + MB',
            'au_powerball'    => ' + PB',
            _                 => ' + bonus',
          }
        : '';
    if (matchedMain == 0 && matchedBonus == 0) return 'No match';
    return 'Matched $matchedMain$bonusPart';
  }
}

/// Returns null if the pick has no draw context (legacy pick).
/// Returns [PickMatchResult.pending] if the draw hasn't happened yet.
/// Returns match counts once the draw result is found.
PickMatchResult? checkPickResult(GeneratedPick pick, List<LotteryDraw> draws) {
  if (pick.drawDate == null) return null;
  final target = pick.drawDate!;
  final draw = draws.where((d) =>
    d.drawDate.year == target.year &&
    d.drawDate.month == target.month &&
    d.drawDate.day == target.day,
  ).firstOrNull;

  if (draw == null) return PickMatchResult.pending;

  final matchedMain = pick.mainNumbers
      .where((n) => draw.mainNumbers.contains(n))
      .length;
  final matchedBonus =
      (pick.bonusNumbers != null && draw.bonusNumbers != null)
          ? pick.bonusNumbers!.where((n) => draw.bonusNumbers!.contains(n)).length
          : 0;

  return PickMatchResult(
    isPending: false,
    matchedMain: matchedMain,
    matchedBonus: matchedBonus,
  );
}
