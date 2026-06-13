import '../data/seed_lotteries.dart';
import '../data/seed_oz_lotto.dart';
import '../data/seed_powerball.dart';
import '../data/seed_saturday_lotto.dart';
import '../data/seed_uk_lotteries.dart';
import '../data/seed_us_megamillions.dart';
import '../data/seed_us_powerball.dart';
import '../data/seed_canada_lotteries.dart';
import '../data/seed_de_lotto_6aus49.dart';
import '../data/seed_jp_loto6.dart';
import '../data/seed_jp_loto7.dart';
import '../data/seed_france_lotteries.dart';
import '../data/seed_shared_euromillions.dart';
import '../data/seed_shared_eurojackpot.dart';
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
  ///
  /// For multi-country lotteries (EuroMillions, EuroJackpot),
  /// returns the shared dataset regardless of country variant.
  List<LotteryDraw> getDraws(String lotteryId) {
    // Check if lottery uses shared dataset
    final lottery = getLotteryById(lotteryId);
    if (lottery?.sharedDatasetId != null) {
      return _getSharedDraws(lottery!.sharedDatasetId!);
    }

    // Fallback to country-specific datasets
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
      case 'ca_lotto_max':
        return kCaLottoMaxDraws;
      case 'ca_lotto_649':
        return kCaLotto649Draws;
      case 'de_lotto_6aus49':
        return kDeLotto6aus49Draws;
      case 'jp_loto6':
        return kJpLoto6Draws;
      case 'jp_loto7':
        return kJpLoto7Draws;
      case 'fr_loto':
        return kFrLotoDraws;
      default:
        return [];
    }
  }

  /// Returns shared dataset for multi-country lotteries
  List<LotteryDraw> _getSharedDraws(String datasetId) {
    switch (datasetId) {
      case 'euromillions':
        return kSharedEuroMillionsDraws;
      case 'eurojackpot':
        return kSharedEuroJackpotDraws;
      default:
        throw ArgumentError('Unknown shared dataset: $datasetId');
    }
  }

  /// Returns the most recent [limit] draws for frequency analysis.
  List<LotteryDraw> getRecentDraws(String lotteryId, {int limit = 50}) {
    final draws = getDraws(lotteryId);
    return draws.take(limit).toList();
  }
}
