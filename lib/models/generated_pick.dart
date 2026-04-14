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
