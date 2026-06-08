import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LottFun'**
  String get appTitle;

  /// No description provided for @brandTitle.
  ///
  /// In en, this message translates to:
  /// **'NumberRun'**
  String get brandTitle;

  /// No description provided for @brandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Number sets from past records'**
  String get brandSubtitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get commonSaved;

  /// No description provided for @commonLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get commonLoad;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get commonBonus;

  /// No description provided for @commonSupp.
  ///
  /// In en, this message translates to:
  /// **'Supp'**
  String get commonSupp;

  /// No description provided for @commonView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get commonView;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get commonGenerating;

  /// No description provided for @commonPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get commonPreparing;

  /// No description provided for @countryUnitedStates.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryUnitedStates;

  /// No description provided for @countryAustralia.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get countryAustralia;

  /// No description provided for @countryUnitedKingdom.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get countryUnitedKingdom;

  /// No description provided for @countryCanada.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get countryCanada;

  /// No description provided for @countryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get countryOther;

  /// No description provided for @lotteryPowerball.
  ///
  /// In en, this message translates to:
  /// **'Powerball'**
  String get lotteryPowerball;

  /// No description provided for @lotteryOzLotto.
  ///
  /// In en, this message translates to:
  /// **'Oz Lotto'**
  String get lotteryOzLotto;

  /// No description provided for @lotterySaturdayLotto.
  ///
  /// In en, this message translates to:
  /// **'Saturday Lotto'**
  String get lotterySaturdayLotto;

  /// No description provided for @lotteryMegaMillions.
  ///
  /// In en, this message translates to:
  /// **'Mega Millions'**
  String get lotteryMegaMillions;

  /// No description provided for @lotteryUkLotto.
  ///
  /// In en, this message translates to:
  /// **'UK Lotto'**
  String get lotteryUkLotto;

  /// No description provided for @lotteryEuroMillions.
  ///
  /// In en, this message translates to:
  /// **'EuroMillions'**
  String get lotteryEuroMillions;

  /// No description provided for @lotteryLottoMax.
  ///
  /// In en, this message translates to:
  /// **'Lotto Max'**
  String get lotteryLottoMax;

  /// No description provided for @lotteryLotto649.
  ///
  /// In en, this message translates to:
  /// **'Lotto 6/49'**
  String get lotteryLotto649;

  /// No description provided for @bonusPowerball.
  ///
  /// In en, this message translates to:
  /// **'Powerball'**
  String get bonusPowerball;

  /// No description provided for @bonusMegaBall.
  ///
  /// In en, this message translates to:
  /// **'Mega Ball'**
  String get bonusMegaBall;

  /// No description provided for @bonusLuckyStars.
  ///
  /// In en, this message translates to:
  /// **'Lucky Stars'**
  String get bonusLuckyStars;

  /// No description provided for @screenHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get screenHistoryTitle;

  /// No description provided for @screenSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get screenSettingsTitle;

  /// No description provided for @screenSavedPicksTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Picks'**
  String get screenSavedPicksTitle;

  /// No description provided for @screenAddMyNumbersTitle.
  ///
  /// In en, this message translates to:
  /// **'Add My Numbers'**
  String get screenAddMyNumbersTitle;

  /// No description provided for @numberSelectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Number selection'**
  String get numberSelectionLabel;

  /// No description provided for @lotteryLabel.
  ///
  /// In en, this message translates to:
  /// **'Lottery'**
  String get lotteryLabel;

  /// No description provided for @homeCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Number Picks'**
  String get homeCardTitle;

  /// No description provided for @homeCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose one style, or generate 3 number sets'**
  String get homeCardSubtitle;

  /// No description provided for @generateOnePick.
  ///
  /// In en, this message translates to:
  /// **'Generate 1 Pick'**
  String get generateOnePick;

  /// No description provided for @generateThreeNumberSets.
  ///
  /// In en, this message translates to:
  /// **'🎲 Generate 3 Number Sets'**
  String get generateThreeNumberSets;

  /// No description provided for @generateThreeNumberSetsDescription.
  ///
  /// In en, this message translates to:
  /// **'3 Number Sets combine Balanced + Observed + Random styles for reference only.'**
  String get generateThreeNumberSetsDescription;

  /// No description provided for @pastOverlapReferenceNote.
  ///
  /// In en, this message translates to:
  /// **'✨ Some selections overlapped multiple numbers in past results (for reference only)'**
  String get pastOverlapReferenceNote;

  /// No description provided for @generateEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Generate a number set from past records 🎲'**
  String get generateEmptyPrompt;

  /// No description provided for @numberSetReady.
  ///
  /// In en, this message translates to:
  /// **'✨ Your number set is ready'**
  String get numberSetReady;

  /// No description provided for @historicalSimilarityReference.
  ///
  /// In en, this message translates to:
  /// **'📊 Historical similarity (reference only): {score} / 100'**
  String historicalSimilarityReference(int score);

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'🔥 {count}-day streak'**
  String dayStreak(int count);

  /// No description provided for @countdownWithHourglass.
  ///
  /// In en, this message translates to:
  /// **'⏳ {text}'**
  String countdownWithHourglass(Object text);

  /// No description provided for @saveAll.
  ///
  /// In en, this message translates to:
  /// **'Save All'**
  String get saveAll;

  /// No description provided for @savedToSavedPicks.
  ///
  /// In en, this message translates to:
  /// **'Saved to Saved Picks'**
  String get savedToSavedPicks;

  /// No description provided for @pickSaved.
  ///
  /// In en, this message translates to:
  /// **'Pick saved'**
  String get pickSaved;

  /// No description provided for @alreadySaved.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get alreadySaved;

  /// No description provided for @allThreePicksSaved.
  ///
  /// In en, this message translates to:
  /// **'All 3 picks saved'**
  String get allThreePicksSaved;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard.'**
  String get copiedToClipboard;

  /// No description provided for @pickCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard.'**
  String pickCopiedToClipboard(Object label);

  /// No description provided for @savedPicksTooltip.
  ///
  /// In en, this message translates to:
  /// **'Saved Picks'**
  String get savedPicksTooltip;

  /// No description provided for @historyTooltip.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @addMyNumbersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add My Numbers'**
  String get addMyNumbersTooltip;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// No description provided for @collapseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapseTooltip;

  /// No description provided for @styleBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get styleBalanced;

  /// No description provided for @styleObservedPattern.
  ///
  /// In en, this message translates to:
  /// **'Observed Pattern'**
  String get styleObservedPattern;

  /// No description provided for @styleLessCommon.
  ///
  /// In en, this message translates to:
  /// **'Less common'**
  String get styleLessCommon;

  /// No description provided for @styleRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get styleRandom;

  /// No description provided for @styleBalancedTagline.
  ///
  /// In en, this message translates to:
  /// **'Balanced Pick'**
  String get styleBalancedTagline;

  /// No description provided for @styleHotTagline.
  ///
  /// In en, this message translates to:
  /// **'Example Pattern Pick'**
  String get styleHotTagline;

  /// No description provided for @styleColdTagline.
  ///
  /// In en, this message translates to:
  /// **'Historical Number Example'**
  String get styleColdTagline;

  /// No description provided for @styleRandomTagline.
  ///
  /// In en, this message translates to:
  /// **'Random Pick'**
  String get styleRandomTagline;

  /// No description provided for @styleBalancedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Even spread across all number ranges.'**
  String get styleBalancedSubtitle;

  /// No description provided for @styleHotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These numbers were observed more often in past results.'**
  String get styleHotSubtitle;

  /// No description provided for @styleColdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These numbers were observed less often in past results.'**
  String get styleColdSubtitle;

  /// No description provided for @styleRandomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Completely random selection. Just for fun.'**
  String get styleRandomSubtitle;

  /// No description provided for @styleBalancedDescription.
  ///
  /// In en, this message translates to:
  /// **'Even spread across the number range'**
  String get styleBalancedDescription;

  /// No description provided for @styleHotDescription.
  ///
  /// In en, this message translates to:
  /// **'Based on recent frequency in past results (for reference only)'**
  String get styleHotDescription;

  /// No description provided for @styleColdDescription.
  ///
  /// In en, this message translates to:
  /// **'Based on less frequent historical numbers (for reference only)'**
  String get styleColdDescription;

  /// No description provided for @styleRandomDescription.
  ///
  /// In en, this message translates to:
  /// **'Random selection (for reference only)'**
  String get styleRandomDescription;

  /// No description provided for @threePickExample.
  ///
  /// In en, this message translates to:
  /// **'Example Pick'**
  String get threePickExample;

  /// No description provided for @threePickExampleStar.
  ///
  /// In en, this message translates to:
  /// **'⭐ Example Pick'**
  String get threePickExampleStar;

  /// No description provided for @threePickCommonPattern.
  ///
  /// In en, this message translates to:
  /// **'Common Pattern'**
  String get threePickCommonPattern;

  /// No description provided for @threePickRandomSurprise.
  ///
  /// In en, this message translates to:
  /// **'Random Surprise'**
  String get threePickRandomSurprise;

  /// No description provided for @threePickRandomSurpriseDice.
  ///
  /// In en, this message translates to:
  /// **'🎲 Random Surprise'**
  String get threePickRandomSurpriseDice;

  /// No description provided for @threePickBalancedMicrocopy.
  ///
  /// In en, this message translates to:
  /// **'Balanced selection based on past results'**
  String get threePickBalancedMicrocopy;

  /// No description provided for @threePickHotMicrocopy.
  ///
  /// In en, this message translates to:
  /// **'These numbers were observed more often in past results'**
  String get threePickHotMicrocopy;

  /// No description provided for @threePickRandomMicrocopy.
  ///
  /// In en, this message translates to:
  /// **'Random selection for reference only 🎲'**
  String get threePickRandomMicrocopy;

  /// No description provided for @insightBalancedOne.
  ///
  /// In en, this message translates to:
  /// **'Based on past data, this shows a balanced spread for reference'**
  String get insightBalancedOne;

  /// No description provided for @insightBalancedTwo.
  ///
  /// In en, this message translates to:
  /// **'History points to an even distribution'**
  String get insightBalancedTwo;

  /// No description provided for @insightBalancedThree.
  ///
  /// In en, this message translates to:
  /// **'Balanced number spread seen in past results'**
  String get insightBalancedThree;

  /// No description provided for @insightHotOne.
  ///
  /// In en, this message translates to:
  /// **'Recent results show similar patterns'**
  String get insightHotOne;

  /// No description provided for @insightHotTwo.
  ///
  /// In en, this message translates to:
  /// **'Frequently observed in past results'**
  String get insightHotTwo;

  /// No description provided for @insightHotThree.
  ///
  /// In en, this message translates to:
  /// **'Based on past results, a similar pattern was observed'**
  String get insightHotThree;

  /// No description provided for @insightColdOne.
  ///
  /// In en, this message translates to:
  /// **'Based on past results, less common numbers were observed ❄️'**
  String get insightColdOne;

  /// No description provided for @insightColdTwo.
  ///
  /// In en, this message translates to:
  /// **'Less common numbers from past results'**
  String get insightColdTwo;

  /// No description provided for @insightRandomOne.
  ///
  /// In en, this message translates to:
  /// **'Sometimes randomness is fun 🎲'**
  String get insightRandomOne;

  /// No description provided for @insightRandomTwo.
  ///
  /// In en, this message translates to:
  /// **'Random pattern for reference only'**
  String get insightRandomTwo;

  /// No description provided for @insightRandomThree.
  ///
  /// In en, this message translates to:
  /// **'Random selection for fun'**
  String get insightRandomThree;

  /// No description provided for @nextResultUpdateDays.
  ///
  /// In en, this message translates to:
  /// **'Next result update in {days}d'**
  String nextResultUpdateDays(int days);

  /// No description provided for @nextResultUpdateHours.
  ///
  /// In en, this message translates to:
  /// **'Next result update in {hours}h'**
  String nextResultUpdateHours(int hours);

  /// No description provided for @resultUpdateSoon.
  ///
  /// In en, this message translates to:
  /// **'Result update soon!'**
  String get resultUpdateSoon;

  /// No description provided for @referencePickLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference Pick'**
  String get referencePickLabel;

  /// No description provided for @referencePickWithStyle.
  ///
  /// In en, this message translates to:
  /// **'Reference Pick · {style}'**
  String referencePickWithStyle(Object style);

  /// No description provided for @manualPickLabel.
  ///
  /// In en, this message translates to:
  /// **'👤 My Numbers'**
  String get manualPickLabel;

  /// No description provided for @trackingResult.
  ///
  /// In en, this message translates to:
  /// **'Tracking result: {date}'**
  String trackingResult(Object date);

  /// No description provided for @pickMainNumbers.
  ///
  /// In en, this message translates to:
  /// **'Pick {count} numbers  ({min}–{max})'**
  String pickMainNumbers(int count, int min, int max);

  /// No description provided for @pickBonusNumbers.
  ///
  /// In en, this message translates to:
  /// **'Pick {count} {label}  ({min}–{max})'**
  String pickBonusNumbers(int count, Object label, int min, int max);

  /// No description provided for @saveMyNumbers.
  ///
  /// In en, this message translates to:
  /// **'Save My Numbers'**
  String get saveMyNumbers;

  /// No description provided for @pickMoreNumbers.
  ///
  /// In en, this message translates to:
  /// **'Pick {count} more {count, plural, one{number} other{numbers}}'**
  String pickMoreNumbers(int count);

  /// No description provided for @pickMoreBonus.
  ///
  /// In en, this message translates to:
  /// **'Pick {count} more {label}{count, plural, one{} other{s}}'**
  String pickMoreBonus(int count, Object label);

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Just for fun — play responsibly.'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'This app provides number selections based on historical data only. It does NOT predict results, improve odds, or guarantee outcomes.'**
  String get disclaimerBody;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get settingsResults;

  /// No description provided for @settingsResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When past results are available for your saved picks'**
  String get settingsResultsSubtitle;

  /// No description provided for @settingsMyPicks.
  ///
  /// In en, this message translates to:
  /// **'My Picks'**
  String get settingsMyPicks;

  /// No description provided for @settingsMyPicksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When your saved numbers appear in recent results'**
  String get settingsMyPicksSubtitle;

  /// No description provided for @settingsDailyInsights.
  ///
  /// In en, this message translates to:
  /// **'Daily Insights'**
  String get settingsDailyInsights;

  /// No description provided for @settingsDailyInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One short trend observation per day'**
  String get settingsDailyInsightsSubtitle;

  /// No description provided for @settingsWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get settingsWeeklySummary;

  /// No description provided for @settingsWeeklySummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A brief weekly pattern summary every Sunday'**
  String get settingsWeeklySummarySubtitle;

  /// No description provided for @settingsMaxNotifications.
  ///
  /// In en, this message translates to:
  /// **'Max 2 notifications per day total.'**
  String get settingsMaxNotifications;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsHistoricalResultsOnly.
  ///
  /// In en, this message translates to:
  /// **'Historical results only'**
  String get settingsHistoricalResultsOnly;

  /// No description provided for @settingsHistoricalResultsOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'All analysis is based on historical results. This app does not provide predictions or improve outcomes.'**
  String get settingsHistoricalResultsOnlyBody;

  /// No description provided for @clearAllSavedPicksTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all saved picks?'**
  String get clearAllSavedPicksTitle;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @pickDeleted.
  ///
  /// In en, this message translates to:
  /// **'Pick deleted'**
  String get pickDeleted;

  /// No description provided for @yourStats.
  ///
  /// In en, this message translates to:
  /// **'Your Stats'**
  String get yourStats;

  /// No description provided for @resultsChecked.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, one{result} other{results}} checked'**
  String resultsChecked(int count);

  /// No description provided for @top.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get top;

  /// No description provided for @topWithTrophy.
  ///
  /// In en, this message translates to:
  /// **'🏆 Top'**
  String get topWithTrophy;

  /// No description provided for @totalHits.
  ///
  /// In en, this message translates to:
  /// **'Total Hits'**
  String get totalHits;

  /// No description provided for @similarityScore.
  ///
  /// In en, this message translates to:
  /// **'Similarity Score'**
  String get similarityScore;

  /// No description provided for @myPick.
  ///
  /// In en, this message translates to:
  /// **'👤 My Pick'**
  String get myPick;

  /// No description provided for @noneYet.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get noneYet;

  /// No description provided for @mainCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} main'**
  String mainCountLabel(int count);

  /// No description provided for @suppCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} supp'**
  String suppCountLabel(int count);

  /// No description provided for @mainSuppCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{main}+{supp}'**
  String mainSuppCountLabel(int main, int supp);

  /// No description provided for @totalMainHits.
  ///
  /// In en, this message translates to:
  /// **'{main} main'**
  String totalMainHits(int main);

  /// No description provided for @totalMainSuppHits.
  ///
  /// In en, this message translates to:
  /// **'{main} main · {supp} supp'**
  String totalMainSuppHits(int main, int supp);

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @pendingWithDate.
  ///
  /// In en, this message translates to:
  /// **'Pending · {date}'**
  String pendingWithDate(Object date);

  /// No description provided for @copyPickText.
  ///
  /// In en, this message translates to:
  /// **'🎯 My {lotteryName} Number Set\n{label}\n\n{main}{bonus}\n\nGenerated for fun — NumberRun'**
  String copyPickText(
    Object lotteryName,
    Object label,
    Object main,
    Object bonus,
  );

  /// No description provided for @copyPickBonusLine.
  ///
  /// In en, this message translates to:
  /// **'\n+ {label}: {numbers}'**
  String copyPickBonusLine(Object label, Object numbers);

  /// No description provided for @inlinePickCopyText.
  ///
  /// In en, this message translates to:
  /// **'{label}\n{lotteryName}: {main}{bonus}\nGenerated for fun — NumberRun 🎯'**
  String inlinePickCopyText(
    Object label,
    Object lotteryName,
    Object main,
    Object bonus,
  );

  /// No description provided for @inlinePickBonusInline.
  ///
  /// In en, this message translates to:
  /// **' + {numbers}'**
  String inlinePickBonusInline(Object numbers);

  /// No description provided for @savedWithCheck.
  ///
  /// In en, this message translates to:
  /// **'Saved ✓'**
  String get savedWithCheck;

  /// No description provided for @historyPastResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} past results'**
  String historyPastResultsCount(int count);

  /// No description provided for @offlineModeSavedResults.
  ///
  /// In en, this message translates to:
  /// **'Offline mode: showing saved results'**
  String get offlineModeSavedResults;

  /// No description provided for @offlineModeSavedResultsFrom.
  ///
  /// In en, this message translates to:
  /// **'Offline mode: showing saved results from {date}'**
  String offlineModeSavedResultsFrom(Object date);

  /// No description provided for @noHistoryData.
  ///
  /// In en, this message translates to:
  /// **'No history data available yet.'**
  String get noHistoryData;

  /// No description provided for @noInternetNoSavedHistory.
  ///
  /// In en, this message translates to:
  /// **'No internet connection and no saved lottery history yet.'**
  String get noInternetNoSavedHistory;

  /// No description provided for @noInternetNoSavedResultHistory.
  ///
  /// In en, this message translates to:
  /// **'No internet connection and no saved result history yet.'**
  String get noInternetNoSavedResultHistory;

  /// No description provided for @failedToLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history.'**
  String get failedToLoadHistory;

  /// No description provided for @recentPatternsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Past Result Patterns'**
  String get recentPatternsTitle;

  /// No description provided for @recentPatternsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on the last {count} past results'**
  String recentPatternsSubtitle(int count);

  /// No description provided for @historicalComparisonOnly.
  ///
  /// In en, this message translates to:
  /// **'Historical comparison only · no guarantee of outcomes'**
  String get historicalComparisonOnly;

  /// No description provided for @frequentNumbers.
  ///
  /// In en, this message translates to:
  /// **'Frequently observed numbers'**
  String get frequentNumbers;

  /// No description provided for @frequentNumbersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Observed more often in past results'**
  String get frequentNumbersTooltip;

  /// No description provided for @lessCommonNumbers.
  ///
  /// In en, this message translates to:
  /// **'Less common numbers'**
  String get lessCommonNumbers;

  /// No description provided for @lessCommonNumbersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Observed less often in past results'**
  String get lessCommonNumbersTooltip;

  /// No description provided for @avgSum.
  ///
  /// In en, this message translates to:
  /// **'Avg sum'**
  String get avgSum;

  /// No description provided for @oddEven.
  ///
  /// In en, this message translates to:
  /// **'Odd/Even'**
  String get oddEven;

  /// No description provided for @lowHigh.
  ///
  /// In en, this message translates to:
  /// **'Low/High'**
  String get lowHigh;

  /// No description provided for @avgConsecPairs.
  ///
  /// In en, this message translates to:
  /// **'Avg consec pairs'**
  String get avgConsecPairs;

  /// No description provided for @notEnoughHistory.
  ///
  /// In en, this message translates to:
  /// **'Not enough past result history for analysis.'**
  String get notEnoughHistory;

  /// No description provided for @patternNotable.
  ///
  /// In en, this message translates to:
  /// **'Notable pattern'**
  String get patternNotable;

  /// No description provided for @patternBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get patternBalanced;

  /// No description provided for @patternRandomLike.
  ///
  /// In en, this message translates to:
  /// **'Random-like'**
  String get patternRandomLike;

  /// No description provided for @dailyInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Insight'**
  String get dailyInsightTitle;

  /// No description provided for @savedPicksAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'My Saved Picks Analysis'**
  String get savedPicksAnalysisTitle;

  /// No description provided for @savedPicksAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compared with recent 20 past results · post-result comparison only'**
  String get savedPicksAnalysisSubtitle;

  /// No description provided for @topOverlap.
  ///
  /// In en, this message translates to:
  /// **'Top overlap'**
  String get topOverlap;

  /// No description provided for @numbersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, one{number} other{numbers}}'**
  String numbersCount(int count);

  /// No description provided for @avgOverlap.
  ///
  /// In en, this message translates to:
  /// **'Avg overlap'**
  String get avgOverlap;

  /// No description provided for @perPastResult.
  ///
  /// In en, this message translates to:
  /// **'per past result'**
  String get perPastResult;

  /// No description provided for @oftenPicked.
  ///
  /// In en, this message translates to:
  /// **'Often picked'**
  String get oftenPicked;

  /// No description provided for @inRecentDraws.
  ///
  /// In en, this message translates to:
  /// **'In recent draws'**
  String get inRecentDraws;

  /// No description provided for @overlapLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'Overlap level: High'**
  String get overlapLevelHigh;

  /// No description provided for @overlapLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'Overlap level: Medium'**
  String get overlapLevelMedium;

  /// No description provided for @overlapLevelLow.
  ///
  /// In en, this message translates to:
  /// **'Overlap level: Low'**
  String get overlapLevelLow;

  /// No description provided for @historicalPatternNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough history for pattern analysis (requires 52+ past draws).'**
  String get historicalPatternNotEnough;

  /// No description provided for @historicalPatternTitle.
  ///
  /// In en, this message translates to:
  /// **'Historical Pattern Comparison'**
  String get historicalPatternTitle;

  /// No description provided for @historicalPatternSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on past results from the last 5 years'**
  String get historicalPatternSubtitle;

  /// No description provided for @trendComparison.
  ///
  /// In en, this message translates to:
  /// **'Trend comparison'**
  String get trendComparison;

  /// No description provided for @observedLessCommonComparison.
  ///
  /// In en, this message translates to:
  /// **'Observed/less-common comparison'**
  String get observedLessCommonComparison;

  /// No description provided for @oddEvenStructure.
  ///
  /// In en, this message translates to:
  /// **'Odd/even structure'**
  String get oddEvenStructure;

  /// No description provided for @lowHighStructure.
  ///
  /// In en, this message translates to:
  /// **'Low/high structure'**
  String get lowHighStructure;

  /// No description provided for @sumRange.
  ///
  /// In en, this message translates to:
  /// **'Sum range'**
  String get sumRange;

  /// No description provided for @consecutivePairs.
  ///
  /// In en, this message translates to:
  /// **'Consecutive pairs'**
  String get consecutivePairs;

  /// No description provided for @consecutivePairCount.
  ///
  /// In en, this message translates to:
  /// **'{count} consec {count, plural, one{pair} other{pairs}}'**
  String consecutivePairCount(int count);

  /// No description provided for @topSimilarPastResults.
  ///
  /// In en, this message translates to:
  /// **'Top 10 similar past results (for reference only)'**
  String get topSimilarPastResults;

  /// No description provided for @similarSharedNumbers.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, one{number} other{numbers}} overlapped'**
  String similarSharedNumbers(int count);

  /// No description provided for @similarStructuralSimilarity.
  ///
  /// In en, this message translates to:
  /// **'{percent}% structural similarity'**
  String similarStructuralSimilarity(Object percent);

  /// No description provided for @observedMoreLessCommonCounts.
  ///
  /// In en, this message translates to:
  /// **'🔥 {hotCount} observed more often · ❄️ {coldCount} less common'**
  String observedMoreLessCommonCounts(int hotCount, int coldCount);

  /// No description provided for @historicalPatternStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong comparison with historical patterns (for reference only)'**
  String get historicalPatternStrong;

  /// No description provided for @historicalPatternModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate comparison with historical patterns (for reference only)'**
  String get historicalPatternModerate;

  /// No description provided for @historicalPatternLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited comparison with historical patterns (for reference only)'**
  String get historicalPatternLimited;

  /// No description provided for @drawResult.
  ///
  /// In en, this message translates to:
  /// **'DRAW RESULT'**
  String get drawResult;

  /// No description provided for @supplementary.
  ///
  /// In en, this message translates to:
  /// **'SUPPLEMENTARY'**
  String get supplementary;

  /// No description provided for @yourNumbers.
  ///
  /// In en, this message translates to:
  /// **'YOUR NUMBERS'**
  String get yourNumbers;

  /// No description provided for @noMainMatched.
  ///
  /// In en, this message translates to:
  /// **'No main matched'**
  String get noMainMatched;

  /// No description provided for @checkOfficialResults.
  ///
  /// In en, this message translates to:
  /// **'Check official results for details'**
  String get checkOfficialResults;

  /// No description provided for @noNumbersMatched.
  ///
  /// In en, this message translates to:
  /// **'No numbers matched'**
  String get noNumbersMatched;

  /// No description provided for @bonusMatched.
  ///
  /// In en, this message translates to:
  /// **'{label} matched'**
  String bonusMatched(Object label);

  /// No description provided for @matchedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} matched'**
  String matchedCount(int count);

  /// No description provided for @matchedCountWithBonus.
  ///
  /// In en, this message translates to:
  /// **'{count} matched + {label}'**
  String matchedCountWithBonus(int count, Object label);

  /// No description provided for @noMainWithSupp.
  ///
  /// In en, this message translates to:
  /// **'No main · {count}s'**
  String noMainWithSupp(int count);

  /// No description provided for @matchedWithSupp.
  ///
  /// In en, this message translates to:
  /// **'{main} matched + {supp}s'**
  String matchedWithSupp(int main, int supp);

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'No match'**
  String get noMatch;

  /// No description provided for @levelLightHit.
  ///
  /// In en, this message translates to:
  /// **'Light hit'**
  String get levelLightHit;

  /// No description provided for @levelNice.
  ///
  /// In en, this message translates to:
  /// **'Nice'**
  String get levelNice;

  /// No description provided for @levelSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get levelSolid;

  /// No description provided for @levelStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get levelStrong;

  /// No description provided for @levelGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get levelGreat;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @belowTypicalRange.
  ///
  /// In en, this message translates to:
  /// **'Below typical range'**
  String get belowTypicalRange;

  /// No description provided for @aboveTypicalRange.
  ///
  /// In en, this message translates to:
  /// **'Above typical range'**
  String get aboveTypicalRange;

  /// No description provided for @withinTypicalRange.
  ///
  /// In en, this message translates to:
  /// **'Within typical range'**
  String get withinTypicalRange;

  /// No description provided for @drawAnalysisNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough draw history for analysis.'**
  String get drawAnalysisNotEnough;

  /// No description provided for @drawAnalysisNoSavedPicks.
  ///
  /// In en, this message translates to:
  /// **'No saved picks or draw history to compare.'**
  String get drawAnalysisNoSavedPicks;

  /// No description provided for @recentDrawsConcentrated.
  ///
  /// In en, this message translates to:
  /// **'Recent draws show higher activity among a few numbers — a notable concentration in this period.'**
  String get recentDrawsConcentrated;

  /// No description provided for @periodMidRangeActive.
  ///
  /// In en, this message translates to:
  /// **'This period shows higher activity among several mid-range numbers.'**
  String get periodMidRangeActive;

  /// No description provided for @recentDrawsHigherRange.
  ///
  /// In en, this message translates to:
  /// **'Recent draws have leaned toward higher-range numbers.'**
  String get recentDrawsHigherRange;

  /// No description provided for @recentDrawsLowerRange.
  ///
  /// In en, this message translates to:
  /// **'Recent draws have leaned toward lower-range numbers.'**
  String get recentDrawsLowerRange;

  /// No description provided for @recentDrawsModerateSpread.
  ///
  /// In en, this message translates to:
  /// **'Recent draws are fairly balanced with a moderate spread across numbers.'**
  String get recentDrawsModerateSpread;

  /// No description provided for @recentDrawsNoStrongPattern.
  ///
  /// In en, this message translates to:
  /// **'Recent draws are fairly balanced with no strong pattern detected.'**
  String get recentDrawsNoStrongPattern;

  /// No description provided for @weeklyNotableConcentration.
  ///
  /// In en, this message translates to:
  /// **'This week showed a notable concentration among a few numbers.'**
  String get weeklyNotableConcentration;

  /// No description provided for @weeklyModerateSpread.
  ///
  /// In en, this message translates to:
  /// **'This week showed a balanced distribution with moderate spread.'**
  String get weeklyModerateSpread;

  /// No description provided for @weeklyNoStrongTrend.
  ///
  /// In en, this message translates to:
  /// **'This week showed a balanced distribution with no strong trend.'**
  String get weeklyNoStrongTrend;

  /// No description provided for @savedPicksModerate.
  ///
  /// In en, this message translates to:
  /// **'Your saved picks have matched recent draws moderately.'**
  String get savedPicksModerate;

  /// No description provided for @savedNumbersAppeared.
  ///
  /// In en, this message translates to:
  /// **'Several numbers you saved appeared in recent results.'**
  String get savedNumbersAppeared;

  /// No description provided for @savedPicksLimited.
  ///
  /// In en, this message translates to:
  /// **'Your saved picks show limited overlap with recent draw results.'**
  String get savedPicksLimited;

  /// No description provided for @drawStrongHistoricalComparison.
  ///
  /// In en, this message translates to:
  /// **'This draw shows a strong comparison with historical patterns from the past 5 years.'**
  String get drawStrongHistoricalComparison;

  /// No description provided for @drawModerateHistoricalComparison.
  ///
  /// In en, this message translates to:
  /// **'This draw shows a moderate comparison with historical distribution patterns.'**
  String get drawModerateHistoricalComparison;

  /// No description provided for @drawLimitedHistoricalComparison.
  ///
  /// In en, this message translates to:
  /// **'This draw shows a limited comparison with typical historical patterns.'**
  String get drawLimitedHistoricalComparison;

  /// No description provided for @generatedForFunHistoricalPatterns.
  ///
  /// In en, this message translates to:
  /// **'Generated for fun using historical patterns.'**
  String get generatedForFunHistoricalPatterns;

  /// No description provided for @suppShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get suppShort;

  /// No description provided for @mainAndBonusMatched.
  ///
  /// In en, this message translates to:
  /// **'{main} main + {bonusLabel} matched'**
  String mainAndBonusMatched(int main, Object bonusLabel);

  /// No description provided for @mainMatched.
  ///
  /// In en, this message translates to:
  /// **'{main} main matched'**
  String mainMatched(int main);

  /// No description provided for @suppMatched.
  ///
  /// In en, this message translates to:
  /// **'{supp} supp matched'**
  String suppMatched(int supp);

  /// No description provided for @mainAndSuppMatched.
  ///
  /// In en, this message translates to:
  /// **'{main} main + {supp} supp matched'**
  String mainAndSuppMatched(int main, int supp);

  /// No description provided for @shareNearMatch.
  ///
  /// In en, this message translates to:
  /// **'🔥 Near match!'**
  String get shareNearMatch;

  /// No description provided for @shareOnlyOneAway.
  ///
  /// In en, this message translates to:
  /// **'Only one number away 👀'**
  String get shareOnlyOneAway;

  /// No description provided for @shareCanYouBeatThis.
  ///
  /// In en, this message translates to:
  /// **'Can you beat this? 👀'**
  String get shareCanYouBeatThis;

  /// No description provided for @shareNotBad.
  ///
  /// In en, this message translates to:
  /// **'🎯 Not bad!'**
  String get shareNotBad;

  /// No description provided for @shareOfMainCount.
  ///
  /// In en, this message translates to:
  /// **'of {count}'**
  String shareOfMainCount(int count);

  /// No description provided for @shareTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get shareTemplate;

  /// No description provided for @shareReferencePick.
  ///
  /// In en, this message translates to:
  /// **'⭐ Reference Pick'**
  String get shareReferencePick;

  /// No description provided for @sharePng.
  ///
  /// In en, this message translates to:
  /// **'Share PNG'**
  String get sharePng;

  /// No description provided for @shareDefaultPick.
  ///
  /// In en, this message translates to:
  /// **'My number pick 🎯 — Generated by NumberRun'**
  String get shareDefaultPick;

  /// No description provided for @shareDefaultPicks.
  ///
  /// In en, this message translates to:
  /// **'My number picks 🎯 — Generated by NumberRun'**
  String get shareDefaultPicks;

  /// No description provided for @shareNumberComparison.
  ///
  /// In en, this message translates to:
  /// **'🔥 Number comparison from NumberRun'**
  String get shareNumberComparison;

  /// No description provided for @shareNumberOverlap.
  ///
  /// In en, this message translates to:
  /// **'🎯 Number overlap from NumberRun'**
  String get shareNumberOverlap;

  /// No description provided for @shareRandomResult.
  ///
  /// In en, this message translates to:
  /// **'😆 Random result from NumberRun'**
  String get shareRandomResult;

  /// No description provided for @shareTemplateFireLabel.
  ///
  /// In en, this message translates to:
  /// **'🔥 Almost Overlap'**
  String get shareTemplateFireLabel;

  /// No description provided for @shareTemplateElectricLabel.
  ///
  /// In en, this message translates to:
  /// **'🎯 Number Overlap'**
  String get shareTemplateElectricLabel;

  /// No description provided for @shareTemplateWarmLabel.
  ///
  /// In en, this message translates to:
  /// **'😂 Random Result'**
  String get shareTemplateWarmLabel;

  /// No description provided for @shareTemplateFireDescription.
  ///
  /// In en, this message translates to:
  /// **'Dramatic gold-on-dark card for close calls and strong hit streaks.'**
  String get shareTemplateFireDescription;

  /// No description provided for @shareTemplateElectricDescription.
  ///
  /// In en, this message translates to:
  /// **'Clean neon stats card for smaller wins and partial matches.'**
  String get shareTemplateElectricDescription;

  /// No description provided for @shareTemplateWarmDescription.
  ///
  /// In en, this message translates to:
  /// **'Playful motivational card for pending draws, misses, or pick-only sharing.'**
  String get shareTemplateWarmDescription;

  /// No description provided for @shareNotToday.
  ///
  /// In en, this message translates to:
  /// **'Not today'**
  String get shareNotToday;

  /// No description provided for @shareZeroOverlapped.
  ///
  /// In en, this message translates to:
  /// **'0 overlapped'**
  String get shareZeroOverlapped;

  /// No description provided for @shareRandomResultPlain.
  ///
  /// In en, this message translates to:
  /// **'Random result'**
  String get shareRandomResultPlain;

  /// No description provided for @shareResultIncoming.
  ///
  /// In en, this message translates to:
  /// **'Result update incoming!'**
  String get shareResultIncoming;

  /// No description provided for @shareWaitingForResults.
  ///
  /// In en, this message translates to:
  /// **'Waiting for results 🤞'**
  String get shareWaitingForResults;

  /// No description provided for @shareMyNumberPick.
  ///
  /// In en, this message translates to:
  /// **'My Number Pick'**
  String get shareMyNumberPick;

  /// No description provided for @shareLetsSee.
  ///
  /// In en, this message translates to:
  /// **'Let\'s see what happens 👀'**
  String get shareLetsSee;

  /// No description provided for @shareTheseAreMyNumbers.
  ///
  /// In en, this message translates to:
  /// **'These are my numbers ↑'**
  String get shareTheseAreMyNumbers;

  /// No description provided for @shareFunnyFail.
  ///
  /// In en, this message translates to:
  /// **'😂 Funny fail'**
  String get shareFunnyFail;

  /// No description provided for @shareCardPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Card Preview'**
  String get shareCardPreviewTitle;

  /// No description provided for @shareCardPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a style or keep the default option for {lotteryName}.'**
  String shareCardPreviewSubtitle(Object lotteryName);

  /// No description provided for @resultPanelNoOverlap.
  ///
  /// In en, this message translates to:
  /// **'No overlap in last past result ({date})'**
  String resultPanelNoOverlap(Object date);

  /// No description provided for @resultPanelBonusAppeared.
  ///
  /// In en, this message translates to:
  /// **'{bonusLabel} appeared in last past result ({date})'**
  String resultPanelBonusAppeared(Object bonusLabel, Object date);

  /// No description provided for @resultPanelOverlap.
  ///
  /// In en, this message translates to:
  /// **'{count}{bonusSuffix} overlapped in last past result ({date})'**
  String resultPanelOverlap(int count, Object bonusSuffix, Object date);

  /// No description provided for @bonusSuffix.
  ///
  /// In en, this message translates to:
  /// **' + {bonusLabel}'**
  String bonusSuffix(Object bonusLabel);

  /// No description provided for @notificationResultReadyChannel.
  ///
  /// In en, this message translates to:
  /// **'Result Ready'**
  String get notificationResultReadyChannel;

  /// No description provided for @notificationResultReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Result Ready 🎯'**
  String get notificationResultReadyTitle;

  /// No description provided for @notificationResultsReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} Results Ready 🎯'**
  String notificationResultsReadyTitle(int count);

  /// No description provided for @notificationSavedNumbersReady.
  ///
  /// In en, this message translates to:
  /// **'Your saved lottery numbers are ready to check'**
  String get notificationSavedNumbersReady;

  /// No description provided for @notificationDailyInsightsChannel.
  ///
  /// In en, this message translates to:
  /// **'Daily Insights'**
  String get notificationDailyInsightsChannel;

  /// No description provided for @notificationDailyInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Insight 📊'**
  String get notificationDailyInsightTitle;

  /// No description provided for @notificationWeeklySummaryChannel.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get notificationWeeklySummaryChannel;

  /// No description provided for @notificationWeeklySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary 📅'**
  String get notificationWeeklySummaryTitle;

  /// No description provided for @notificationResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifies when lottery draw results are available'**
  String get notificationResultsDescription;

  /// No description provided for @notificationDailyDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily draw trend observations'**
  String get notificationDailyDescription;

  /// No description provided for @notificationWeeklyDescription.
  ///
  /// In en, this message translates to:
  /// **'Weekly draw pattern summary'**
  String get notificationWeeklyDescription;

  /// No description provided for @lotteryHistoryNoRemoteCsv.
  ///
  /// In en, this message translates to:
  /// **'No remote CSV configured for {lottery}.'**
  String lotteryHistoryNoRemoteCsv(Object lottery);

  /// No description provided for @lotteryHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history CSV ({statusCode}).'**
  String lotteryHistoryLoadFailed(int statusCode);

  /// No description provided for @lotteryHistoryCsvEmpty.
  ///
  /// In en, this message translates to:
  /// **'History CSV is empty.'**
  String get lotteryHistoryCsvEmpty;

  /// No description provided for @lotteryHistoryNoValidRows.
  ///
  /// In en, this message translates to:
  /// **'No valid draw rows found in CSV.'**
  String get lotteryHistoryNoValidRows;

  /// No description provided for @lotteryHistoryParseFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse history CSV: {error}'**
  String lotteryHistoryParseFailed(Object error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
