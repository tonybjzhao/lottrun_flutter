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
  final String lotteryId;
  final PlayStyle style;
  final List<int> mainNumbers;
  final List<int>? bonusNumbers;
  final DateTime createdAt;

  const GeneratedPick({
    required this.lotteryId,
    required this.style,
    required this.mainNumbers,
    this.bonusNumbers,
    required this.createdAt,
  });
}
