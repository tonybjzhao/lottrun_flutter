class LotteryDraw {
  final String lotteryId;
  final DateTime drawDate;
  final List<int> mainNumbers;
  final List<int>? bonusNumbers;

  const LotteryDraw({
    required this.lotteryId,
    required this.drawDate,
    required this.mainNumbers,
    this.bonusNumbers,
  });
}
