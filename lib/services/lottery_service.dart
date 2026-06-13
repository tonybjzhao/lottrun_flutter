import '../data/seed_lotteries.dart';
import '../data/seed_oz_lotto.dart';
import '../data/seed_powerball.dart';
import '../data/seed_saturday_lotto.dart';
import '../data/seed_uk_lotteries.dart';
import '../data/seed_us_megamillions.dart';
import '../data/seed_us_powerball.dart';
import '../data/seed_canada_lotteries.dart';
import '../data/seed_de_lotto_6aus49.dart';
import '../data/seed_de_eurojackpot.dart';
import '../data/seed_jp_loto6.dart';
import '../data/seed_jp_loto7.dart';
import '../data/seed_france_lotteries.dart';
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
      case 'us_powerball':
        return kUsPowerballDraws;
      case 'us_megamillions':
        return kUsMegaMillionsDraws;
      case 'uk_lotto':
        return kUkLottoDraws;
      case 'uk_euromillions':
        return kUkEuroMillionsDraws;
      case 'ca_lotto_max':
        return kCaLottoMaxDraws;
      case 'ca_lotto_649':
        return kCaLotto649Draws;
      case 'de_lotto_6aus49':
        return kDeLotto6aus49Draws;
      case 'de_eurojackpot':
        return kDeEuroJackpotDraws;
      case 'jp_loto6':
        return kJpLoto6Draws;
      case 'jp_loto7':
        return kJpLoto7Draws;
      case 'fr_loto':
        return kFrLotoDraws;
      case 'fr_euromillions':
        return kFrEuroMillionsDraws;
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
