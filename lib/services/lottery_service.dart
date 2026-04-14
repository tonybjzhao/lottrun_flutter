import '../data/seed_lotteries.dart';
import '../data/seed_oz_lotto.dart';
import '../data/seed_powerball.dart';
import '../data/seed_saturday_lotto.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';

class LotteryService {
  static final LotteryService _instance = LotteryService._();
  LotteryService._();
  static LotteryService get instance => _instance;

  List<Lottery> getLotteries() => kSeedLotteries;

  Lottery? getLotteryById(String id) {
    try {
      return kSeedLotteries.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns draws for the given lottery, newest first.
  List<LotteryDraw> getDraws(String lotteryId) {
    switch (lotteryId) {
      case 'au_powerball':
        return kPowerballDraws;
      case 'au_ozlotto':
        return kOzLottoDraws;
      case 'au_saturday':
        return kSaturdayLottoDraws;
      default:
        return [];
    }
  }

  /// Returns the most recent [limit] draws for frequency analysis.
  List<LotteryDraw> getRecentDraws(String lotteryId, {int limit = 50}) {
    final draws = getDraws(lotteryId);
    return draws.take(limit).toList();
  }
}
