import 'lottery_draw.dart';

enum LotteryHistorySource { network, cache }

class LotteryHistoryResult {
  final List<LotteryDraw> draws;
  final LotteryHistorySource source;
  final DateTime? loadedAt;

  const LotteryHistoryResult({
    required this.draws,
    required this.source,
    this.loadedAt,
  });
}
