import '../models/generated_pick.dart';
import '../models/lottery_draw.dart';

/// Saturday Lotto and Oz Lotto — player picks only main numbers; the draw
/// also reveals supplementary numbers that count toward lower prize divisions.
bool _isSupplementaryLottery(String lotteryId) =>
    lotteryId == 'au_saturday' || lotteryId == 'au_ozlotto';

class PickMatchResult {
  final bool isPending;

  /// pick.mainNumbers ∩ draw.mainNumbers
  final int matchedMain;
  final List<int> matchedMainNumbers;

  /// pick.mainNumbers ∩ draw.bonusNumbers (supp lotteries only)
  /// e.g. one of the player's 6 picks appeared in the draw's supp pool.
  final List<int> matchedMainInDrawSupp;

  /// pick.bonusNumbers ∩ draw.bonusNumbers
  final int matchedBonus;
  final List<int> matchedBonusNumbers;

  /// pick.bonusNumbers ∩ draw.mainNumbers
  /// The player's bonus pick happened to match a main draw number.
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
  /// Supp hits and cross-pool bonus hits count but with lower weight.
  int get score =>
      matchedMain * 2 +
      suppHits +
      matchedBonus * 2 +
      matchedBonusInDrawMain.length;

  String _bonusLabel(String lotteryId) => switch (lotteryId) {
        'us_powerball'    => 'PB',
        'us_megamillions' => 'MB',
        'au_powerball'    => 'PB',
        _                 => '+',
      };

  String emotionalText(String lotteryId) {
    if (isPending) return '';

    if (_isSupplementaryLottery(lotteryId)) {
      return _emotionalTextSupp();
    }

    // Powerball / inline-bonus lotteries
    final hasBonus = matchedBonus > 0;
    final bp = hasBonus ? ' + ${_bonusLabel(lotteryId)}' : '';
    return switch (matchedMain) {
      0 when !hasBonus => 'No match this time — luck is building 🤞',
      0                => '${_bonusLabel(lotteryId)} matched! — keep going 🙌',
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

  String _emotionalTextSupp() {
    final m = matchedMain;
    final s = suppHits;
    final bonusPickHit = matchedBonus > 0 || matchedBonusInDrawMain.isNotEmpty;

    if (m == 0 && s == 0 && !bonusPickHit) {
      return 'No match this time — luck is building 🤞';
    }

    final parts = <String>[];
    if (m > 0) parts.add('$m main');
    if (s > 0) parts.add('$s supp');
    final hit = parts.join(' + ');

    if (m >= 5 && s >= 1) return '🏆 Division 2! $hit matched!';
    if (m >= 5) return '🔥 Division 3! $m main matched!';
    if (m >= 4) return '😮 So close — $hit matched!';
    if (m >= 3 && s >= 1) return '😮 $hit matched — almost!';
    if (m >= 3) return '3 main matched — almost! 🤞';
    if (hit.isNotEmpty) return '$hit matched — keep going 🙌';
    if (matchedBonus > 0) return 'Supp pick correct! — keep going 🙌';
    return 'Supp pick hit a draw number! 🎯';
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

  final drawMainSet = draw.mainNumbers.toSet();
  final drawSuppSet = draw.bonusNumbers?.toSet() ?? const <int>{};

  // pick.main vs draw.main
  final matchedMain = pick.mainNumbers.where(drawMainSet.contains).toList();

  // pick.main vs draw.supp (prize-relevant for Saturday/Oz Lotto)
  final matchedMainInDrawSupp = drawSuppSet.isNotEmpty
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
