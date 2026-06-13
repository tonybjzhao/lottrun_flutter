import 'package:flutter/widgets.dart';

import '../models/generated_pick.dart';
import '../models/lottery.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension L10nBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension PlayStyleL10n on AppLocalizations {
  String playStyleLabel(PlayStyle style) => switch (style) {
    PlayStyle.balanced => styleBalanced,
    PlayStyle.hot => styleObservedPattern,
    PlayStyle.cold => styleLessCommon,
    PlayStyle.random => styleRandom,
  };

  String playStyleTagline(PlayStyle style) => switch (style) {
    PlayStyle.balanced => styleBalancedTagline,
    PlayStyle.hot => styleHotTagline,
    PlayStyle.cold => styleColdTagline,
    PlayStyle.random => styleRandomTagline,
  };

  String playStyleSubtitle(PlayStyle style) => switch (style) {
    PlayStyle.balanced => styleBalancedSubtitle,
    PlayStyle.hot => styleHotSubtitle,
    PlayStyle.cold => styleColdSubtitle,
    PlayStyle.random => styleRandomSubtitle,
  };

  String playStyleDescription(PlayStyle style) => switch (style) {
    PlayStyle.balanced => styleBalancedDescription,
    PlayStyle.hot => styleHotDescription,
    PlayStyle.cold => styleColdDescription,
    PlayStyle.random => styleRandomDescription,
  };

  String matchLevelLabel(int total) => switch (total) {
    0 => noMatch,
    1 => levelLightHit,
    2 => levelNice,
    3 => levelSolid,
    4 => levelStrong,
    _ => levelGreat,
  };

  String shareTemplateLabelByName(String templateName) =>
      switch (templateName) {
        'fire' => shareTemplateFireLabel,
        'electric' => shareTemplateElectricLabel,
        _ => shareTemplateWarmLabel,
      };

  String shareTemplateDescriptionByName(String templateName) =>
      switch (templateName) {
        'fire' => shareTemplateFireDescription,
        'electric' => shareTemplateElectricDescription,
        _ => shareTemplateWarmDescription,
      };

  String countryNameForCode(String code) => switch (code) {
    'AU' => countryAustralia,
    'US' => countryUnitedStates,
    'GB' => countryUnitedKingdom,
    'CA' => countryCanada,
    'DE' => countryGermany,
    'JP' => countryJapan,
    'FR' => countryFrance,
    _ => countryOther,
  };

  String lotteryName(Lottery lottery) => switch (lottery.id) {
    'au_powerball' || 'us_powerball' => lotteryPowerball,
    'au_ozlotto' => lotteryOzLotto,
    'au_saturday' => lotterySaturdayLotto,
    'us_megamillions' => lotteryMegaMillions,
    'uk_lotto' => lotteryUkLotto,
    'uk_euromillions' => lotteryEuroMillions,
    'ca_lotto_max' => lotteryLottoMax,
    'ca_lotto_649' => lotteryLotto649,
    'de_lotto_6aus49' => lotteryLotto6aus49,
    'de_eurojackpot' => lotteryEuroJackpot,
    'jp_loto6' => lotteryLoto6,
    'jp_loto7' => lotteryLoto7,
    'fr_loto' => lotteryFranceLoto,
    'fr_euromillions' => lotteryFranceEuroMillions,
    _ => lottery.name,
  };

  String lotteryDisplayName(Lottery lottery) =>
      '${countryNameForCode(lottery.countryCode)} · ${lotteryName(lottery)}';

  String lotteryBonusLabel(Lottery lottery) => switch (lottery.id) {
    'au_powerball' || 'us_powerball' => bonusPowerball,
    'us_megamillions' => bonusMegaBall,
    'uk_euromillions' => bonusLuckyStars,
    'de_lotto_6aus49' => bonusSuperzahl,
    'de_eurojackpot' => bonusEuroNumbers,
    _ => lottery.bonusLabel ?? commonSupp,
  };
}
