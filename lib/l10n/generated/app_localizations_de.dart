// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'LottFun';

  @override
  String get brandTitle => 'NumberRun';

  @override
  String get brandSubtitle => 'Zahlensets aus vergangenen Aufzeichnungen';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonRetry => 'Wiederholen';

  @override
  String get commonShare => 'Teilen';

  @override
  String get commonCopy => 'Kopieren';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonSaved => 'Gespeichert';

  @override
  String get commonLoad => 'Laden';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonBonus => 'Bonus';

  @override
  String get commonSupp => 'Zus';

  @override
  String get commonView => 'Ansehen';

  @override
  String get commonLoading => 'Laden...';

  @override
  String get commonGenerating => 'Wird generiert…';

  @override
  String get commonPreparing => 'Wird vorbereitet...';

  @override
  String get countryUnitedStates => 'Vereinigte Staaten';

  @override
  String get countryAustralia => 'Australien';

  @override
  String get countryUnitedKingdom => 'Vereinigtes Königreich';

  @override
  String get countryCanada => 'Kanada';

  @override
  String get countryGermany => 'Deutschland';

  @override
  String get countryJapan => 'Japan';

  @override
  String get countryFrance => 'France';

  @override
  String get countryOther => 'Andere';

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
  String get lotteryLoto6 => 'Loto 6';

  @override
  String get lotteryLoto7 => 'Loto 7';

  @override
  String get lotteryFranceLoto => 'France Loto';

  @override
  String get lotteryFranceEuroMillions => 'EuroMillions';

  @override
  String get bonusPowerball => 'Powerball';

  @override
  String get bonusMegaBall => 'Mega Ball';

  @override
  String get bonusLuckyStars => 'Lucky Stars';

  @override
  String get bonusSuperzahl => 'Superzahl';

  @override
  String get bonusEuroNumbers => 'Eurozahlen';

  @override
  String get bonusChanceNumber => 'Chance Number';

  @override
  String get screenHistoryTitle => 'Verlauf';

  @override
  String get screenSettingsTitle => 'Einstellungen';

  @override
  String get screenSavedPicksTitle => 'Gespeicherte Tipps';

  @override
  String get screenAddMyNumbersTitle => 'Meine Zahlen hinzufügen';

  @override
  String get numberSelectionLabel => 'Zahlenauswahl';

  @override
  String get lotteryLabel => 'Lotterie';

  @override
  String get homeCardTitle => 'Zahlentipps';

  @override
  String get homeCardSubtitle => 'Wähle einen Stil oder generiere 3 Zahlensets';

  @override
  String get generateOnePick => '1 Tipp generieren';

  @override
  String get generateThreeNumberSets => '🎲 3 Zahlensets generieren';

  @override
  String get generateThreeNumberSetsDescription =>
      '3 Zahlensets kombinieren Ausgewogen + Beobachtet + Zufällig nur als Referenz.';

  @override
  String get pastOverlapReferenceNote =>
      '✨ Einige Auswahlen überschnitten sich mit mehreren Zahlen in vergangenen Ergebnissen (nur als Referenz)';

  @override
  String get generateEmptyPrompt =>
      'Generiere ein Zahlenset aus vergangenen Aufzeichnungen 🎲';

  @override
  String get numberSetReady => '✨ Dein Zahlenset ist bereit';

  @override
  String historicalSimilarityReference(int score) {
    return '📊 Historische Ähnlichkeit (nur Referenz): $score / 100';
  }

  @override
  String dayStreak(int count) {
    return '🔥 $count-Tage-Serie';
  }

  @override
  String countdownWithHourglass(Object text) {
    return '⏳ $text';
  }

  @override
  String get saveAll => 'Alle speichern';

  @override
  String get savedToSavedPicks => 'Zu gespeicherten Tipps hinzugefügt';

  @override
  String get pickSaved => 'Tipp gespeichert';

  @override
  String get alreadySaved => 'Bereits gespeichert';

  @override
  String get allThreePicksSaved => 'Alle 3 Tipps gespeichert';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert.';

  @override
  String pickCopiedToClipboard(Object label) {
    return '$label in die Zwischenablage kopiert.';
  }

  @override
  String get savedPicksTooltip => 'Gespeicherte Tipps';

  @override
  String get historyTooltip => 'Verlauf';

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String get addMyNumbersTooltip => 'Meine Zahlen hinzufügen';

  @override
  String get deleteTooltip => 'Löschen';

  @override
  String get collapseTooltip => 'Einklappen';

  @override
  String get styleBalanced => 'Ausgewogen';

  @override
  String get styleObservedPattern => 'Beobachtetes Muster';

  @override
  String get styleLessCommon => 'Weniger häufig';

  @override
  String get styleRandom => 'Zufällig';

  @override
  String get styleBalancedTagline => 'Ausgewogener Tipp';

  @override
  String get styleHotTagline => 'Beispiel-Mustertipp';

  @override
  String get styleColdTagline => 'Historisches Zahlenbeispiel';

  @override
  String get styleRandomTagline => 'Zufälliger Tipp';

  @override
  String get styleBalancedSubtitle =>
      'Gleichmäßige Verteilung über alle Zahlenbereiche.';

  @override
  String get styleHotSubtitle =>
      'Diese Zahlen wurden in vergangenen Ergebnissen häufiger beobachtet.';

  @override
  String get styleColdSubtitle =>
      'Diese Zahlen wurden in vergangenen Ergebnissen seltener beobachtet.';

  @override
  String get styleRandomSubtitle => 'Völlig zufällige Auswahl. Nur zum Spaß.';

  @override
  String get styleBalancedDescription =>
      'Gleichmäßige Verteilung über den Zahlenbereich';

  @override
  String get styleHotDescription =>
      'Basierend auf aktueller Häufigkeit in vergangenen Ergebnissen (nur als Referenz)';

  @override
  String get styleColdDescription =>
      'Basierend auf weniger häufigen historischen Zahlen (nur als Referenz)';

  @override
  String get styleRandomDescription => 'Zufällige Auswahl (nur als Referenz)';

  @override
  String get threePickExample => 'Beispieltipp';

  @override
  String get threePickExampleStar => '⭐ Beispieltipp';

  @override
  String get threePickCommonPattern => 'Häufiges Muster';

  @override
  String get threePickRandomSurprise => 'Zufällige Überraschung';

  @override
  String get threePickRandomSurpriseDice => '🎲 Zufällige Überraschung';

  @override
  String get threePickBalancedMicrocopy =>
      'Ausgewogene Auswahl basierend auf vergangenen Ergebnissen';

  @override
  String get threePickHotMicrocopy =>
      'Diese Zahlen wurden in vergangenen Ergebnissen häufiger beobachtet';

  @override
  String get threePickRandomMicrocopy =>
      'Zufällige Auswahl nur als Referenz 🎲';

  @override
  String get insightBalancedOne =>
      'Basierend auf vergangenen Daten zeigt dies eine ausgewogene Verteilung als Referenz';

  @override
  String get insightBalancedTwo =>
      'Die Historie deutet auf eine gleichmäßige Verteilung hin';

  @override
  String get insightBalancedThree =>
      'Ausgewogene Zahlenverteilung in vergangenen Ergebnissen gesehen';

  @override
  String get insightHotOne => 'Aktuelle Ergebnisse zeigen ähnliche Muster';

  @override
  String get insightHotTwo => 'Häufig in vergangenen Ergebnissen beobachtet';

  @override
  String get insightHotThree =>
      'Basierend auf vergangenen Ergebnissen wurde ein ähnliches Muster beobachtet';

  @override
  String get insightColdOne =>
      'Basierend auf vergangenen Ergebnissen wurden weniger häufige Zahlen beobachtet ❄️';

  @override
  String get insightColdTwo =>
      'Weniger häufige Zahlen aus vergangenen Ergebnissen';

  @override
  String get insightRandomOne => 'Manchmal macht Zufall Spaß 🎲';

  @override
  String get insightRandomTwo => 'Zufälliges Muster nur als Referenz';

  @override
  String get insightRandomThree => 'Zufällige Auswahl zum Spaß';

  @override
  String nextResultUpdateDays(int days) {
    return 'Nächste Ergebnisaktualisierung in ${days}T';
  }

  @override
  String nextResultUpdateHours(int hours) {
    return 'Nächste Ergebnisaktualisierung in ${hours}Std';
  }

  @override
  String get resultUpdateSoon => 'Ergebnisaktualisierung bald!';

  @override
  String get referencePickLabel => 'Referenztipp';

  @override
  String referencePickWithStyle(Object style) {
    return 'Referenztipp · $style';
  }

  @override
  String get manualPickLabel => '👤 Meine Zahlen';

  @override
  String trackingResult(Object date) {
    return 'Verfolgtes Ergebnis: $date';
  }

  @override
  String pickMainNumbers(int count, int min, int max) {
    return 'Wähle $count Zahlen  ($min–$max)';
  }

  @override
  String pickBonusNumbers(int count, Object label, int min, int max) {
    return 'Wähle $count $label  ($min–$max)';
  }

  @override
  String get saveMyNumbers => 'Meine Zahlen speichern';

  @override
  String pickMoreNumbers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zahlen',
      one: 'Zahl',
    );
    return 'Wähle $count weitere $_temp0';
  }

  @override
  String pickMoreBonus(int count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'n',
      one: '',
    );
    return 'Wähle $count weitere $label$_temp0';
  }

  @override
  String get disclaimerTitle => 'Nur zum Spaß — spiele verantwortungsvoll.';

  @override
  String get disclaimerBody =>
      'Diese App bietet Zahlenauswahlen nur basierend auf historischen Daten. Sie prognostiziert KEINE Ergebnisse, verbessert keine Chancen und garantiert keine Ergebnisse.';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsResults => 'Ergebnisse';

  @override
  String get settingsResultsSubtitle =>
      'Wenn vergangene Ergebnisse für deine gespeicherten Tipps verfügbar sind';

  @override
  String get settingsMyPicks => 'Meine Tipps';

  @override
  String get settingsMyPicksSubtitle =>
      'Wenn deine gespeicherten Zahlen in aktuellen Ergebnissen erscheinen';

  @override
  String get settingsDailyInsights => 'Tägliche Einblicke';

  @override
  String get settingsDailyInsightsSubtitle =>
      'Eine kurze Trendbeobachtung pro Tag';

  @override
  String get settingsWeeklySummary => 'Wöchentliche Zusammenfassung';

  @override
  String get settingsWeeklySummarySubtitle =>
      'Eine kurze Musterzusammenfassung jeden Sonntag';

  @override
  String get settingsNotificationTime => 'Benachrichtigungszeit';

  @override
  String settingsNotificationTimeSubtitle(Object time) {
    return 'Tägliche und wöchentliche Einblicke sind für $time geplant.';
  }

  @override
  String get settingsMaxNotifications =>
      'Max. 2 Benachrichtigungen pro Tag insgesamt.';

  @override
  String get settingsLanguage => 'Sprache';

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
  String get languageJapanese => '日本語';

  @override
  String get settingsAnalysisStyle => 'Analysestil';

  @override
  String get settingsAnalysisStyleSubtitle =>
      'Wie historische Trends gewichtet werden';

  @override
  String get analysisStyleRecentTrend => 'Aktueller Trend';

  @override
  String get analysisStyleRecentTrendDescription =>
      'Betont aktuelle Muster (0-12 Wochen: 70%, 13-52 Wochen: 20%, 1-5 Jahre: 10%)';

  @override
  String get analysisStyleBalanced => 'Ausgewogen';

  @override
  String get analysisStyleBalancedDescription =>
      'Gleichmäßige Berücksichtigung aller Zeiträume (0-12 Wochen: 50%, 13-52 Wochen: 30%, 1-5 Jahre: 20%)';

  @override
  String get analysisStyleLongTermPattern => 'Langzeitmuster';

  @override
  String get analysisStyleLongTermPatternDescription =>
      'Betont historische Muster (0-12 Wochen: 30%, 13-52 Wochen: 30%, 1-5 Jahre: 40%)';

  @override
  String get analysisStyleDisclaimer =>
      'Dies ändert nur die Gewichtung historischer Trends. Es verbessert nicht die Gewinnchancen.';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsHistoricalResultsOnly => 'Nur historische Ergebnisse';

  @override
  String get settingsHistoricalResultsOnlyBody =>
      'Alle Analysen basieren auf historischen Ergebnissen. Diese App bietet keine Vorhersagen und verbessert keine Ergebnisse.';

  @override
  String get clearAllSavedPicksTitle => 'Alle gespeicherten Tipps löschen?';

  @override
  String get clearAll => 'Alle löschen';

  @override
  String get pickDeleted => 'Tipp gelöscht';

  @override
  String get yourStats => 'Deine Statistiken';

  @override
  String resultsChecked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ergebnisse',
      one: 'Ergebnis',
    );
    return '$count $_temp0 geprüft';
  }

  @override
  String get top => 'Top';

  @override
  String get topWithTrophy => '🏆 Top';

  @override
  String get totalHits => 'Treffer Gesamt';

  @override
  String get similarityScore => 'Ähnlichkeitswert';

  @override
  String get myPick => '👤 Mein Tipp';

  @override
  String get noneYet => 'Noch keine';

  @override
  String mainCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'zahlen',
      one: 'zahl',
    );
    return '$count Haupt$_temp0';
  }

  @override
  String suppCountLabel(int count) {
    return '$count Zus';
  }

  @override
  String mainSuppCountLabel(int main, int supp) {
    return '$main+$supp';
  }

  @override
  String totalMainHits(int main) {
    String _temp0 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'zahlen',
      one: 'zahl',
    );
    return '$main Haupt$_temp0';
  }

  @override
  String totalMainSuppHits(int main, int supp) {
    String _temp0 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'zahlen',
      one: 'zahl',
    );
    return '$main Haupt$_temp0 · $supp Zus';
  }

  @override
  String get pending => 'Ausstehend';

  @override
  String pendingWithDate(Object date) {
    return 'Ausstehend · $date';
  }

  @override
  String copyPickText(
    Object lotteryName,
    Object label,
    Object main,
    Object bonus,
  ) {
    return '🎯 Mein $lotteryName Zahlenset\n$label\n\n$main$bonus\n\nZum Spaß generiert — NumberRun';
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
    return '$label\n$lotteryName: $main$bonus\nZum Spaß generiert — NumberRun 🎯';
  }

  @override
  String inlinePickBonusInline(Object numbers) {
    return ' + $numbers';
  }

  @override
  String get savedWithCheck => 'Gespeichert ✓';

  @override
  String historyPastResultsCount(int count) {
    return '$count vergangene Ergebnisse';
  }

  @override
  String get offlineModeSavedResults =>
      'Offline-Modus: gespeicherte Ergebnisse werden angezeigt';

  @override
  String offlineModeSavedResultsFrom(Object date) {
    return 'Offline-Modus: gespeicherte Ergebnisse von $date werden angezeigt';
  }

  @override
  String get noHistoryData => 'Noch keine Verlaufsdaten verfügbar.';

  @override
  String get noInternetNoSavedHistory =>
      'Keine Internetverbindung und noch kein gespeicherter Lotterieverlauf.';

  @override
  String get noInternetNoSavedResultHistory =>
      'Keine Internetverbindung und noch kein gespeicherter Ergebnisverlauf.';

  @override
  String get failedToLoadHistory => 'Laden des Verlaufs fehlgeschlagen.';

  @override
  String get recentPatternsTitle => 'Aktuelle Muster vergangener Ergebnisse';

  @override
  String recentPatternsSubtitle(int count) {
    return 'Basierend auf den letzten $count vergangenen Ergebnissen';
  }

  @override
  String get historicalComparisonOnly =>
      'Nur historischer Vergleich · keine Garantie für Ergebnisse';

  @override
  String get frequentNumbers => 'Häufig beobachtete Zahlen';

  @override
  String get frequentNumbersTooltip =>
      'Häufiger in vergangenen Ergebnissen beobachtet';

  @override
  String get lessCommonNumbers => 'Weniger häufige Zahlen';

  @override
  String get lessCommonNumbersTooltip =>
      'Seltener in vergangenen Ergebnissen beobachtet';

  @override
  String get avgSum => 'Durchschn. Summe';

  @override
  String get oddEven => 'Ungerade/Gerade';

  @override
  String get lowHigh => 'Niedrig/Hoch';

  @override
  String get avgConsecPairs => 'Durchschn. aufeinand. Paare';

  @override
  String get notEnoughHistory =>
      'Nicht genug vergangene Ergebnisse für Analyse.';

  @override
  String get patternNotable => 'Bemerkenswertes Muster';

  @override
  String get patternBalanced => 'Ausgewogen';

  @override
  String get patternRandomLike => 'Zufallsartig';

  @override
  String get odd => 'ungerade';

  @override
  String get even => 'gerade';

  @override
  String get low => 'niedrig';

  @override
  String get high => 'hoch';

  @override
  String get dailyInsightTitle => 'Heutiger Einblick';

  @override
  String get savedPicksAnalysisTitle => 'Analyse meiner gespeicherten Tipps';

  @override
  String get savedPicksAnalysisSubtitle =>
      'Verglichen mit den letzten 20 vergangenen Ergebnissen · nur Vergleich nach Ergebnis';

  @override
  String get topOverlap => 'Höchste Übereinstimmung';

  @override
  String numbersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zahlen',
      one: 'Zahl',
    );
    return '$count $_temp0';
  }

  @override
  String get avgOverlap => 'Durchschn. Übereinstimmung';

  @override
  String get perPastResult => 'pro vergangenem Ergebnis';

  @override
  String get oftenPicked => 'Oft gewählt';

  @override
  String get inRecentDraws => 'In aktuellen Ziehungen';

  @override
  String get overlapLevelHigh => 'Übereinstimmungsstufe: Hoch';

  @override
  String get overlapLevelMedium => 'Übereinstimmungsstufe: Mittel';

  @override
  String get overlapLevelLow => 'Übereinstimmungsstufe: Niedrig';

  @override
  String get historicalPatternNotEnough =>
      'Nicht genug Verlauf für Musteranalyse (52+ vergangene Ziehungen erforderlich).';

  @override
  String get historicalPatternTitle => 'Historischer Mustervergleich';

  @override
  String get historicalPatternSubtitle =>
      'Basierend auf vergangenen Ergebnissen der letzten 5 Jahre';

  @override
  String get trendComparison => 'Trendvergleich';

  @override
  String get observedLessCommonComparison =>
      'Beobachtet/weniger häufig Vergleich';

  @override
  String get oddEvenStructure => 'Ungerade/Gerade-Struktur';

  @override
  String get lowHighStructure => 'Niedrig/Hoch-Struktur';

  @override
  String get sumRange => 'Summenbereich';

  @override
  String get consecutivePairs => 'Aufeinanderfolgende Paare';

  @override
  String consecutivePairCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Paare',
      one: 'Paar',
    );
    return '$count aufeinand. $_temp0';
  }

  @override
  String get topSimilarPastResults =>
      'Top 10 ähnliche vergangene Ergebnisse (nur als Referenz)';

  @override
  String similarSharedNumbers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zahlen stimmten überein',
      one: 'Zahl stimmte überein',
    );
    return '$count $_temp0';
  }

  @override
  String similarStructuralSimilarity(Object percent) {
    return '$percent% strukturelle Ähnlichkeit';
  }

  @override
  String observedMoreLessCommonCounts(int hotCount, int coldCount) {
    return '🔥 $hotCount häufiger beobachtet · ❄️ $coldCount weniger häufig';
  }

  @override
  String get historicalPatternStrong =>
      'Starker Vergleich mit historischen Mustern (nur als Referenz)';

  @override
  String get historicalPatternModerate =>
      'Mäßiger Vergleich mit historischen Mustern (nur als Referenz)';

  @override
  String get historicalPatternLimited =>
      'Begrenzter Vergleich mit historischen Mustern (nur als Referenz)';

  @override
  String get drawResult => 'ZIEHUNGSERGEBNIS';

  @override
  String get supplementary => 'ZUSATZZAHLEN';

  @override
  String get yourNumbers => 'DEINE ZAHLEN';

  @override
  String get noMainMatched => 'Keine Hauptzahl getroffen';

  @override
  String get checkOfficialResults => 'Prüfe offizielle Ergebnisse für Details';

  @override
  String get noNumbersMatched => 'Keine Zahlen getroffen';

  @override
  String bonusMatched(Object label) {
    return '$label getroffen';
  }

  @override
  String matchedCount(int count) {
    return '$count getroffen';
  }

  @override
  String matchedCountWithBonus(int count, Object label) {
    return '$count getroffen + $label';
  }

  @override
  String noMainWithSupp(int count) {
    return 'Keine Haupt · ${count}Zus';
  }

  @override
  String matchedWithSupp(int main, int supp) {
    return '$main getroffen + ${supp}Zus';
  }

  @override
  String get noMatch => 'Kein Treffer';

  @override
  String get levelLightHit => 'Leichter Treffer';

  @override
  String get levelNice => 'Gut';

  @override
  String get levelSolid => 'Solide';

  @override
  String get levelStrong => 'Stark';

  @override
  String get levelGreat => 'Großartig';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get belowTypicalRange => 'Unter typischem Bereich';

  @override
  String get aboveTypicalRange => 'Über typischem Bereich';

  @override
  String get withinTypicalRange => 'Innerhalb typischem Bereich';

  @override
  String get drawAnalysisNotEnough =>
      'Nicht genug Ziehungsverlauf für Analyse.';

  @override
  String get drawAnalysisNoSavedPicks =>
      'Keine gespeicherten Tipps oder Ziehungsverlauf zum Vergleichen.';

  @override
  String get recentDrawsConcentrated =>
      'Aktuelle Ziehungen zeigen höhere Aktivität bei wenigen Zahlen — eine bemerkenswerte Konzentration in diesem Zeitraum.';

  @override
  String get periodMidRangeActive =>
      'Dieser Zeitraum zeigt höhere Aktivität bei mehreren Zahlen im mittleren Bereich.';

  @override
  String get recentDrawsHigherRange =>
      'Aktuelle Ziehungen tendierten zu Zahlen im höheren Bereich.';

  @override
  String get recentDrawsLowerRange =>
      'Aktuelle Ziehungen tendierten zu Zahlen im niedrigeren Bereich.';

  @override
  String get recentDrawsModerateSpread =>
      'Aktuelle Ziehungen sind ziemlich ausgewogen mit mäßiger Streuung über Zahlen.';

  @override
  String get recentDrawsNoStrongPattern =>
      'Aktuelle Ziehungen sind ziemlich ausgewogen ohne starkes erkanntes Muster.';

  @override
  String get weeklyNotableConcentration =>
      'Diese Woche zeigte eine bemerkenswerte Konzentration bei wenigen Zahlen.';

  @override
  String get weeklyModerateSpread =>
      'Diese Woche zeigte eine ausgewogene Verteilung mit mäßiger Streuung.';

  @override
  String get weeklyNoStrongTrend =>
      'Diese Woche zeigte eine ausgewogene Verteilung ohne starken Trend.';

  @override
  String dailyInsightStrongDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
  ) {
    return '$lotteryName: Basierend auf den letzten $drawCount Ziehungen sind die aktivsten Zahlen $hotNumbers.';
  }

  @override
  String dailyInsightMidRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
  ) {
    return '$lotteryName: Die letzten $drawCount Ziehungen zeigen mehr Aktivität im mittleren Bereich. Aktive Zahlen: $hotNumbers.';
  }

  @override
  String dailyInsightHigherRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object averageSum,
  ) {
    return '$lotteryName: Die letzten $drawCount Ziehungen tendieren zu höheren Zahlen, mit einer durchschnittlichen Hauptzahlensumme von $averageSum.';
  }

  @override
  String dailyInsightLowerRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object averageSum,
  ) {
    return '$lotteryName: Die letzten $drawCount Ziehungen tendieren zu niedrigeren Zahlen, mit einer durchschnittlichen Hauptzahlensumme von $averageSum.';
  }

  @override
  String dailyInsightBalancedDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object oddEvenPattern,
  ) {
    return '$lotteryName: Die letzten $drawCount Ziehungen wirken ausgewogen. Aktive Zahlen: $hotNumbers; häufige Struktur: $oddEvenPattern.';
  }

  @override
  String dailyInsightNoTrendDynamic(
    Object lotteryName,
    int drawCount,
    Object oddEvenPattern,
  ) {
    return '$lotteryName: Kein starkes Muster in den letzten $drawCount Ziehungen. Häufige Struktur: $oddEvenPattern.';
  }

  @override
  String weeklySummaryStrongDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object oddEvenPattern,
  ) {
    return '$lotteryName: Wochenübersicht basierend auf den letzten $drawCount Ziehungen. Heiße Zahlen: $hotNumbers; häufige Struktur: $oddEvenPattern.';
  }

  @override
  String weeklySummaryBalancedDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object lowHighPattern,
  ) {
    return '$lotteryName: Wochenübersicht basierend auf den letzten $drawCount Ziehungen. Heiße Zahlen: $hotNumbers; Bereichsmuster: $lowHighPattern.';
  }

  @override
  String weeklySummaryNoTrendDynamic(
    Object lotteryName,
    int drawCount,
    Object oddEvenPattern,
    Object lowHighPattern,
  ) {
    return '$lotteryName: Die Wochenübersicht der letzten $drawCount Ziehungen zeigt keinen starken Trend. Struktur: $oddEvenPattern; Bereich: $lowHighPattern.';
  }

  @override
  String get savedPicksModerate =>
      'Deine gespeicherten Tipps stimmten mäßig mit aktuellen Ziehungen überein.';

  @override
  String get savedNumbersAppeared =>
      'Mehrere deiner gespeicherten Zahlen erschienen in aktuellen Ergebnissen.';

  @override
  String get savedPicksLimited =>
      'Deine gespeicherten Tipps zeigen begrenzte Übereinstimmung mit aktuellen Ziehungsergebnissen.';

  @override
  String get drawStrongHistoricalComparison =>
      'Diese Ziehung zeigt einen starken Vergleich mit historischen Mustern der letzten 5 Jahre.';

  @override
  String get drawModerateHistoricalComparison =>
      'Diese Ziehung zeigt einen mäßigen Vergleich mit historischen Verteilungsmustern.';

  @override
  String get drawLimitedHistoricalComparison =>
      'Diese Ziehung zeigt einen begrenzten Vergleich mit typischen historischen Mustern.';

  @override
  String get generatedForFunHistoricalPatterns =>
      'Zum Spaß generiert mit historischen Mustern.';

  @override
  String get suppShort => 'Z';

  @override
  String mainAndBonusMatched(int main, Object bonusLabel) {
    String _temp0 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'zahlen',
      one: 'zahl',
    );
    return '$main Haupt$_temp0 + $bonusLabel getroffen';
  }

  @override
  String mainMatched(int main) {
    String _temp0 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'zahlen',
      one: 'zahl',
    );
    return '$main Haupt$_temp0 getroffen';
  }

  @override
  String suppMatched(int supp) {
    return '$supp Zus getroffen';
  }

  @override
  String mainAndSuppMatched(int main, int supp) {
    String _temp0 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'zahlen',
      one: 'zahl',
    );
    return '$main Haupt$_temp0 + $supp Zus getroffen';
  }

  @override
  String get shareNearMatch => '🔥 Fast getroffen!';

  @override
  String get shareOnlyOneAway => 'Nur eine Zahl daneben 👀';

  @override
  String get shareCanYouBeatThis => 'Kannst du das toppen? 👀';

  @override
  String get shareNotBad => '🎯 Nicht schlecht!';

  @override
  String shareOfMainCount(int count) {
    return 'von $count';
  }

  @override
  String get shareTemplate => 'Vorlage';

  @override
  String get shareReferencePick => '⭐ Referenztipp';

  @override
  String get sharePng => 'PNG teilen';

  @override
  String get shareDefaultPick => 'Mein Zahlentipp 🎯 — Generiert von NumberRun';

  @override
  String get shareDefaultPicks =>
      'Meine Zahlentipps 🎯 — Generiert von NumberRun';

  @override
  String get shareNumberComparison => '🔥 Zahlenvergleich von NumberRun';

  @override
  String get shareNumberOverlap => '🎯 Zahlenübereinstimmung von NumberRun';

  @override
  String get shareRandomResult => '😆 Zufälliges Ergebnis von NumberRun';

  @override
  String get shareTemplateFireLabel => '🔥 Fast getroffen';

  @override
  String get shareTemplateElectricLabel => '🎯 Zahlenübereinstimmung';

  @override
  String get shareTemplateWarmLabel => '😂 Zufälliges Ergebnis';

  @override
  String get shareTemplateFireDescription =>
      'Dramatische Gold-auf-Dunkel-Karte für knappe Treffer und starke Trefferserien.';

  @override
  String get shareTemplateElectricDescription =>
      'Saubere Neon-Statistikkarte für kleinere Gewinne und Teiltreffer.';

  @override
  String get shareTemplateWarmDescription =>
      'Verspielte Motivationskarte für ausstehende Ziehungen, Fehlversuche oder nur zum Teilen des Tipps.';

  @override
  String get shareNotToday => 'Heute nicht';

  @override
  String get shareZeroOverlapped => '0 getroffen';

  @override
  String get shareRandomResultPlain => 'Zufälliges Ergebnis';

  @override
  String get shareResultIncoming => 'Ergebnisaktualisierung kommt!';

  @override
  String get shareWaitingForResults => 'Warte auf Ergebnisse 🤞';

  @override
  String get shareMyNumberPick => 'Mein Zahlentipp';

  @override
  String get shareLetsSee => 'Mal sehen was passiert 👀';

  @override
  String get shareTheseAreMyNumbers => 'Das sind meine Zahlen ↑';

  @override
  String get shareFunnyFail => '😂 Lustiger Fehlschlag';

  @override
  String get shareCardPreviewTitle => 'Vorschau der Freigabekarte';

  @override
  String shareCardPreviewSubtitle(Object lotteryName) {
    return 'Wähle einen Stil oder behalte die Standardoption für $lotteryName.';
  }

  @override
  String resultPanelNoOverlap(Object date) {
    return 'Keine Übereinstimmung im letzten vergangenen Ergebnis ($date)';
  }

  @override
  String resultPanelBonusAppeared(Object bonusLabel, Object date) {
    return '$bonusLabel erschien im letzten vergangenen Ergebnis ($date)';
  }

  @override
  String resultPanelOverlap(int count, Object bonusSuffix, Object date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'n',
      one: '',
    );
    return '$count$bonusSuffix stimmte$_temp0 im letzten vergangenen Ergebnis überein ($date)';
  }

  @override
  String bonusSuffix(Object bonusLabel) {
    return ' + $bonusLabel';
  }

  @override
  String get notificationResultReadyChannel => 'Ergebnis Bereit';

  @override
  String get notificationResultReadyTitle => 'Ergebnis Bereit 🎯';

  @override
  String notificationResultsReadyTitle(int count) {
    return '$count Ergebnisse Bereit 🎯';
  }

  @override
  String get notificationSavedNumbersReady =>
      'Deine gespeicherten Lottozahlen sind bereit zum Prüfen';

  @override
  String get notificationDailyInsightsChannel => 'Tägliche Einblicke';

  @override
  String get notificationDailyInsightTitle => 'Heutiger Einblick 📊';

  @override
  String get notificationWeeklySummaryChannel => 'Wöchentliche Zusammenfassung';

  @override
  String get notificationWeeklySummaryTitle =>
      'Wöchentliche Zusammenfassung 📅';

  @override
  String get notificationResultsDescription =>
      'Benachrichtigt wenn Lottoziehungsergebnisse verfügbar sind';

  @override
  String get notificationDailyDescription =>
      'Tägliche Ziehungstrendbeobachtungen';

  @override
  String get notificationWeeklyDescription =>
      'Wöchentliche Ziehungsmusterzusammenfassung';

  @override
  String lotteryHistoryNoRemoteCsv(Object lottery) {
    return 'Keine Remote-CSV für $lottery konfiguriert.';
  }

  @override
  String lotteryHistoryLoadFailed(int statusCode) {
    return 'Laden der Verlaufs-CSV fehlgeschlagen ($statusCode).';
  }

  @override
  String get lotteryHistoryCsvEmpty => 'Verlaufs-CSV ist leer.';

  @override
  String get lotteryHistoryNoValidRows =>
      'Keine gültigen Ziehungszeilen in CSV gefunden.';

  @override
  String lotteryHistoryParseFailed(Object error) {
    return 'Parsen der Verlaufs-CSV fehlgeschlagen: $error';
  }

  @override
  String get completeMyNumbers => 'Meine Zahlen Vervollständigen';

  @override
  String get completeMyNumbersTitle => 'Sperren Sie Ihre Glückszahlen';

  @override
  String get completeMyNumbersSubtitle =>
      'Wählen Sie die Zahlen aus, die Sie behalten möchten, und wir generieren den Rest basierend auf Ihrer gewählten Strategie.';

  @override
  String get selectYourNumbers => 'Ihre Zahlen';

  @override
  String tapToLockNumbers(int locked, int total) {
    return 'Tippen zum Sperren ($locked/$total)';
  }

  @override
  String get bonusNumbers => 'Bonuszahlen';

  @override
  String tapToLockBonusNumbers(int locked, int total) {
    return 'Tippen zum Sperren Bonus ($locked/$total)';
  }

  @override
  String get generationStrategy => 'Generierungsstrategie';

  @override
  String get generateAllNumbers => 'Zahlen Generieren';

  @override
  String get completeRemainingNumbers => 'Meine Zahlen Vervollständigen';

  @override
  String get yourCompletedNumbers => 'Ihre Vollständigen Zahlen';

  @override
  String get locked => 'Ihre Auswahl';

  @override
  String get generated => 'Generiert';

  @override
  String maxNumbersSelected(int max) {
    return 'Maximal $max Zahlen erlaubt';
  }

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get regenerate => 'Erneut Versuchen';

  @override
  String get completeMyNumbersDisclaimer =>
      'Diese Funktion dient nur zu Unterhaltungs- und statistischen Referenzzwecken. Generierte Zahlen basieren auf historischen Daten und erhöhen nicht Ihre Gewinnchancen.';

  @override
  String get numberAlreadySelected =>
      'Diese Nummer ist bereits im anderen Abschnitt ausgewählt';

  @override
  String get duplicateNumbersError =>
      'Kann nicht generieren: Doppelte Zahlen gefunden. Stellen Sie sicher, dass keine Zahl sowohl im Haupt- als auch im Zusatzabschnitt vorkommt.';
}
