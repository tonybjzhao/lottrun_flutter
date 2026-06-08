// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'LottFun';

  @override
  String get brandTitle => 'NumberRun';

  @override
  String get brandSubtitle => 'Combinaisons issues des anciens tirages';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonShare => 'Partager';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonSaved => 'Enregistré';

  @override
  String get commonLoad => 'Charger';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonBonus => 'Bonus';

  @override
  String get commonSupp => 'Suppl.';

  @override
  String get commonView => 'Voir';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get commonGenerating => 'Génération…';

  @override
  String get commonPreparing => 'Préparation...';

  @override
  String get countryUnitedStates => 'États-Unis';

  @override
  String get countryAustralia => 'Australie';

  @override
  String get countryUnitedKingdom => 'Royaume-Uni';

  @override
  String get countryCanada => 'Canada';

  @override
  String get countryGermany => 'Allemagne';

  @override
  String get countryOther => 'Autre';

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
  String get bonusEuroNumbers => 'Numéros Euro';

  @override
  String get screenHistoryTitle => 'Historique';

  @override
  String get screenSettingsTitle => 'Réglages';

  @override
  String get screenSavedPicksTitle => 'Numéros enregistrés';

  @override
  String get screenAddMyNumbersTitle => 'Ajouter mes numéros';

  @override
  String get numberSelectionLabel => 'Sélection de numéros';

  @override
  String get lotteryLabel => 'Loterie';

  @override
  String get homeCardTitle => 'Numéros';

  @override
  String get homeCardSubtitle =>
      'Choisissez un style ou générez 3 combinaisons';

  @override
  String get generateOnePick => 'Générer 1 combinaison';

  @override
  String get generateThreeNumberSets => '🎲 Générer 3 combinaisons';

  @override
  String get generateThreeNumberSetsDescription =>
      'Les 3 combinaisons associent les styles Équilibré, Observé et Aléatoire, à titre indicatif seulement.';

  @override
  String get pastOverlapReferenceNote =>
      '✨ Certaines sélections ont recoupé plusieurs numéros dans les anciens résultats (à titre indicatif seulement)';

  @override
  String get generateEmptyPrompt =>
      'Générer une combinaison à partir des anciens résultats 🎲';

  @override
  String get numberSetReady => '✨ Votre combinaison est prête';

  @override
  String historicalSimilarityReference(int score) {
    return '📊 Similarité historique (indicative) : $score / 100';
  }

  @override
  String dayStreak(int count) {
    return '🔥 Série de $count jours';
  }

  @override
  String countdownWithHourglass(Object text) {
    return '⏳ $text';
  }

  @override
  String get saveAll => 'Tout enregistrer';

  @override
  String get savedToSavedPicks => 'Enregistré dans les numéros sauvegardés';

  @override
  String get pickSaved => 'Combinaison enregistrée';

  @override
  String get alreadySaved => 'Déjà enregistrée';

  @override
  String get allThreePicksSaved => 'Les 3 combinaisons sont enregistrées';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers.';

  @override
  String pickCopiedToClipboard(Object label) {
    return '$label copié dans le presse-papiers.';
  }

  @override
  String get savedPicksTooltip => 'Numéros enregistrés';

  @override
  String get historyTooltip => 'Historique';

  @override
  String get settingsTooltip => 'Réglages';

  @override
  String get addMyNumbersTooltip => 'Ajouter mes numéros';

  @override
  String get deleteTooltip => 'Supprimer';

  @override
  String get collapseTooltip => 'Réduire';

  @override
  String get styleBalanced => 'Équilibré';

  @override
  String get styleObservedPattern => 'Motif observé';

  @override
  String get styleLessCommon => 'Moins fréquent';

  @override
  String get styleRandom => 'Aléatoire';

  @override
  String get styleBalancedTagline => 'Combinaison équilibrée';

  @override
  String get styleHotTagline => 'Exemple de motif';

  @override
  String get styleColdTagline => 'Exemple de numéros historiques rares';

  @override
  String get styleRandomTagline => 'Combinaison aléatoire';

  @override
  String get styleBalancedSubtitle =>
      'Répartition uniforme sur toutes les plages de numéros.';

  @override
  String get styleHotSubtitle =>
      'Ces numéros sont apparus plus souvent dans les anciens résultats.';

  @override
  String get styleColdSubtitle =>
      'Ces numéros sont apparus moins souvent dans les anciens résultats.';

  @override
  String get styleRandomSubtitle =>
      'Sélection entièrement aléatoire. Juste pour le plaisir.';

  @override
  String get styleBalancedDescription =>
      'Répartition équilibrée sur la plage de numéros';

  @override
  String get styleHotDescription =>
      'Basé sur la fréquence récente des anciens résultats (à titre indicatif)';

  @override
  String get styleColdDescription =>
      'Basé sur des numéros historiquement moins fréquents (à titre indicatif)';

  @override
  String get styleRandomDescription =>
      'Sélection aléatoire (à titre indicatif)';

  @override
  String get threePickExample => 'Exemple de combinaison';

  @override
  String get threePickExampleStar => '⭐ Exemple de combinaison';

  @override
  String get threePickCommonPattern => 'Motif courant';

  @override
  String get threePickRandomSurprise => 'Surprise aléatoire';

  @override
  String get threePickRandomSurpriseDice => '🎲 Surprise aléatoire';

  @override
  String get threePickBalancedMicrocopy =>
      'Sélection équilibrée basée sur les anciens résultats';

  @override
  String get threePickHotMicrocopy =>
      'Ces numéros sont apparus plus souvent dans les anciens résultats';

  @override
  String get threePickRandomMicrocopy =>
      'Sélection aléatoire à titre indicatif 🎲';

  @override
  String get insightBalancedOne =>
      'Selon les données passées, cela montre une répartition équilibrée à titre indicatif';

  @override
  String get insightBalancedTwo =>
      'L’historique indique une distribution régulière';

  @override
  String get insightBalancedThree =>
      'Répartition équilibrée observée dans les anciens résultats';

  @override
  String get insightHotOne =>
      'Les résultats récents montrent des motifs similaires';

  @override
  String get insightHotTwo => 'Souvent observé dans les anciens résultats';

  @override
  String get insightHotThree =>
      'Selon les anciens résultats, un motif similaire a été observé';

  @override
  String get insightColdOne =>
      'Selon les anciens résultats, des numéros moins fréquents ont été observés ❄️';

  @override
  String get insightColdTwo =>
      'Numéros moins fréquents issus des anciens résultats';

  @override
  String get insightRandomOne => 'Parfois, le hasard est amusant 🎲';

  @override
  String get insightRandomTwo => 'Motif aléatoire à titre indicatif';

  @override
  String get insightRandomThree => 'Sélection aléatoire pour le plaisir';

  @override
  String nextResultUpdateDays(int days) {
    return 'Prochaine mise à jour dans $days j';
  }

  @override
  String nextResultUpdateHours(int hours) {
    return 'Prochaine mise à jour dans $hours h';
  }

  @override
  String get resultUpdateSoon => 'Mise à jour bientôt !';

  @override
  String get referencePickLabel => 'Combinaison de référence';

  @override
  String referencePickWithStyle(Object style) {
    return 'Combinaison de référence · $style';
  }

  @override
  String get manualPickLabel => '👤 Mes numéros';

  @override
  String trackingResult(Object date) {
    return 'Résultat suivi : $date';
  }

  @override
  String pickMainNumbers(int count, int min, int max) {
    return 'Choisissez $count numéros ($min–$max)';
  }

  @override
  String pickBonusNumbers(int count, Object label, int min, int max) {
    return 'Choisissez $count $label ($min–$max)';
  }

  @override
  String get saveMyNumbers => 'Enregistrer mes numéros';

  @override
  String pickMoreNumbers(int count) {
    return 'Choisissez encore $count numéro(s)';
  }

  @override
  String pickMoreBonus(int count, Object label) {
    return 'Choisissez encore $count $label';
  }

  @override
  String get disclaimerTitle =>
      'Juste pour le plaisir — jouez de façon responsable.';

  @override
  String get disclaimerBody =>
      'Cette application fournit des sélections basées uniquement sur les données historiques. Elle ne prédit pas les résultats, n’améliore pas les chances et ne garantit aucun résultat.';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsResults => 'Résultats';

  @override
  String get settingsResultsSubtitle =>
      'Quand des résultats passés sont disponibles pour vos numéros enregistrés';

  @override
  String get settingsMyPicks => 'Mes numéros';

  @override
  String get settingsMyPicksSubtitle =>
      'Quand vos numéros enregistrés apparaissent dans les résultats récents';

  @override
  String get settingsDailyInsights => 'Aperçus quotidiens';

  @override
  String get settingsDailyInsightsSubtitle =>
      'Une courte observation de tendance par jour';

  @override
  String get settingsWeeklySummary => 'Résumé hebdomadaire';

  @override
  String get settingsWeeklySummarySubtitle =>
      'Un bref résumé des motifs chaque dimanche';

  @override
  String get settingsMaxNotifications =>
      'Maximum 2 notifications par jour au total.';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageChinese => 'Chinois';

  @override
  String get languageFrench => 'Français';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsHistoricalResultsOnly =>
      'Résultats historiques uniquement';

  @override
  String get settingsHistoricalResultsOnlyBody =>
      'Toutes les analyses sont basées sur les résultats historiques. Cette application ne fournit pas de prédictions et n’améliore pas les résultats.';

  @override
  String get clearAllSavedPicksTitle =>
      'Effacer tous les numéros enregistrés ?';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get pickDeleted => 'Combinaison supprimée';

  @override
  String get yourStats => 'Vos statistiques';

  @override
  String resultsChecked(int count) {
    return '$count résultat(s) vérifié(s)';
  }

  @override
  String get top => 'Meilleur';

  @override
  String get topWithTrophy => '🏆 Meilleur';

  @override
  String get totalHits => 'Total des correspondances';

  @override
  String get similarityScore => 'Score de similarité';

  @override
  String get myPick => '👤 Ma combinaison';

  @override
  String get noneYet => 'Aucun pour le moment';

  @override
  String mainCountLabel(int count) {
    return '$count principal(aux)';
  }

  @override
  String suppCountLabel(int count) {
    return '$count suppl.';
  }

  @override
  String mainSuppCountLabel(int main, int supp) {
    return '$main+$supp';
  }

  @override
  String totalMainHits(int main) {
    return '$main principal(aux)';
  }

  @override
  String totalMainSuppHits(int main, int supp) {
    return '$main principal(aux) · $supp suppl.';
  }

  @override
  String get pending => 'En attente';

  @override
  String pendingWithDate(Object date) {
    return 'En attente · $date';
  }

  @override
  String copyPickText(
    Object lotteryName,
    Object label,
    Object main,
    Object bonus,
  ) {
    return '🎯 Ma combinaison $lotteryName\n$label\n\n$main$bonus\n\nGénéré pour le plaisir — NumberRun';
  }

  @override
  String copyPickBonusLine(Object label, Object numbers) {
    return '\n+ $label : $numbers';
  }

  @override
  String inlinePickCopyText(
    Object label,
    Object lotteryName,
    Object main,
    Object bonus,
  ) {
    return '$label\n$lotteryName : $main$bonus\nGénéré pour le plaisir — NumberRun 🎯';
  }

  @override
  String inlinePickBonusInline(Object numbers) {
    return ' + $numbers';
  }

  @override
  String get savedWithCheck => 'Enregistré ✓';

  @override
  String historyPastResultsCount(int count) {
    return '$count résultats passés';
  }

  @override
  String get offlineModeSavedResults =>
      'Mode hors ligne : affichage des résultats enregistrés';

  @override
  String offlineModeSavedResultsFrom(Object date) {
    return 'Mode hors ligne : résultats enregistrés depuis $date';
  }

  @override
  String get noHistoryData =>
      'Aucune donnée historique disponible pour le moment.';

  @override
  String get noInternetNoSavedHistory =>
      'Aucune connexion Internet et aucun historique de loterie enregistré.';

  @override
  String get noInternetNoSavedResultHistory =>
      'Aucune connexion Internet et aucun historique de résultats enregistré.';

  @override
  String get failedToLoadHistory => 'Impossible de charger l’historique.';

  @override
  String get recentPatternsTitle => 'Motifs récents des anciens tirages';

  @override
  String recentPatternsSubtitle(int count) {
    return 'Basé sur les $count derniers résultats passés';
  }

  @override
  String get historicalComparisonOnly =>
      'Comparaison historique uniquement · aucun résultat garanti';

  @override
  String get frequentNumbers => 'Numéros fréquemment observés';

  @override
  String get frequentNumbersTooltip =>
      'Observés plus souvent dans les anciens résultats';

  @override
  String get lessCommonNumbers => 'Numéros moins fréquents';

  @override
  String get lessCommonNumbersTooltip =>
      'Observés moins souvent dans les anciens résultats';

  @override
  String get avgSum => 'Somme moy.';

  @override
  String get oddEven => 'Pair/impair';

  @override
  String get lowHigh => 'Bas/haut';

  @override
  String get avgConsecPairs => 'Paires conséc. moy.';

  @override
  String get notEnoughHistory => 'Pas assez d’historique pour l’analyse.';

  @override
  String get patternNotable => 'Motif notable';

  @override
  String get patternBalanced => 'Équilibré';

  @override
  String get patternRandomLike => 'Proche du hasard';

  @override
  String get odd => 'impair';

  @override
  String get even => 'pair';

  @override
  String get low => 'faible';

  @override
  String get high => 'élevé';

  @override
  String get dailyInsightTitle => 'Aperçu du jour';

  @override
  String get savedPicksAnalysisTitle => 'Analyse de mes numéros enregistrés';

  @override
  String get savedPicksAnalysisSubtitle =>
      'Comparé aux 20 derniers résultats passés · comparaison après tirage seulement';

  @override
  String get topOverlap => 'Meilleur recoupement';

  @override
  String numbersCount(int count) {
    return '$count numéro(s)';
  }

  @override
  String get avgOverlap => 'Recoupement moy.';

  @override
  String get perPastResult => 'par résultat passé';

  @override
  String get oftenPicked => 'Souvent choisi';

  @override
  String get inRecentDraws => 'Dans les tirages récents';

  @override
  String get overlapLevelHigh => 'Niveau de recoupement : élevé';

  @override
  String get overlapLevelMedium => 'Niveau de recoupement : moyen';

  @override
  String get overlapLevelLow => 'Niveau de recoupement : faible';

  @override
  String get historicalPatternNotEnough =>
      'Historique insuffisant pour l’analyse des motifs (52+ tirages passés requis).';

  @override
  String get historicalPatternTitle => 'Comparaison des motifs historiques';

  @override
  String get historicalPatternSubtitle =>
      'Basé sur les résultats passés des 5 dernières années';

  @override
  String get trendComparison => 'Comparaison de tendance';

  @override
  String get observedLessCommonComparison =>
      'Comparaison observé/moins fréquent';

  @override
  String get oddEvenStructure => 'Structure pair/impair';

  @override
  String get lowHighStructure => 'Structure bas/haut';

  @override
  String get sumRange => 'Plage de somme';

  @override
  String get consecutivePairs => 'Paires consécutives';

  @override
  String consecutivePairCount(int count) {
    return '$count paire(s) conséc.';
  }

  @override
  String get topSimilarPastResults =>
      'Top 10 des résultats passés similaires (à titre indicatif)';

  @override
  String similarSharedNumbers(int count) {
    return '$count numéro(s) recoupé(s)';
  }

  @override
  String similarStructuralSimilarity(Object percent) {
    return '$percent % de similarité structurelle';
  }

  @override
  String observedMoreLessCommonCounts(int hotCount, int coldCount) {
    return '🔥 $hotCount plus observé(s) · ❄️ $coldCount moins fréquent(s)';
  }

  @override
  String get historicalPatternStrong =>
      'Forte comparaison avec les motifs historiques (à titre indicatif)';

  @override
  String get historicalPatternModerate =>
      'Comparaison modérée avec les motifs historiques (à titre indicatif)';

  @override
  String get historicalPatternLimited =>
      'Comparaison limitée avec les motifs historiques (à titre indicatif)';

  @override
  String get drawResult => 'RÉSULTAT DU TIRAGE';

  @override
  String get supplementary => 'SUPPLÉMENTAIRE';

  @override
  String get yourNumbers => 'VOS NUMÉROS';

  @override
  String get noMainMatched => 'Aucun numéro principal';

  @override
  String get checkOfficialResults =>
      'Consultez les résultats officiels pour plus de détails';

  @override
  String get noNumbersMatched => 'Aucun numéro correspondant';

  @override
  String bonusMatched(Object label) {
    return '$label correspondant';
  }

  @override
  String matchedCount(int count) {
    return '$count correspondant(s)';
  }

  @override
  String matchedCountWithBonus(int count, Object label) {
    return '$count correspondant(s) + $label';
  }

  @override
  String noMainWithSupp(int count) {
    return 'Aucun principal · $count suppl.';
  }

  @override
  String matchedWithSupp(int main, int supp) {
    return '$main correspondant(s) + $supp suppl.';
  }

  @override
  String get noMatch => 'Aucune correspondance';

  @override
  String get levelLightHit => 'Petit coup';

  @override
  String get levelNice => 'Bien';

  @override
  String get levelSolid => 'Solide';

  @override
  String get levelStrong => 'Fort';

  @override
  String get levelGreat => 'Excellent';

  @override
  String get unknown => 'Inconnu';

  @override
  String get belowTypicalRange => 'Sous la plage typique';

  @override
  String get aboveTypicalRange => 'Au-dessus de la plage typique';

  @override
  String get withinTypicalRange => 'Dans la plage typique';

  @override
  String get drawAnalysisNotEnough =>
      'Pas assez d’historique de tirages pour l’analyse.';

  @override
  String get drawAnalysisNoSavedPicks =>
      'Aucun numéro enregistré ou historique de tirages à comparer.';

  @override
  String get recentDrawsConcentrated =>
      'Les tirages récents montrent une activité plus forte sur quelques numéros — concentration notable sur cette période.';

  @override
  String get periodMidRangeActive =>
      'Cette période montre une activité plus forte sur plusieurs numéros de milieu de plage.';

  @override
  String get recentDrawsHigherRange =>
      'Les tirages récents ont penché vers les numéros élevés.';

  @override
  String get recentDrawsLowerRange =>
      'Les tirages récents ont penché vers les numéros bas.';

  @override
  String get recentDrawsModerateSpread =>
      'Les tirages récents sont assez équilibrés avec une dispersion modérée.';

  @override
  String get recentDrawsNoStrongPattern =>
      'Les tirages récents sont assez équilibrés, sans motif fort détecté.';

  @override
  String get weeklyNotableConcentration =>
      'Cette semaine a montré une concentration notable autour de quelques numéros.';

  @override
  String get weeklyModerateSpread =>
      'Cette semaine a montré une distribution équilibrée avec une dispersion modérée.';

  @override
  String get weeklyNoStrongTrend =>
      'Cette semaine a montré une distribution équilibrée sans tendance forte.';

  @override
  String get savedPicksModerate =>
      'Vos numéros enregistrés correspondent modérément aux tirages récents.';

  @override
  String get savedNumbersAppeared =>
      'Plusieurs numéros enregistrés sont apparus dans les résultats récents.';

  @override
  String get savedPicksLimited =>
      'Vos numéros enregistrés montrent un recoupement limité avec les résultats récents.';

  @override
  String get drawStrongHistoricalComparison =>
      'Ce tirage présente une forte comparaison avec les motifs historiques des 5 dernières années.';

  @override
  String get drawModerateHistoricalComparison =>
      'Ce tirage présente une comparaison modérée avec les distributions historiques.';

  @override
  String get drawLimitedHistoricalComparison =>
      'Ce tirage présente une comparaison limitée avec les motifs historiques typiques.';

  @override
  String get generatedForFunHistoricalPatterns =>
      'Généré pour le plaisir à partir de motifs historiques.';

  @override
  String get suppShort => 'S';

  @override
  String mainAndBonusMatched(int main, Object bonusLabel) {
    return '$main principal(aux) + $bonusLabel correspondant';
  }

  @override
  String mainMatched(int main) {
    return '$main principal(aux) correspondant(s)';
  }

  @override
  String suppMatched(int supp) {
    return '$supp suppl. correspondant(s)';
  }

  @override
  String mainAndSuppMatched(int main, int supp) {
    return '$main principal(aux) + $supp suppl. correspondant(s)';
  }

  @override
  String get shareNearMatch => '🔥 Presque !';

  @override
  String get shareOnlyOneAway => 'À un numéro près 👀';

  @override
  String get shareCanYouBeatThis => 'Pouvez-vous faire mieux ? 👀';

  @override
  String get shareNotBad => '🎯 Pas mal !';

  @override
  String shareOfMainCount(int count) {
    return 'sur $count';
  }

  @override
  String get shareTemplate => 'Modèle';

  @override
  String get shareReferencePick => '⭐ Combinaison de référence';

  @override
  String get sharePng => 'Partager le PNG';

  @override
  String get shareDefaultPick => 'Ma combinaison 🎯 — Générée par NumberRun';

  @override
  String get shareDefaultPicks =>
      'Mes combinaisons 🎯 — Générées par NumberRun';

  @override
  String get shareNumberComparison => '🔥 Comparaison de numéros par NumberRun';

  @override
  String get shareNumberOverlap => '🎯 Recoupement de numéros par NumberRun';

  @override
  String get shareRandomResult => '😆 Résultat aléatoire de NumberRun';

  @override
  String get shareTemplateFireLabel => '🔥 Recoupement proche';

  @override
  String get shareTemplateElectricLabel => '🎯 Recoupement de numéros';

  @override
  String get shareTemplateWarmLabel => '😂 Résultat aléatoire';

  @override
  String get shareTemplateFireDescription =>
      'Carte dorée sur fond sombre pour les quasi-réussites et les fortes séries.';

  @override
  String get shareTemplateElectricDescription =>
      'Carte de statistiques néon propre pour les petites réussites et correspondances partielles.';

  @override
  String get shareTemplateWarmDescription =>
      'Carte motivante et ludique pour les tirages en attente, les manqués ou le partage simple.';

  @override
  String get shareNotToday => 'Pas aujourd’hui';

  @override
  String get shareZeroOverlapped => '0 recoupement';

  @override
  String get shareRandomResultPlain => 'Résultat aléatoire';

  @override
  String get shareResultIncoming => 'Résultat bientôt disponible !';

  @override
  String get shareWaitingForResults => 'En attente des résultats 🤞';

  @override
  String get shareMyNumberPick => 'Ma combinaison';

  @override
  String get shareLetsSee => 'Voyons ce qui se passe 👀';

  @override
  String get shareTheseAreMyNumbers => 'Voici mes numéros ↑';

  @override
  String get shareFunnyFail => '😂 Manqué amusant';

  @override
  String get shareCardPreviewTitle => 'Aperçu de la carte à partager';

  @override
  String shareCardPreviewSubtitle(Object lotteryName) {
    return 'Choisissez un style ou gardez l’option par défaut pour $lotteryName.';
  }

  @override
  String resultPanelNoOverlap(Object date) {
    return 'Aucun recoupement dans le dernier résultat passé ($date)';
  }

  @override
  String resultPanelBonusAppeared(Object bonusLabel, Object date) {
    return '$bonusLabel est apparu dans le dernier résultat passé ($date)';
  }

  @override
  String resultPanelOverlap(int count, Object bonusSuffix, Object date) {
    return '$count$bonusSuffix recoupé(s) dans le dernier résultat passé ($date)';
  }

  @override
  String bonusSuffix(Object bonusLabel) {
    return ' + $bonusLabel';
  }

  @override
  String get notificationResultReadyChannel => 'Résultat prêt';

  @override
  String get notificationResultReadyTitle => 'Résultat prêt 🎯';

  @override
  String notificationResultsReadyTitle(int count) {
    return '$count résultats prêts 🎯';
  }

  @override
  String get notificationSavedNumbersReady =>
      'Vos numéros enregistrés sont prêts à vérifier';

  @override
  String get notificationDailyInsightsChannel => 'Aperçus quotidiens';

  @override
  String get notificationDailyInsightTitle => 'Aperçu du jour 📊';

  @override
  String get notificationWeeklySummaryChannel => 'Résumé hebdomadaire';

  @override
  String get notificationWeeklySummaryTitle => 'Résumé hebdomadaire 📅';

  @override
  String get notificationResultsDescription =>
      'Préviens lorsque les résultats du tirage sont disponibles';

  @override
  String get notificationDailyDescription =>
      'Observations quotidiennes de tendance';

  @override
  String get notificationWeeklyDescription =>
      'Résumé hebdomadaire des motifs de tirage';

  @override
  String lotteryHistoryNoRemoteCsv(Object lottery) {
    return 'Aucun CSV distant configuré pour $lottery.';
  }

  @override
  String lotteryHistoryLoadFailed(int statusCode) {
    return 'Échec du chargement du CSV historique ($statusCode).';
  }

  @override
  String get lotteryHistoryCsvEmpty => 'Le CSV historique est vide.';

  @override
  String get lotteryHistoryNoValidRows =>
      'Aucune ligne de tirage valide trouvée dans le CSV.';

  @override
  String lotteryHistoryParseFailed(Object error) {
    return 'Échec de l’analyse du CSV historique : $error';
  }
}
