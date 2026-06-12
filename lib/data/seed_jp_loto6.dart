import '../models/lottery_draw.dart';

const String kJpLoto6DrawsUpdatedAt = '2026-06-12';

/// Placeholder Japan Loto 6 draws - needs real data source
final List<LotteryDraw> kJpLoto6Draws = [
  LotteryDraw(lotteryId: 'jp_loto6', drawDate: DateTime(2024, 6, 10), mainNumbers: [2, 15, 22, 28, 35, 41], bonusNumbers: [18]),
  LotteryDraw(lotteryId: 'jp_loto6', drawDate: DateTime(2024, 6, 6), mainNumbers: [5, 12, 19, 27, 33, 40], bonusNumbers: [14]),
  LotteryDraw(lotteryId: 'jp_loto6', drawDate: DateTime(2024, 6, 3), mainNumbers: [8, 16, 23, 31, 36, 42], bonusNumbers: [25]),
];
