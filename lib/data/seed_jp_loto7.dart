import '../models/lottery_draw.dart';

const String kJpLoto7DrawsUpdatedAt = '2026-06-12';

/// Placeholder Japan Loto 7 draws - needs real data source
final List<LotteryDraw> kJpLoto7Draws = [
  LotteryDraw(lotteryId: 'jp_loto7', drawDate: DateTime(2024, 6, 7), mainNumbers: [3, 9, 14, 21, 28, 32, 35], bonusNumbers: [12, 25]),
  LotteryDraw(lotteryId: 'jp_loto7', drawDate: DateTime(2024, 5, 31), mainNumbers: [2, 8, 15, 19, 27, 31, 36], bonusNumbers: [10, 22]),
  LotteryDraw(lotteryId: 'jp_loto7', drawDate: DateTime(2024, 5, 24), mainNumbers: [5, 11, 17, 23, 29, 33, 37], bonusNumbers: [8, 19]),
];
