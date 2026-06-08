import 'package:flutter/widgets.dart';

import '../models/generated_pick.dart';
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
}
