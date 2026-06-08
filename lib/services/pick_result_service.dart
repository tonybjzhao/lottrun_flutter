import '../l10n/generated/app_localizations.dart';
import '../l10n/generated/app_localizations_en.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';

final _fallbackL10n = AppLocalizationsEn();

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
  String matchSummary(Lottery lottery, [AppLocalizations? localizations]) {
    if (isPending) return '';
    final l10n = localizations ?? _fallbackL10n;

    if (lottery.bonusIsSupplementary) {
      final totalSupp = suppCategoryHits(lottery);
      if (matchedMain == 0 && totalSupp == 0) return l10n.noMainMatched;
      if (matchedMain == 0) return l10n.noMainWithSupp(totalSupp);
      if (totalSupp == 0) return l10n.matchedCount(matchedMain);
      return l10n.matchedWithSupp(matchedMain, totalSupp);
    }

    // Powerball / inline-bonus lotteries
    final m = matchedMain;
    final b = matchedBonus > 0;
    final label = lottery.bonusLabel ?? l10n.commonBonus;
    if (m == 0 && !b) return l10n.noNumbersMatched;
    if (m == 0) return l10n.bonusMatched(label);
    if (!b) return l10n.matchedCount(m);
    return l10n.matchedCountWithBonus(m, label);
  }

  /// Gamification level label based on total effective matches.
  /// Uses neutral language — no prize implication.
  String levelLabel(Lottery lottery, [AppLocalizations? localizations]) {
    final l10n = localizations ?? _fallbackL10n;
    final total = _levelTotal(lottery);
    return switch (total) {
      0 => l10n.noMatch,
      1 => l10n.levelLightHit,
      2 => l10n.levelNice,
      3 => l10n.levelSolid,
      4 => l10n.levelStrong,
      _ => l10n.levelGreat,
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
  final draw = draws
      .where(
        (d) =>
            d.drawDate.year == target.year &&
            d.drawDate.month == target.month &&
            d.drawDate.day == target.day,
      )
      .firstOrNull;

  if (draw == null) return PickMatchResult.pending;

  final drawMainSet = draw.mainNumbers.toSet();
  final drawSuppSet = draw.bonusNumbers?.toSet() ?? const <int>{};

  // pick.main vs draw.main
  final matchedMain = pick.mainNumbers.where(drawMainSet.contains).toList();

  // pick.main vs draw.supp — only prize-relevant for supplementary lotteries
  final matchedMainInDrawSupp =
      lottery.bonusIsSupplementary && drawSuppSet.isNotEmpty
      ? pick.mainNumbers.where(drawSuppSet.contains).toList()
      : <int>[];

  // pick.bonus vs draw.bonus — only meaningful for non-supp lotteries (e.g. Powerball).
  // For supplementary lotteries (Saturday, Oz Lotto), bonus numbers are app-generated
  // and not real user selections — ignore them completely.
  final matchedBonus =
      (!lottery.bonusIsSupplementary &&
          pick.bonusNumbers != null &&
          drawSuppSet.isNotEmpty)
      ? pick.bonusNumbers!.where(drawSuppSet.contains).toList()
      : <int>[];

  // pick.bonus vs draw.main — same gate: supp lotteries skip this entirely.
  final matchedBonusInDrawMain =
      (!lottery.bonusIsSupplementary && pick.bonusNumbers != null)
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
