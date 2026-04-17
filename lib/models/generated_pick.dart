enum PlayStyle {
  balanced,
  hot,
  cold,
  random;

  String get label {
    switch (this) {
      case PlayStyle.balanced:
        return 'Balanced';
      case PlayStyle.hot:
        return 'Hot';
      case PlayStyle.cold:
        return 'Cold';
      case PlayStyle.random:
        return 'Random';
    }
  }

  /// Short emotional headline shown on the result card.
  String get tagline {
    switch (this) {
      case PlayStyle.balanced:
        return '⚖️ Balanced Pick';
      case PlayStyle.hot:
        return '🔥 Hot Trend Pick';
      case PlayStyle.cold:
        return '❄️ Cold Comeback Pick';
      case PlayStyle.random:
        return '🎲 Pure Luck Pick';
    }
  }

  /// One-liner shown under the tagline.
  String get taglineSubtitle {
    switch (this) {
      case PlayStyle.balanced:
        return 'Even spread across all number ranges.';
      case PlayStyle.hot:
        return 'These numbers have been trending recently.';
      case PlayStyle.cold:
        return "These numbers haven't appeared in a while.";
      case PlayStyle.random:
        return 'Completely random — pure chance!';
    }
  }

  /// Stable lowercase_underscore value for analytics.
  /// Never change these once shipped — reports depend on them.
  String get analyticsName {
    switch (this) {
      case PlayStyle.balanced:
        return 'balanced';
      case PlayStyle.hot:
        return 'hot';
      case PlayStyle.cold:
        return 'cold';
      case PlayStyle.random:
        return 'random';
    }
  }

  String get description {
    switch (this) {
      case PlayStyle.balanced:
        return 'Even spread across the number range';
      case PlayStyle.hot:
        return 'Favors recently frequent numbers';
      case PlayStyle.cold:
        return 'Favors numbers overdue for a draw';
      case PlayStyle.random:
        return 'Pure random selection';
    }
  }
}

class GeneratedPick {
  final String id;
  final String lotteryId;
  final PlayStyle style;
  final List<int> mainNumbers;
  final List<int>? bonusNumbers;
  final DateTime createdAt;
  final String? pickLabel;  // e.g. "⭐ Best AI Pick" — set when saved from 3-picks
  final DateTime? drawDate; // UTC date of the targeted draw
  final String? drawLabel;  // e.g. "Thu 17 Apr"

  GeneratedPick({
    String? id,
    required this.lotteryId,
    required this.style,
    required this.mainNumbers,
    this.bonusNumbers,
    required this.createdAt,
    this.pickLabel,
    this.drawDate,
    this.drawLabel,
  }) : id = id ?? '${createdAt.millisecondsSinceEpoch}_${lotteryId.hashCode.abs()}';

  String get countryCode {
    if (lotteryId.startsWith('us_')) return 'US';
    if (lotteryId.startsWith('au_')) return 'AU';
    return 'OTHER';
  }

  String get displayLabel => pickLabel ?? style.tagline;
}
