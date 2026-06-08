// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LottFun';

  @override
  String get brandTitle => 'NumberRun';

  @override
  String get brandSubtitle => 'Number sets from past records';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonShare => 'Share';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaved => 'Saved';

  @override
  String get commonLoad => 'Load';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonBonus => 'Bonus';

  @override
  String get commonSupp => 'Supp';

  @override
  String get commonView => 'View';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonGenerating => 'Generating…';

  @override
  String get commonPreparing => 'Preparing...';

  @override
  String get countryUnitedStates => 'United States';

  @override
  String get countryAustralia => 'Australia';

  @override
  String get countryUnitedKingdom => 'United Kingdom';

  @override
  String get countryCanada => 'Canada';

  @override
  String get countryGermany => 'Germany';

  @override
  String get countryOther => 'Other';

  @override
  String get lotteryPowerball => 'Powerball';

  @override
  String get lotteryOzLotto => 'Oz Lotto';

  @override
  String get lotterySaturdayLotto => 'Saturday Lotto';

  @override
  String get lotteryMegaMillions => 'Mega Millions';

  @override
  String get lotteryUkLotto => 'UK Lotto';

  @override
  String get lotteryEuroMillions => 'EuroMillions';

  @override
  String get lotteryLottoMax => 'Lotto Max';

  @override
  String get lotteryLotto649 => 'Lotto 6/49';

  @override
  String get lotteryLotto6aus49 => 'Lotto 6aus49';

  @override
  String get lotteryEuroJackpot => 'EuroJackpot';

  @override
  String get bonusPowerball => 'Powerball';

  @override
  String get bonusMegaBall => 'Mega Ball';

  @override
  String get bonusLuckyStars => 'Lucky Stars';

  @override
  String get bonusSuperzahl => 'Superzahl';

  @override
  String get bonusEuroNumbers => 'Euro Numbers';

  @override
  String get screenHistoryTitle => 'History';

  @override
  String get screenSettingsTitle => 'Settings';

  @override
  String get screenSavedPicksTitle => 'Saved Picks';

  @override
  String get screenAddMyNumbersTitle => 'Add My Numbers';

  @override
  String get numberSelectionLabel => 'Number selection';

  @override
  String get lotteryLabel => 'Lottery';

  @override
  String get homeCardTitle => 'Number Picks';

  @override
  String get homeCardSubtitle => 'Choose one style, or generate 3 number sets';

  @override
  String get generateOnePick => 'Generate 1 Pick';

  @override
  String get generateThreeNumberSets => '🎲 Generate 3 Number Sets';

  @override
  String get generateThreeNumberSetsDescription =>
      '3 Number Sets combine Balanced + Observed + Random styles for reference only.';

  @override
  String get pastOverlapReferenceNote =>
      '✨ Some selections overlapped multiple numbers in past results (for reference only)';

  @override
  String get generateEmptyPrompt =>
      'Generate a number set from past records 🎲';

  @override
  String get numberSetReady => '✨ Your number set is ready';

  @override
  String historicalSimilarityReference(int score) {
    return '📊 Historical similarity (reference only): $score / 100';
  }

  @override
  String dayStreak(int count) {
    return '🔥 $count-day streak';
  }

  @override
  String countdownWithHourglass(Object text) {
    return '⏳ $text';
  }

  @override
  String get saveAll => 'Save All';

  @override
  String get savedToSavedPicks => 'Saved to Saved Picks';

  @override
  String get pickSaved => 'Pick saved';

  @override
  String get alreadySaved => 'Already saved';

  @override
  String get allThreePicksSaved => 'All 3 picks saved';

  @override
  String get copiedToClipboard => 'Copied to clipboard.';

  @override
  String pickCopiedToClipboard(Object label) {
    return '$label copied to clipboard.';
  }

  @override
  String get savedPicksTooltip => 'Saved Picks';

  @override
  String get historyTooltip => 'History';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get addMyNumbersTooltip => 'Add My Numbers';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get collapseTooltip => 'Collapse';

  @override
  String get styleBalanced => 'Balanced';

  @override
  String get styleObservedPattern => 'Observed Pattern';

  @override
  String get styleLessCommon => 'Less common';

  @override
  String get styleRandom => 'Random';

  @override
  String get styleBalancedTagline => 'Balanced Pick';

  @override
  String get styleHotTagline => 'Example Pattern Pick';

  @override
  String get styleColdTagline => 'Historical Number Example';

  @override
  String get styleRandomTagline => 'Random Pick';

  @override
  String get styleBalancedSubtitle => 'Even spread across all number ranges.';

  @override
  String get styleHotSubtitle =>
      'These numbers were observed more often in past results.';

  @override
  String get styleColdSubtitle =>
      'These numbers were observed less often in past results.';

  @override
  String get styleRandomSubtitle =>
      'Completely random selection. Just for fun.';

  @override
  String get styleBalancedDescription => 'Even spread across the number range';

  @override
  String get styleHotDescription =>
      'Based on recent frequency in past results (for reference only)';

  @override
  String get styleColdDescription =>
      'Based on less frequent historical numbers (for reference only)';

  @override
  String get styleRandomDescription => 'Random selection (for reference only)';

  @override
  String get threePickExample => 'Example Pick';

  @override
  String get threePickExampleStar => '⭐ Example Pick';

  @override
  String get threePickCommonPattern => 'Common Pattern';

  @override
  String get threePickRandomSurprise => 'Random Surprise';

  @override
  String get threePickRandomSurpriseDice => '🎲 Random Surprise';

  @override
  String get threePickBalancedMicrocopy =>
      'Balanced selection based on past results';

  @override
  String get threePickHotMicrocopy =>
      'These numbers were observed more often in past results';

  @override
  String get threePickRandomMicrocopy =>
      'Random selection for reference only 🎲';

  @override
  String get insightBalancedOne =>
      'Based on past data, this shows a balanced spread for reference';

  @override
  String get insightBalancedTwo => 'History points to an even distribution';

  @override
  String get insightBalancedThree =>
      'Balanced number spread seen in past results';

  @override
  String get insightHotOne => 'Recent results show similar patterns';

  @override
  String get insightHotTwo => 'Frequently observed in past results';

  @override
  String get insightHotThree =>
      'Based on past results, a similar pattern was observed';

  @override
  String get insightColdOne =>
      'Based on past results, less common numbers were observed ❄️';

  @override
  String get insightColdTwo => 'Less common numbers from past results';

  @override
  String get insightRandomOne => 'Sometimes randomness is fun 🎲';

  @override
  String get insightRandomTwo => 'Random pattern for reference only';

  @override
  String get insightRandomThree => 'Random selection for fun';

  @override
  String nextResultUpdateDays(int days) {
    return 'Next result update in ${days}d';
  }

  @override
  String nextResultUpdateHours(int hours) {
    return 'Next result update in ${hours}h';
  }

  @override
  String get resultUpdateSoon => 'Result update soon!';

  @override
  String get referencePickLabel => 'Reference Pick';

  @override
  String referencePickWithStyle(Object style) {
    return 'Reference Pick · $style';
  }

  @override
  String get manualPickLabel => '👤 My Numbers';

  @override
  String trackingResult(Object date) {
    return 'Tracking result: $date';
  }

  @override
  String pickMainNumbers(int count, int min, int max) {
    return 'Pick $count numbers  ($min–$max)';
  }

  @override
  String pickBonusNumbers(int count, Object label, int min, int max) {
    return 'Pick $count $label  ($min–$max)';
  }

  @override
  String get saveMyNumbers => 'Save My Numbers';

  @override
  String pickMoreNumbers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'numbers',
      one: 'number',
    );
    return 'Pick $count more $_temp0';
  }

  @override
  String pickMoreBonus(int count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Pick $count more $label$_temp0';
  }

  @override
  String get disclaimerTitle => 'Just for fun — play responsibly.';

  @override
  String get disclaimerBody =>
      'This app provides number selections based on historical data only. It does NOT predict results, improve odds, or guarantee outcomes.';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsResults => 'Results';

  @override
  String get settingsResultsSubtitle =>
      'When past results are available for your saved picks';

  @override
  String get settingsMyPicks => 'My Picks';

  @override
  String get settingsMyPicksSubtitle =>
      'When your saved numbers appear in recent results';

  @override
  String get settingsDailyInsights => 'Daily Insights';

  @override
  String get settingsDailyInsightsSubtitle =>
      'One short trend observation per day';

  @override
  String get settingsWeeklySummary => 'Weekly Summary';

  @override
  String get settingsWeeklySummarySubtitle =>
      'A brief weekly pattern summary every Sunday';

  @override
  String get settingsMaxNotifications => 'Max 2 notifications per day total.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsHistoricalResultsOnly => 'Historical results only';

  @override
  String get settingsHistoricalResultsOnlyBody =>
      'All analysis is based on historical results. This app does not provide predictions or improve outcomes.';

  @override
  String get clearAllSavedPicksTitle => 'Clear all saved picks?';

  @override
  String get clearAll => 'Clear all';

  @override
  String get pickDeleted => 'Pick deleted';

  @override
  String get yourStats => 'Your Stats';

  @override
  String resultsChecked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'results',
      one: 'result',
    );
    return '$count $_temp0 checked';
  }

  @override
  String get top => 'Top';

  @override
  String get topWithTrophy => '🏆 Top';

  @override
  String get totalHits => 'Total Hits';

  @override
  String get similarityScore => 'Similarity Score';

  @override
  String get myPick => '👤 My Pick';

  @override
  String get noneYet => 'None yet';

  @override
  String mainCountLabel(int count) {
    return '$count main';
  }

  @override
  String suppCountLabel(int count) {
    return '$count supp';
  }

  @override
  String mainSuppCountLabel(int main, int supp) {
    return '$main+$supp';
  }

  @override
  String totalMainHits(int main) {
    return '$main main';
  }

  @override
  String totalMainSuppHits(int main, int supp) {
    return '$main main · $supp supp';
  }

  @override
  String get pending => 'Pending';

  @override
  String pendingWithDate(Object date) {
    return 'Pending · $date';
  }

  @override
  String copyPickText(
    Object lotteryName,
    Object label,
    Object main,
    Object bonus,
  ) {
    return '🎯 My $lotteryName Number Set\n$label\n\n$main$bonus\n\nGenerated for fun — NumberRun';
  }

  @override
  String copyPickBonusLine(Object label, Object numbers) {
    return '\n+ $label: $numbers';
  }

  @override
  String inlinePickCopyText(
    Object label,
    Object lotteryName,
    Object main,
    Object bonus,
  ) {
    return '$label\n$lotteryName: $main$bonus\nGenerated for fun — NumberRun 🎯';
  }

  @override
  String inlinePickBonusInline(Object numbers) {
    return ' + $numbers';
  }

  @override
  String get savedWithCheck => 'Saved ✓';

  @override
  String historyPastResultsCount(int count) {
    return '$count past results';
  }

  @override
  String get offlineModeSavedResults => 'Offline mode: showing saved results';

  @override
  String offlineModeSavedResultsFrom(Object date) {
    return 'Offline mode: showing saved results from $date';
  }

  @override
  String get noHistoryData => 'No history data available yet.';

  @override
  String get noInternetNoSavedHistory =>
      'No internet connection and no saved lottery history yet.';

  @override
  String get noInternetNoSavedResultHistory =>
      'No internet connection and no saved result history yet.';

  @override
  String get failedToLoadHistory => 'Failed to load history.';

  @override
  String get recentPatternsTitle => 'Recent Past Result Patterns';

  @override
  String recentPatternsSubtitle(int count) {
    return 'Based on the last $count past results';
  }

  @override
  String get historicalComparisonOnly =>
      'Historical comparison only · no guarantee of outcomes';

  @override
  String get frequentNumbers => 'Frequently observed numbers';

  @override
  String get frequentNumbersTooltip => 'Observed more often in past results';

  @override
  String get lessCommonNumbers => 'Less common numbers';

  @override
  String get lessCommonNumbersTooltip => 'Observed less often in past results';

  @override
  String get avgSum => 'Avg sum';

  @override
  String get oddEven => 'Odd/Even';

  @override
  String get lowHigh => 'Low/High';

  @override
  String get avgConsecPairs => 'Avg consec pairs';

  @override
  String get notEnoughHistory => 'Not enough past result history for analysis.';

  @override
  String get patternNotable => 'Notable pattern';

  @override
  String get patternBalanced => 'Balanced';

  @override
  String get patternRandomLike => 'Random-like';

  @override
  String get odd => 'odd';

  @override
  String get even => 'even';

  @override
  String get low => 'low';

  @override
  String get high => 'high';

  @override
  String get dailyInsightTitle => 'Today\'s Insight';

  @override
  String get savedPicksAnalysisTitle => 'My Saved Picks Analysis';

  @override
  String get savedPicksAnalysisSubtitle =>
      'Compared with recent 20 past results · post-result comparison only';

  @override
  String get topOverlap => 'Top overlap';

  @override
  String numbersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'numbers',
      one: 'number',
    );
    return '$count $_temp0';
  }

  @override
  String get avgOverlap => 'Avg overlap';

  @override
  String get perPastResult => 'per past result';

  @override
  String get oftenPicked => 'Often picked';

  @override
  String get inRecentDraws => 'In recent draws';

  @override
  String get overlapLevelHigh => 'Overlap level: High';

  @override
  String get overlapLevelMedium => 'Overlap level: Medium';

  @override
  String get overlapLevelLow => 'Overlap level: Low';

  @override
  String get historicalPatternNotEnough =>
      'Not enough history for pattern analysis (requires 52+ past draws).';

  @override
  String get historicalPatternTitle => 'Historical Pattern Comparison';

  @override
  String get historicalPatternSubtitle =>
      'Based on past results from the last 5 years';

  @override
  String get trendComparison => 'Trend comparison';

  @override
  String get observedLessCommonComparison => 'Observed/less-common comparison';

  @override
  String get oddEvenStructure => 'Odd/even structure';

  @override
  String get lowHighStructure => 'Low/high structure';

  @override
  String get sumRange => 'Sum range';

  @override
  String get consecutivePairs => 'Consecutive pairs';

  @override
  String consecutivePairCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pairs',
      one: 'pair',
    );
    return '$count consec $_temp0';
  }

  @override
  String get topSimilarPastResults =>
      'Top 10 similar past results (for reference only)';

  @override
  String similarSharedNumbers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'numbers',
      one: 'number',
    );
    return '$count $_temp0 overlapped';
  }

  @override
  String similarStructuralSimilarity(Object percent) {
    return '$percent% structural similarity';
  }

  @override
  String observedMoreLessCommonCounts(int hotCount, int coldCount) {
    return '🔥 $hotCount observed more often · ❄️ $coldCount less common';
  }

  @override
  String get historicalPatternStrong =>
      'Strong comparison with historical patterns (for reference only)';

  @override
  String get historicalPatternModerate =>
      'Moderate comparison with historical patterns (for reference only)';

  @override
  String get historicalPatternLimited =>
      'Limited comparison with historical patterns (for reference only)';

  @override
  String get drawResult => 'DRAW RESULT';

  @override
  String get supplementary => 'SUPPLEMENTARY';

  @override
  String get yourNumbers => 'YOUR NUMBERS';

  @override
  String get noMainMatched => 'No main matched';

  @override
  String get checkOfficialResults => 'Check official results for details';

  @override
  String get noNumbersMatched => 'No numbers matched';

  @override
  String bonusMatched(Object label) {
    return '$label matched';
  }

  @override
  String matchedCount(int count) {
    return '$count matched';
  }

  @override
  String matchedCountWithBonus(int count, Object label) {
    return '$count matched + $label';
  }

  @override
  String noMainWithSupp(int count) {
    return 'No main · ${count}s';
  }

  @override
  String matchedWithSupp(int main, int supp) {
    return '$main matched + ${supp}s';
  }

  @override
  String get noMatch => 'No match';

  @override
  String get levelLightHit => 'Light hit';

  @override
  String get levelNice => 'Nice';

  @override
  String get levelSolid => 'Solid';

  @override
  String get levelStrong => 'Strong';

  @override
  String get levelGreat => 'Great';

  @override
  String get unknown => 'Unknown';

  @override
  String get belowTypicalRange => 'Below typical range';

  @override
  String get aboveTypicalRange => 'Above typical range';

  @override
  String get withinTypicalRange => 'Within typical range';

  @override
  String get drawAnalysisNotEnough => 'Not enough draw history for analysis.';

  @override
  String get drawAnalysisNoSavedPicks =>
      'No saved picks or draw history to compare.';

  @override
  String get recentDrawsConcentrated =>
      'Recent draws show higher activity among a few numbers — a notable concentration in this period.';

  @override
  String get periodMidRangeActive =>
      'This period shows higher activity among several mid-range numbers.';

  @override
  String get recentDrawsHigherRange =>
      'Recent draws have leaned toward higher-range numbers.';

  @override
  String get recentDrawsLowerRange =>
      'Recent draws have leaned toward lower-range numbers.';

  @override
  String get recentDrawsModerateSpread =>
      'Recent draws are fairly balanced with a moderate spread across numbers.';

  @override
  String get recentDrawsNoStrongPattern =>
      'Recent draws are fairly balanced with no strong pattern detected.';

  @override
  String get weeklyNotableConcentration =>
      'This week showed a notable concentration among a few numbers.';

  @override
  String get weeklyModerateSpread =>
      'This week showed a balanced distribution with moderate spread.';

  @override
  String get weeklyNoStrongTrend =>
      'This week showed a balanced distribution with no strong trend.';

  @override
  String get savedPicksModerate =>
      'Your saved picks have matched recent draws moderately.';

  @override
  String get savedNumbersAppeared =>
      'Several numbers you saved appeared in recent results.';

  @override
  String get savedPicksLimited =>
      'Your saved picks show limited overlap with recent draw results.';

  @override
  String get drawStrongHistoricalComparison =>
      'This draw shows a strong comparison with historical patterns from the past 5 years.';

  @override
  String get drawModerateHistoricalComparison =>
      'This draw shows a moderate comparison with historical distribution patterns.';

  @override
  String get drawLimitedHistoricalComparison =>
      'This draw shows a limited comparison with typical historical patterns.';

  @override
  String get generatedForFunHistoricalPatterns =>
      'Generated for fun using historical patterns.';

  @override
  String get suppShort => 'S';

  @override
  String mainAndBonusMatched(int main, Object bonusLabel) {
    return '$main main + $bonusLabel matched';
  }

  @override
  String mainMatched(int main) {
    return '$main main matched';
  }

  @override
  String suppMatched(int supp) {
    return '$supp supp matched';
  }

  @override
  String mainAndSuppMatched(int main, int supp) {
    return '$main main + $supp supp matched';
  }

  @override
  String get shareNearMatch => '🔥 Near match!';

  @override
  String get shareOnlyOneAway => 'Only one number away 👀';

  @override
  String get shareCanYouBeatThis => 'Can you beat this? 👀';

  @override
  String get shareNotBad => '🎯 Not bad!';

  @override
  String shareOfMainCount(int count) {
    return 'of $count';
  }

  @override
  String get shareTemplate => 'Template';

  @override
  String get shareReferencePick => '⭐ Reference Pick';

  @override
  String get sharePng => 'Share PNG';

  @override
  String get shareDefaultPick => 'My number pick 🎯 — Generated by NumberRun';

  @override
  String get shareDefaultPicks => 'My number picks 🎯 — Generated by NumberRun';

  @override
  String get shareNumberComparison => '🔥 Number comparison from NumberRun';

  @override
  String get shareNumberOverlap => '🎯 Number overlap from NumberRun';

  @override
  String get shareRandomResult => '😆 Random result from NumberRun';

  @override
  String get shareTemplateFireLabel => '🔥 Almost Overlap';

  @override
  String get shareTemplateElectricLabel => '🎯 Number Overlap';

  @override
  String get shareTemplateWarmLabel => '😂 Random Result';

  @override
  String get shareTemplateFireDescription =>
      'Dramatic gold-on-dark card for close calls and strong hit streaks.';

  @override
  String get shareTemplateElectricDescription =>
      'Clean neon stats card for smaller wins and partial matches.';

  @override
  String get shareTemplateWarmDescription =>
      'Playful motivational card for pending draws, misses, or pick-only sharing.';

  @override
  String get shareNotToday => 'Not today';

  @override
  String get shareZeroOverlapped => '0 overlapped';

  @override
  String get shareRandomResultPlain => 'Random result';

  @override
  String get shareResultIncoming => 'Result update incoming!';

  @override
  String get shareWaitingForResults => 'Waiting for results 🤞';

  @override
  String get shareMyNumberPick => 'My Number Pick';

  @override
  String get shareLetsSee => 'Let\'s see what happens 👀';

  @override
  String get shareTheseAreMyNumbers => 'These are my numbers ↑';

  @override
  String get shareFunnyFail => '😂 Funny fail';

  @override
  String get shareCardPreviewTitle => 'Share Card Preview';

  @override
  String shareCardPreviewSubtitle(Object lotteryName) {
    return 'Pick a style or keep the default option for $lotteryName.';
  }

  @override
  String resultPanelNoOverlap(Object date) {
    return 'No overlap in last past result ($date)';
  }

  @override
  String resultPanelBonusAppeared(Object bonusLabel, Object date) {
    return '$bonusLabel appeared in last past result ($date)';
  }

  @override
  String resultPanelOverlap(int count, Object bonusSuffix, Object date) {
    return '$count$bonusSuffix overlapped in last past result ($date)';
  }

  @override
  String bonusSuffix(Object bonusLabel) {
    return ' + $bonusLabel';
  }

  @override
  String get notificationResultReadyChannel => 'Result Ready';

  @override
  String get notificationResultReadyTitle => 'Result Ready 🎯';

  @override
  String notificationResultsReadyTitle(int count) {
    return '$count Results Ready 🎯';
  }

  @override
  String get notificationSavedNumbersReady =>
      'Your saved lottery numbers are ready to check';

  @override
  String get notificationDailyInsightsChannel => 'Daily Insights';

  @override
  String get notificationDailyInsightTitle => 'Today\'s Insight 📊';

  @override
  String get notificationWeeklySummaryChannel => 'Weekly Summary';

  @override
  String get notificationWeeklySummaryTitle => 'Weekly Summary 📅';

  @override
  String get notificationResultsDescription =>
      'Notifies when lottery draw results are available';

  @override
  String get notificationDailyDescription => 'Daily draw trend observations';

  @override
  String get notificationWeeklyDescription => 'Weekly draw pattern summary';

  @override
  String lotteryHistoryNoRemoteCsv(Object lottery) {
    return 'No remote CSV configured for $lottery.';
  }

  @override
  String lotteryHistoryLoadFailed(int statusCode) {
    return 'Failed to load history CSV ($statusCode).';
  }

  @override
  String get lotteryHistoryCsvEmpty => 'History CSV is empty.';

  @override
  String get lotteryHistoryNoValidRows => 'No valid draw rows found in CSV.';

  @override
  String lotteryHistoryParseFailed(Object error) {
    return 'Failed to parse history CSV: $error';
  }
}
