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

  String get descriptionZh {
    switch (this) {
      case PlayStyle.balanced:
        return '号码均匀分布在各区间';
      case PlayStyle.hot:
        return '偏向近期高频出现的号码';
      case PlayStyle.cold:
        return '偏向长期未出现的号码';
      case PlayStyle.random:
        return '完全随机生成';
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
