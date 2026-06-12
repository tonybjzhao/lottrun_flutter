import '../l10n/generated/app_localizations_en.dart';
import '../models/lottery.dart';

final _l10n = AppLocalizationsEn();

final List<Lottery> kSeedLotteries = [
  // ── Australia ──────────────────────────────────────────────────────────────
  Lottery(
    id: 'au_powerball',
    countryCode: 'AU',
    countryName: _l10n.countryAustralia,
    name: _l10n.lotteryPowerball,
    mainCount: 7,
    mainMin: 1,
    mainMax: 35,
    bonusCount: 1,
    bonusMin: 1,
    bonusMax: 20,
    hasSeparateBonusPool: true,
    bonusLabel: _l10n.bonusPowerball,
  ),
  Lottery(
    id: 'au_ozlotto',
    countryCode: 'AU',
    countryName: _l10n.countryAustralia,
    name: _l10n.lotteryOzLotto,
    mainCount: 7,
    mainMin: 1,
    mainMax: 47,
    bonusCount: 3,
    bonusMin: 1,
    bonusMax: 47,
    // bonusLabel: null → supplementary style (Supp row)
  ),
  Lottery(
    id: 'au_saturday',
    countryCode: 'AU',
    countryName: _l10n.countryAustralia,
    name: _l10n.lotterySaturdayLotto,
    mainCount: 6,
    mainMin: 1,
    mainMax: 45,
    bonusCount: 2,
    bonusMin: 1,
    bonusMax: 45,
    // bonusLabel: null → supplementary style (Supp row)
  ),

  // ── United States ──────────────────────────────────────────────────────────
  Lottery(
    id: 'us_powerball',
    countryCode: 'US',
    countryName: _l10n.countryUnitedStates,
    name: _l10n.lotteryPowerball,
    mainCount: 5,
    mainMin: 1,
    mainMax: 69,
    bonusCount: 1,
    bonusMin: 1,
    bonusMax: 26,
    hasSeparateBonusPool: true,
    bonusLabel: _l10n.bonusPowerball,
  ),
  Lottery(
    id: 'us_megamillions',
    countryCode: 'US',
    countryName: _l10n.countryUnitedStates,
    name: _l10n.lotteryMegaMillions,
    mainCount: 5,
    mainMin: 1,
    mainMax: 70,
    bonusCount: 1,
    bonusMin: 1,
    bonusMax: 25,
    hasSeparateBonusPool: true,
    bonusLabel: _l10n.bonusMegaBall,
  ),

  // ── United Kingdom ────────────────────────────────────────────────────────
  Lottery(
    id: 'uk_lotto',
    countryCode: 'GB',
    countryName: _l10n.countryUnitedKingdom,
    name: _l10n.lotteryUkLotto,
    mainCount: 6,
    mainMin: 1,
    mainMax: 59,
    bonusCount: 1,
    bonusMin: 1,
    bonusMax: 59,
    drawRoundsPerTicket: 2,
    // bonusLabel: null → same-pool bonus ball, shown as supplementary.
  ),
  Lottery(
    id: 'uk_euromillions',
    countryCode: 'GB',
    countryName: _l10n.countryUnitedKingdom,
    name: _l10n.lotteryEuroMillions,
    mainCount: 5,
    mainMin: 1,
    mainMax: 50,
    bonusCount: 2,
    bonusMin: 1,
    bonusMax: 12,
    hasSeparateBonusPool: true,
    bonusLabel: _l10n.bonusLuckyStars,
  ),

  // ── Canada ────────────────────────────────────────────────────────────────
  Lottery(
    id: 'ca_lotto_max',
    countryCode: 'CA',
    countryName: _l10n.countryCanada,
    name: _l10n.lotteryLottoMax,
    mainCount: 7,
    mainMin: 1,
    mainMax: 52,
    bonusCount: 1,
    bonusMin: 1,
    bonusMax: 52,
    // bonusLabel: null → same-pool bonus number, shown as supplementary.
  ),
  Lottery(
    id: 'ca_lotto_649',
    countryCode: 'CA',
    countryName: _l10n.countryCanada,
    name: _l10n.lotteryLotto649,
    mainCount: 6,
    mainMin: 1,
    mainMax: 49,
    bonusCount: 1,
    bonusMin: 1,
    bonusMax: 49,
    // bonusLabel: null → same-pool bonus number, shown as supplementary.
  ),

  // ── Germany ───────────────────────────────────────────────────────────────
  Lottery(
    id: 'de_lotto_6aus49',
    countryCode: 'DE',
    countryName: _l10n.countryGermany,
    name: _l10n.lotteryLotto6aus49,
    mainCount: 6,
    mainMin: 1,
    mainMax: 49,
    bonusCount: 1,
    bonusMin: 0,
    bonusMax: 9,
    hasSeparateBonusPool: true,
    bonusLabel: _l10n.bonusSuperzahl,
  ),
  Lottery(
    id: 'de_eurojackpot',
    countryCode: 'DE',
    countryName: _l10n.countryGermany,
    name: _l10n.lotteryEuroJackpot,
    mainCount: 5,
    mainMin: 1,
    mainMax: 50,
    bonusCount: 2,
    bonusMin: 1,
    bonusMax: 12,
    hasSeparateBonusPool: true,
    bonusLabel: _l10n.bonusEuroNumbers,
  ),

  // ── Japan ─────────────────────────────────────────────────────────────────
  Lottery(
    id: 'jp_loto6',
    countryCode: 'JP',
    countryName: _l10n.countryJapan,
    name: _l10n.lotteryLoto6,
    mainCount: 6,
    mainMin: 1,
    mainMax: 43,
    bonusCount: 1,
    bonusMin: 1,
    bonusMax: 43,
    // bonusLabel: null → same-pool bonus number, shown as supplementary.
  ),
  Lottery(
    id: 'jp_loto7',
    countryCode: 'JP',
    countryName: _l10n.countryJapan,
    name: _l10n.lotteryLoto7,
    mainCount: 7,
    mainMin: 1,
    mainMax: 37,
    bonusCount: 2,
    bonusMin: 1,
    bonusMax: 37,
    // bonusLabel: null → same-pool bonus numbers, shown as supplementary.
  ),
];
