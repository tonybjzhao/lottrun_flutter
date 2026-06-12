// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'LottFun';

  @override
  String get brandTitle => 'NumberRun';

  @override
  String get brandSubtitle => 'Conjuntos de números de registros pasados';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonShare => 'Compartir';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonSaved => 'Guardado';

  @override
  String get commonLoad => 'Cargar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonBonus => 'Bono';

  @override
  String get commonSupp => 'Supl';

  @override
  String get commonView => 'Ver';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonGenerating => 'Generando…';

  @override
  String get commonPreparing => 'Preparando...';

  @override
  String get countryUnitedStates => 'Estados Unidos';

  @override
  String get countryAustralia => 'Australia';

  @override
  String get countryUnitedKingdom => 'Reino Unido';

  @override
  String get countryCanada => 'Canadá';

  @override
  String get countryGermany => 'Alemania';

  @override
  String get countryOther => 'Otro';

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
  String get bonusEuroNumbers => 'Números Euro';

  @override
  String get screenHistoryTitle => 'Historial';

  @override
  String get screenSettingsTitle => 'Configuración';

  @override
  String get screenSavedPicksTitle => 'Números Guardados';

  @override
  String get screenAddMyNumbersTitle => 'Agregar Mis Números';

  @override
  String get numberSelectionLabel => 'Selección de números';

  @override
  String get lotteryLabel => 'Lotería';

  @override
  String get homeCardTitle => 'Selecciones de Números';

  @override
  String get homeCardSubtitle =>
      'Elige un estilo o genera 3 conjuntos de números';

  @override
  String get generateOnePick => 'Generar 1 Selección';

  @override
  String get generateThreeNumberSets => '🎲 Generar 3 Conjuntos de Números';

  @override
  String get generateThreeNumberSetsDescription =>
      '3 conjuntos de números combinan estilos Equilibrado + Observado + Aleatorio solo como referencia.';

  @override
  String get pastOverlapReferenceNote =>
      '✨ Algunas selecciones coincidieron con varios números en resultados pasados (solo como referencia)';

  @override
  String get generateEmptyPrompt =>
      'Generar un conjunto de números de registros pasados 🎲';

  @override
  String get numberSetReady => '✨ Tu conjunto de números está listo';

  @override
  String historicalSimilarityReference(int score) {
    return '📊 Similitud histórica (solo referencia): $score / 100';
  }

  @override
  String dayStreak(int count) {
    return '🔥 Racha de $count días';
  }

  @override
  String countdownWithHourglass(Object text) {
    return '⏳ $text';
  }

  @override
  String get saveAll => 'Guardar Todo';

  @override
  String get savedToSavedPicks => 'Guardado en Números Guardados';

  @override
  String get pickSaved => 'Selección guardada';

  @override
  String get alreadySaved => 'Ya guardado';

  @override
  String get allThreePicksSaved => 'Las 3 selecciones guardadas';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles.';

  @override
  String pickCopiedToClipboard(Object label) {
    return '$label copiado al portapapeles.';
  }

  @override
  String get savedPicksTooltip => 'Números Guardados';

  @override
  String get historyTooltip => 'Historial';

  @override
  String get settingsTooltip => 'Configuración';

  @override
  String get addMyNumbersTooltip => 'Agregar Mis Números';

  @override
  String get deleteTooltip => 'Eliminar';

  @override
  String get collapseTooltip => 'Contraer';

  @override
  String get styleBalanced => 'Equilibrado';

  @override
  String get styleObservedPattern => 'Patrón Observado';

  @override
  String get styleLessCommon => 'Menos común';

  @override
  String get styleRandom => 'Aleatorio';

  @override
  String get styleBalancedTagline => 'Selección Equilibrada';

  @override
  String get styleHotTagline => 'Ejemplo de Patrón';

  @override
  String get styleColdTagline => 'Ejemplo de Número Histórico';

  @override
  String get styleRandomTagline => 'Selección Aleatoria';

  @override
  String get styleBalancedSubtitle =>
      'Distribución uniforme en todos los rangos de números.';

  @override
  String get styleHotSubtitle =>
      'Estos números se observaron con más frecuencia en resultados pasados.';

  @override
  String get styleColdSubtitle =>
      'Estos números se observaron con menos frecuencia en resultados pasados.';

  @override
  String get styleRandomSubtitle =>
      'Selección completamente aleatoria. Solo por diversión.';

  @override
  String get styleBalancedDescription =>
      'Distribución uniforme en el rango de números';

  @override
  String get styleHotDescription =>
      'Basado en frecuencia reciente en resultados pasados (solo como referencia)';

  @override
  String get styleColdDescription =>
      'Basado en números históricos menos frecuentes (solo como referencia)';

  @override
  String get styleRandomDescription =>
      'Selección aleatoria (solo como referencia)';

  @override
  String get threePickExample => 'Ejemplo de Selección';

  @override
  String get threePickExampleStar => '⭐ Ejemplo de Selección';

  @override
  String get threePickCommonPattern => 'Patrón Común';

  @override
  String get threePickRandomSurprise => 'Sorpresa Aleatoria';

  @override
  String get threePickRandomSurpriseDice => '🎲 Sorpresa Aleatoria';

  @override
  String get threePickBalancedMicrocopy =>
      'Selección equilibrada basada en resultados pasados';

  @override
  String get threePickHotMicrocopy =>
      'Estos números se observaron con más frecuencia en resultados pasados';

  @override
  String get threePickRandomMicrocopy =>
      'Selección aleatoria solo como referencia 🎲';

  @override
  String get insightBalancedOne =>
      'Basado en datos pasados, esto muestra una distribución equilibrada como referencia';

  @override
  String get insightBalancedTwo =>
      'El historial apunta a una distribución uniforme';

  @override
  String get insightBalancedThree =>
      'Distribución equilibrada de números vista en resultados pasados';

  @override
  String get insightHotOne =>
      'Resultados recientes muestran patrones similares';

  @override
  String get insightHotTwo => 'Observado frecuentemente en resultados pasados';

  @override
  String get insightHotThree =>
      'Basado en resultados pasados, se observó un patrón similar';

  @override
  String get insightColdOne =>
      'Basado en resultados pasados, se observaron números menos comunes ❄️';

  @override
  String get insightColdTwo => 'Números menos comunes de resultados pasados';

  @override
  String get insightRandomOne => 'A veces lo aleatorio es divertido 🎲';

  @override
  String get insightRandomTwo => 'Patrón aleatorio solo como referencia';

  @override
  String get insightRandomThree => 'Selección aleatoria por diversión';

  @override
  String nextResultUpdateDays(int days) {
    return 'Próxima actualización de resultado en ${days}d';
  }

  @override
  String nextResultUpdateHours(int hours) {
    return 'Próxima actualización de resultado en ${hours}h';
  }

  @override
  String get resultUpdateSoon => '¡Actualización de resultado pronto!';

  @override
  String get referencePickLabel => 'Selección de Referencia';

  @override
  String referencePickWithStyle(Object style) {
    return 'Selección de Referencia · $style';
  }

  @override
  String get manualPickLabel => '👤 Mis Números';

  @override
  String trackingResult(Object date) {
    return 'Resultado de seguimiento: $date';
  }

  @override
  String pickMainNumbers(int count, int min, int max) {
    return 'Elige $count números  ($min–$max)';
  }

  @override
  String pickBonusNumbers(int count, Object label, int min, int max) {
    return 'Elige $count $label  ($min–$max)';
  }

  @override
  String get saveMyNumbers => 'Guardar Mis Números';

  @override
  String pickMoreNumbers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'números',
      one: 'número',
    );
    return 'Elige $count $_temp0 más';
  }

  @override
  String pickMoreBonus(int count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Elige $count $label$_temp0 más';
  }

  @override
  String get disclaimerTitle => 'Solo por diversión — juega responsablemente.';

  @override
  String get disclaimerBody =>
      'Esta aplicación proporciona selecciones de números basadas únicamente en datos históricos. NO predice resultados, mejora probabilidades ni garantiza resultados.';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsResults => 'Resultados';

  @override
  String get settingsResultsSubtitle =>
      'Cuando los resultados pasados estén disponibles para tus selecciones guardadas';

  @override
  String get settingsMyPicks => 'Mis Selecciones';

  @override
  String get settingsMyPicksSubtitle =>
      'Cuando tus números guardados aparezcan en resultados recientes';

  @override
  String get settingsDailyInsights => 'Perspectivas Diarias';

  @override
  String get settingsDailyInsightsSubtitle =>
      'Una breve observación de tendencias por día';

  @override
  String get settingsWeeklySummary => 'Resumen Semanal';

  @override
  String get settingsWeeklySummarySubtitle =>
      'Un breve resumen de patrones cada domingo';

  @override
  String get settingsNotificationTime => 'Hora de notificación';

  @override
  String settingsNotificationTimeSubtitle(Object time) {
    return 'Las perspectivas diarias y semanales se programan para $time.';
  }

  @override
  String get settingsMaxNotifications =>
      'Máximo 2 notificaciones por día en total.';

  @override
  String get settingsLanguage => 'Idioma';

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
  String get settingsAnalysisStyle => 'Estilo de análisis';

  @override
  String get settingsAnalysisStyleSubtitle =>
      'Cómo se ponderan las tendencias históricas';

  @override
  String get analysisStyleRecentTrend => 'Tendencia reciente';

  @override
  String get analysisStyleRecentTrendDescription =>
      'Enfatiza patrones recientes (0-12 semanas: 70%, 13-52 semanas: 20%, 1-5 años: 10%)';

  @override
  String get analysisStyleBalanced => 'Equilibrado';

  @override
  String get analysisStyleBalancedDescription =>
      'Consideración igual en todos los períodos (0-12 semanas: 50%, 13-52 semanas: 30%, 1-5 años: 20%)';

  @override
  String get analysisStyleLongTermPattern => 'Patrón a largo plazo';

  @override
  String get analysisStyleLongTermPatternDescription =>
      'Enfatiza patrones históricos (0-12 semanas: 30%, 13-52 semanas: 30%, 1-5 años: 40%)';

  @override
  String get analysisStyleDisclaimer =>
      'Esto solo cambia cómo se ponderan las tendencias históricas. No mejora las probabilidades de ganar.';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsHistoricalResultsOnly => 'Solo resultados históricos';

  @override
  String get settingsHistoricalResultsOnlyBody =>
      'Todo el análisis se basa en resultados históricos. Esta aplicación no proporciona predicciones ni mejora resultados.';

  @override
  String get clearAllSavedPicksTitle =>
      '¿Eliminar todas las selecciones guardadas?';

  @override
  String get clearAll => 'Eliminar todo';

  @override
  String get pickDeleted => 'Selección eliminada';

  @override
  String get yourStats => 'Tus Estadísticas';

  @override
  String resultsChecked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'resultados',
      one: 'resultado',
    );
    return '$count $_temp0 verificado(s)';
  }

  @override
  String get top => 'Superior';

  @override
  String get topWithTrophy => '🏆 Superior';

  @override
  String get totalHits => 'Aciertos Totales';

  @override
  String get similarityScore => 'Puntuación de Similitud';

  @override
  String get myPick => '👤 Mi Selección';

  @override
  String get noneYet => 'Ninguno aún';

  @override
  String mainCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'es',
      one: '',
    );
    return '$count principal$_temp0';
  }

  @override
  String suppCountLabel(int count) {
    return '$count supl';
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
      other: 'es',
      one: '',
    );
    return '$main principal$_temp0';
  }

  @override
  String totalMainSuppHits(int main, int supp) {
    String _temp0 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'es',
      one: '',
    );
    return '$main principal$_temp0 · $supp supl';
  }

  @override
  String get pending => 'Pendiente';

  @override
  String pendingWithDate(Object date) {
    return 'Pendiente · $date';
  }

  @override
  String copyPickText(
    Object lotteryName,
    Object label,
    Object main,
    Object bonus,
  ) {
    return '🎯 Mi Conjunto de Números de $lotteryName\n$label\n\n$main$bonus\n\nGenerado por diversión — NumberRun';
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
    return '$label\n$lotteryName: $main$bonus\nGenerado por diversión — NumberRun 🎯';
  }

  @override
  String inlinePickBonusInline(Object numbers) {
    return ' + $numbers';
  }

  @override
  String get savedWithCheck => 'Guardado ✓';

  @override
  String historyPastResultsCount(int count) {
    return '$count resultados pasados';
  }

  @override
  String get offlineModeSavedResults =>
      'Modo sin conexión: mostrando resultados guardados';

  @override
  String offlineModeSavedResultsFrom(Object date) {
    return 'Modo sin conexión: mostrando resultados guardados desde $date';
  }

  @override
  String get noHistoryData => 'Aún no hay datos de historial disponibles.';

  @override
  String get noInternetNoSavedHistory =>
      'Sin conexión a internet y sin historial de lotería guardado aún.';

  @override
  String get noInternetNoSavedResultHistory =>
      'Sin conexión a internet y sin historial de resultados guardado aún.';

  @override
  String get failedToLoadHistory => 'Error al cargar historial.';

  @override
  String get recentPatternsTitle => 'Patrones de Resultados Pasados Recientes';

  @override
  String recentPatternsSubtitle(int count) {
    return 'Basado en los últimos $count resultados pasados';
  }

  @override
  String get historicalComparisonOnly =>
      'Solo comparación histórica · sin garantía de resultados';

  @override
  String get frequentNumbers => 'Números observados frecuentemente';

  @override
  String get frequentNumbersTooltip =>
      'Observados con más frecuencia en resultados pasados';

  @override
  String get lessCommonNumbers => 'Números menos comunes';

  @override
  String get lessCommonNumbersTooltip =>
      'Observados con menos frecuencia en resultados pasados';

  @override
  String get avgSum => 'Suma prom';

  @override
  String get oddEven => 'Impar/Par';

  @override
  String get lowHigh => 'Bajo/Alto';

  @override
  String get avgConsecPairs => 'Prom pares consec';

  @override
  String get notEnoughHistory =>
      'No hay suficiente historial de resultados pasados para análisis.';

  @override
  String get patternNotable => 'Patrón notable';

  @override
  String get patternBalanced => 'Equilibrado';

  @override
  String get patternRandomLike => 'Tipo aleatorio';

  @override
  String get odd => 'impar';

  @override
  String get even => 'par';

  @override
  String get low => 'bajo';

  @override
  String get high => 'alto';

  @override
  String get dailyInsightTitle => 'Perspectiva de Hoy';

  @override
  String get savedPicksAnalysisTitle => 'Análisis de Mis Selecciones Guardadas';

  @override
  String get savedPicksAnalysisSubtitle =>
      'Comparado con los últimos 20 resultados pasados · solo comparación posterior al resultado';

  @override
  String get topOverlap => 'Máxima coincidencia';

  @override
  String numbersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'números',
      one: 'número',
    );
    return '$count $_temp0';
  }

  @override
  String get avgOverlap => 'Coincidencia prom';

  @override
  String get perPastResult => 'por resultado pasado';

  @override
  String get oftenPicked => 'Elegido frecuentemente';

  @override
  String get inRecentDraws => 'En sorteos recientes';

  @override
  String get overlapLevelHigh => 'Nivel de coincidencia: Alto';

  @override
  String get overlapLevelMedium => 'Nivel de coincidencia: Medio';

  @override
  String get overlapLevelLow => 'Nivel de coincidencia: Bajo';

  @override
  String get historicalPatternNotEnough =>
      'No hay suficiente historial para análisis de patrones (se requieren 52+ sorteos pasados).';

  @override
  String get historicalPatternTitle => 'Comparación de Patrón Histórico';

  @override
  String get historicalPatternSubtitle =>
      'Basado en resultados pasados de los últimos 5 años';

  @override
  String get trendComparison => 'Comparación de tendencia';

  @override
  String get observedLessCommonComparison =>
      'Comparación observado/menos común';

  @override
  String get oddEvenStructure => 'Estructura impar/par';

  @override
  String get lowHighStructure => 'Estructura bajo/alto';

  @override
  String get sumRange => 'Rango de suma';

  @override
  String get consecutivePairs => 'Pares consecutivos';

  @override
  String consecutivePairCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pares consec',
      one: 'par consec',
    );
    return '$count $_temp0';
  }

  @override
  String get topSimilarPastResults =>
      'Los 10 resultados pasados más similares (solo como referencia)';

  @override
  String similarSharedNumbers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'números coincidieron',
      one: 'número coincidió',
    );
    return '$count $_temp0';
  }

  @override
  String similarStructuralSimilarity(Object percent) {
    return '$percent% similitud estructural';
  }

  @override
  String observedMoreLessCommonCounts(int hotCount, int coldCount) {
    return '🔥 $hotCount observados con más frecuencia · ❄️ $coldCount menos comunes';
  }

  @override
  String get historicalPatternStrong =>
      'Fuerte comparación con patrones históricos (solo como referencia)';

  @override
  String get historicalPatternModerate =>
      'Comparación moderada con patrones históricos (solo como referencia)';

  @override
  String get historicalPatternLimited =>
      'Comparación limitada con patrones históricos (solo como referencia)';

  @override
  String get drawResult => 'RESULTADO DEL SORTEO';

  @override
  String get supplementary => 'SUPLEMENTARIO';

  @override
  String get yourNumbers => 'TUS NÚMEROS';

  @override
  String get noMainMatched => 'No coincidió ningún principal';

  @override
  String get checkOfficialResults =>
      'Consulta los resultados oficiales para detalles';

  @override
  String get noNumbersMatched => 'No coincidieron números';

  @override
  String bonusMatched(Object label) {
    return '$label coincidió';
  }

  @override
  String matchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ron',
      one: '',
    );
    return '$count coincidió$_temp0';
  }

  @override
  String matchedCountWithBonus(int count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ron',
      one: '',
    );
    return '$count coincidió$_temp0 + $label';
  }

  @override
  String noMainWithSupp(int count) {
    return 'Sin principal · ${count}s';
  }

  @override
  String matchedWithSupp(int main, int supp) {
    String _temp0 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'ron',
      one: '',
    );
    return '$main coincidió$_temp0 + ${supp}s';
  }

  @override
  String get noMatch => 'Sin coincidencia';

  @override
  String get levelLightHit => 'Acierto ligero';

  @override
  String get levelNice => 'Bien';

  @override
  String get levelSolid => 'Sólido';

  @override
  String get levelStrong => 'Fuerte';

  @override
  String get levelGreat => 'Excelente';

  @override
  String get unknown => 'Desconocido';

  @override
  String get belowTypicalRange => 'Por debajo del rango típico';

  @override
  String get aboveTypicalRange => 'Por encima del rango típico';

  @override
  String get withinTypicalRange => 'Dentro del rango típico';

  @override
  String get drawAnalysisNotEnough =>
      'No hay suficiente historial de sorteos para análisis.';

  @override
  String get drawAnalysisNoSavedPicks =>
      'No hay selecciones guardadas o historial de sorteos para comparar.';

  @override
  String get recentDrawsConcentrated =>
      'Los sorteos recientes muestran mayor actividad entre pocos números — una concentración notable en este período.';

  @override
  String get periodMidRangeActive =>
      'Este período muestra mayor actividad entre varios números de rango medio.';

  @override
  String get recentDrawsHigherRange =>
      'Los sorteos recientes se han inclinado hacia números de rango más alto.';

  @override
  String get recentDrawsLowerRange =>
      'Los sorteos recientes se han inclinado hacia números de rango más bajo.';

  @override
  String get recentDrawsModerateSpread =>
      'Los sorteos recientes están bastante equilibrados con una distribución moderada entre números.';

  @override
  String get recentDrawsNoStrongPattern =>
      'Los sorteos recientes están bastante equilibrados sin patrón fuerte detectado.';

  @override
  String get weeklyNotableConcentration =>
      'Esta semana mostró una concentración notable entre pocos números.';

  @override
  String get weeklyModerateSpread =>
      'Esta semana mostró una distribución equilibrada con dispersión moderada.';

  @override
  String get weeklyNoStrongTrend =>
      'Esta semana mostró una distribución equilibrada sin tendencia fuerte.';

  @override
  String dailyInsightStrongDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
  ) {
    return '$lotteryName: según los últimos $drawCount sorteos, los números más activos son $hotNumbers.';
  }

  @override
  String dailyInsightMidRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
  ) {
    return '$lotteryName: los últimos $drawCount sorteos muestran más actividad en el rango medio. Números activos: $hotNumbers.';
  }

  @override
  String dailyInsightHigherRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object averageSum,
  ) {
    return '$lotteryName: los últimos $drawCount sorteos se inclinan hacia números altos, con una suma media de $averageSum.';
  }

  @override
  String dailyInsightLowerRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object averageSum,
  ) {
    return '$lotteryName: los últimos $drawCount sorteos se inclinan hacia números bajos, con una suma media de $averageSum.';
  }

  @override
  String dailyInsightBalancedDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object oddEvenPattern,
  ) {
    return '$lotteryName: los últimos $drawCount sorteos se ven equilibrados. Números activos: $hotNumbers; estructura común: $oddEvenPattern.';
  }

  @override
  String dailyInsightNoTrendDynamic(
    Object lotteryName,
    int drawCount,
    Object oddEvenPattern,
  ) {
    return '$lotteryName: no hay un patrón fuerte en los últimos $drawCount sorteos. Estructura común: $oddEvenPattern.';
  }

  @override
  String weeklySummaryStrongDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object oddEvenPattern,
  ) {
    return '$lotteryName: resumen semanal basado en los últimos $drawCount sorteos. Números calientes: $hotNumbers; estructura común: $oddEvenPattern.';
  }

  @override
  String weeklySummaryBalancedDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object lowHighPattern,
  ) {
    return '$lotteryName: resumen semanal basado en los últimos $drawCount sorteos. Números calientes: $hotNumbers; patrón de rango: $lowHighPattern.';
  }

  @override
  String weeklySummaryNoTrendDynamic(
    Object lotteryName,
    int drawCount,
    Object oddEvenPattern,
    Object lowHighPattern,
  ) {
    return '$lotteryName: el resumen semanal de los últimos $drawCount sorteos no muestra una tendencia fuerte. Estructura: $oddEvenPattern; rango: $lowHighPattern.';
  }

  @override
  String get savedPicksModerate =>
      'Tus selecciones guardadas han coincidido moderadamente con sorteos recientes.';

  @override
  String get savedNumbersAppeared =>
      'Varios números que guardaste aparecieron en resultados recientes.';

  @override
  String get savedPicksLimited =>
      'Tus selecciones guardadas muestran coincidencia limitada con resultados de sorteos recientes.';

  @override
  String get drawStrongHistoricalComparison =>
      'Este sorteo muestra una fuerte comparación con patrones históricos de los últimos 5 años.';

  @override
  String get drawModerateHistoricalComparison =>
      'Este sorteo muestra una comparación moderada con patrones de distribución histórica.';

  @override
  String get drawLimitedHistoricalComparison =>
      'Este sorteo muestra una comparación limitada con patrones históricos típicos.';

  @override
  String get generatedForFunHistoricalPatterns =>
      'Generado por diversión usando patrones históricos.';

  @override
  String get suppShort => 'S';

  @override
  String mainAndBonusMatched(int main, Object bonusLabel) {
    String _temp0 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'es',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'ron',
      one: '',
    );
    return '$main principal$_temp0 + $bonusLabel coincidió$_temp1';
  }

  @override
  String mainMatched(int main) {
    String _temp0 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'es',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'ron',
      one: '',
    );
    return '$main principal$_temp0 coincidió$_temp1';
  }

  @override
  String suppMatched(int supp) {
    String _temp0 = intl.Intl.pluralLogic(
      supp,
      locale: localeName,
      other: 'ron',
      one: '',
    );
    return '$supp supl coincidió$_temp0';
  }

  @override
  String mainAndSuppMatched(int main, int supp) {
    String _temp0 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'es',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      main,
      locale: localeName,
      other: 'ron',
      one: '',
    );
    return '$main principal$_temp0 + $supp supl coincidió$_temp1';
  }

  @override
  String get shareNearMatch => '🔥 ¡Casi coincide!';

  @override
  String get shareOnlyOneAway => 'Solo falta un número 👀';

  @override
  String get shareCanYouBeatThis => '¿Puedes superar esto? 👀';

  @override
  String get shareNotBad => '🎯 ¡No está mal!';

  @override
  String shareOfMainCount(int count) {
    return 'de $count';
  }

  @override
  String get shareTemplate => 'Plantilla';

  @override
  String get shareReferencePick => '⭐ Selección de Referencia';

  @override
  String get sharePng => 'Compartir PNG';

  @override
  String get shareDefaultPick =>
      'Mi selección de números 🎯 — Generado por NumberRun';

  @override
  String get shareDefaultPicks =>
      'Mis selecciones de números 🎯 — Generado por NumberRun';

  @override
  String get shareNumberComparison => '🔥 Comparación de números de NumberRun';

  @override
  String get shareNumberOverlap => '🎯 Coincidencia de números de NumberRun';

  @override
  String get shareRandomResult => '😆 Resultado aleatorio de NumberRun';

  @override
  String get shareTemplateFireLabel => '🔥 Casi Coincide';

  @override
  String get shareTemplateElectricLabel => '🎯 Coincidencia de Números';

  @override
  String get shareTemplateWarmLabel => '😂 Resultado Aleatorio';

  @override
  String get shareTemplateFireDescription =>
      'Tarjeta dorada sobre oscuro dramática para casi aciertos y rachas de aciertos fuertes.';

  @override
  String get shareTemplateElectricDescription =>
      'Tarjeta de estadísticas neón limpia para pequeñas victorias y coincidencias parciales.';

  @override
  String get shareTemplateWarmDescription =>
      'Tarjeta motivacional divertida para sorteos pendientes, fallos o solo compartir selección.';

  @override
  String get shareNotToday => 'Hoy no';

  @override
  String get shareZeroOverlapped => '0 coincidieron';

  @override
  String get shareRandomResultPlain => 'Resultado aleatorio';

  @override
  String get shareResultIncoming => '¡Actualización de resultado próxima!';

  @override
  String get shareWaitingForResults => 'Esperando resultados 🤞';

  @override
  String get shareMyNumberPick => 'Mi Selección de Números';

  @override
  String get shareLetsSee => 'Veamos qué pasa 👀';

  @override
  String get shareTheseAreMyNumbers => 'Estos son mis números ↑';

  @override
  String get shareFunnyFail => '😂 Fallo gracioso';

  @override
  String get shareCardPreviewTitle => 'Vista Previa de Tarjeta para Compartir';

  @override
  String shareCardPreviewSubtitle(Object lotteryName) {
    return 'Elige un estilo o mantén la opción predeterminada para $lotteryName.';
  }

  @override
  String resultPanelNoOverlap(Object date) {
    return 'Sin coincidencia en el último resultado pasado ($date)';
  }

  @override
  String resultPanelBonusAppeared(Object bonusLabel, Object date) {
    return '$bonusLabel apareció en el último resultado pasado ($date)';
  }

  @override
  String resultPanelOverlap(int count, Object bonusSuffix, Object date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ron',
      one: '',
    );
    return '$count$bonusSuffix coincidió$_temp0 en el último resultado pasado ($date)';
  }

  @override
  String bonusSuffix(Object bonusLabel) {
    return ' + $bonusLabel';
  }

  @override
  String get notificationResultReadyChannel => 'Resultado Listo';

  @override
  String get notificationResultReadyTitle => 'Resultado Listo 🎯';

  @override
  String notificationResultsReadyTitle(int count) {
    return '$count Resultados Listos 🎯';
  }

  @override
  String get notificationSavedNumbersReady =>
      'Tus números de lotería guardados están listos para verificar';

  @override
  String get notificationDailyInsightsChannel => 'Perspectivas Diarias';

  @override
  String get notificationDailyInsightTitle => 'Perspectiva de Hoy 📊';

  @override
  String get notificationWeeklySummaryChannel => 'Resumen Semanal';

  @override
  String get notificationWeeklySummaryTitle => 'Resumen Semanal 📅';

  @override
  String get notificationResultsDescription =>
      'Notifica cuando los resultados del sorteo de lotería están disponibles';

  @override
  String get notificationDailyDescription =>
      'Observaciones diarias de tendencias de sorteo';

  @override
  String get notificationWeeklyDescription =>
      'Resumen semanal de patrones de sorteo';

  @override
  String lotteryHistoryNoRemoteCsv(Object lottery) {
    return 'No hay CSV remoto configurado para $lottery.';
  }

  @override
  String lotteryHistoryLoadFailed(int statusCode) {
    return 'Error al cargar CSV del historial ($statusCode).';
  }

  @override
  String get lotteryHistoryCsvEmpty => 'El CSV del historial está vacío.';

  @override
  String get lotteryHistoryNoValidRows =>
      'No se encontraron filas de sorteo válidas en el CSV.';

  @override
  String lotteryHistoryParseFailed(Object error) {
    return 'Error al analizar CSV del historial: $error';
  }

  @override
  String get completeMyNumbers => 'Completar Mis Números';

  @override
  String get completeMyNumbersTitle => 'Bloquea Tus Números de la Suerte';

  @override
  String get completeMyNumbersSubtitle =>
      'Selecciona los números que quieres mantener y generaremos el resto según tu estrategia elegida.';

  @override
  String get selectYourNumbers => 'Tus Números';

  @override
  String tapToLockNumbers(int locked, int total) {
    return 'Toca para bloquear números ($locked/$total)';
  }

  @override
  String get bonusNumbers => 'Números Bonus';

  @override
  String tapToLockBonusNumbers(int locked, int total) {
    return 'Toca para bloquear bonus ($locked/$total)';
  }

  @override
  String get generationStrategy => 'Estrategia de Generación';

  @override
  String get generateAllNumbers => 'Generar Números';

  @override
  String get completeRemainingNumbers => 'Completar Mis Números';

  @override
  String get yourCompletedNumbers => 'Tus Números Completos';

  @override
  String get locked => 'Tus elecciones';

  @override
  String get generated => 'Generado';

  @override
  String maxNumbersSelected(int max) {
    return 'Máximo $max números permitidos';
  }

  @override
  String get reset => 'Reiniciar';

  @override
  String get regenerate => 'Intentar de Nuevo';

  @override
  String get completeMyNumbersDisclaimer =>
      'Esta función es solo para entretenimiento y referencia estadística. Los números generados se basan en datos históricos y no aumentan tus posibilidades de ganar.';

  @override
  String get numberAlreadySelected =>
      'Este número ya está seleccionado en la otra sección';

  @override
  String get duplicateNumbersError =>
      'No se puede generar: se encontraron números duplicados. Asegúrese de que ningún número aparezca en las secciones principales y suplementarias.';
}
