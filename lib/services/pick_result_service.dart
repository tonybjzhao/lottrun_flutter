import '../models/generated_pick.dart';
import '../models/lottery_draw.dart';

class PickMatchResult {
  final bool isPending;
  final int matchedMain;
  final int matchedBonus;
  final List<int> matchedMainNumbers;    // exact pick numbers that matched
  final List<int> matchedBonusNumbers;   // exact bonus numbers that matched
  final List<int> drawMainNumbers;       // actual draw result (for display)
  final List<int>? drawBonusNumbers;     // actual draw bonus (for display)
  final DateTime? drawDate;              // when the draw was held

  const PickMatchResult({
    required this.isPending,
    required this.matchedMain,
    required this.matchedBonus,
    this.matchedMainNumbers = const [],
    this.matchedBonusNumbers = const [],
    this.drawMainNumbers = const [],
    this.drawBonusNumbers,
    this.drawDate,
  });

  static const pending = PickMatchResult(
    isPending: true,
    matchedMain: 0,
    matchedBonus: 0,
  );

  /// Higher score = better pick. Used for "Best Pick" badge ranking.
  int get score => matchedMain * 2 + matchedBonus;

  String bonusLabel(String lotteryId) => switch (lotteryId) {
        'us_powerball'    => 'PB',
        'us_megamillions' => 'MB',
        'au_powerball'    => 'PB',
        _                 => '+',
      };

  String emotionalText(String lotteryId) {
    if (isPending) return '';
    final hasBonus = matchedBonus > 0;
    final bp = hasBonus ? ' + ${bonusLabel(lotteryId)}' : '';
    return switch (matchedMain) {
      0 when !hasBonus => 'No match this time — luck is building 🤞',
      0                => '${bonusLabel(lotteryId)} matched! — keep going 🙌',
      1 when !hasBonus => '1 matched — keep going 🙌',
      1                => '1$bp matched 😊',
      2                => '2$bp matched — almost! 🤞',
      3                => '😮 So close — 3$bp matched!',
      4                => '🔥 Wow — 4$bp matched!',
      _                => hasBonus
          ? '🏆 Incredible — $matchedMain + bonus matched!'
          : '🚀 Amazing — $matchedMain matched!',
    };
  }
}

/// Returns null if the pick has no draw context (legacy pick).
/// Returns [PickMatchResult.pending] if the draw result isn't in history yet.
/// Returns full match detail once the draw is found.
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
      .toList();
  final matchedBonus =
      (pick.bonusNumbers != null && draw.bonusNumbers != null)
          ? pick.bonusNumbers!
              .where((n) => draw.bonusNumbers!.contains(n))
              .toList()
          : <int>[];

  return PickMatchResult(
    isPending: false,
    matchedMain: matchedMain.length,
    matchedBonus: matchedBonus.length,
    matchedMainNumbers: matchedMain,
    matchedBonusNumbers: matchedBonus,
    drawMainNumbers: draw.mainNumbers,
    drawBonusNumbers: draw.bonusNumbers,
    drawDate: draw.drawDate,
  );
}
