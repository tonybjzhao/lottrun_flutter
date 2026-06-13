// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'LottFun';

  @override
  String get brandTitle => 'NumberRun';

  @override
  String get brandSubtitle => '過去の記録からの数字セット';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonRetry => '再試行';

  @override
  String get commonShare => '共有';

  @override
  String get commonCopy => 'コピー';

  @override
  String get commonSave => '保存';

  @override
  String get commonSaved => '保存済み';

  @override
  String get commonLoad => '読み込み';

  @override
  String get commonDelete => '削除';

  @override
  String get commonBonus => 'ボーナス';

  @override
  String get commonSupp => '追加';

  @override
  String get commonView => '表示';

  @override
  String get commonLoading => '読み込み中...';

  @override
  String get commonGenerating => '生成中…';

  @override
  String get commonPreparing => '準備中...';

  @override
  String get countryUnitedStates => 'アメリカ';

  @override
  String get countryAustralia => 'オーストラリア';

  @override
  String get countryUnitedKingdom => 'イギリス';

  @override
  String get countryCanada => 'カナダ';

  @override
  String get countryGermany => 'ドイツ';

  @override
  String get countryJapan => '日本';

  @override
  String get countryFrance => 'France';

  @override
  String get countryOther => 'その他';

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
  String get lotteryLoto6 => 'ロト6';

  @override
  String get lotteryLoto7 => 'ロト7';

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
  String get bonusEuroNumbers => 'Euro Numbers';

  @override
  String get bonusChanceNumber => 'Chance Number';

  @override
  String get screenHistoryTitle => '履歴';

  @override
  String get screenSettingsTitle => '設定';

  @override
  String get screenSavedPicksTitle => '保存した選択';

  @override
  String get screenAddMyNumbersTitle => '自分の数字を追加';

  @override
  String get numberSelectionLabel => '数字の選択';

  @override
  String get lotteryLabel => '宝くじ';

  @override
  String get homeCardTitle => '数字の選択';

  @override
  String get homeCardSubtitle => 'スタイルを選択するか、3つの数字セットを生成';

  @override
  String get generateOnePick => '1つ生成';

  @override
  String get generateThreeNumberSets => '🎲 3つの数字セットを生成';

  @override
  String get generateThreeNumberSetsDescription =>
      '3つの数字セットはバランス型+観察型+ランダム型を組み合わせています（参考用）。';

  @override
  String get pastOverlapReferenceNote => '✨ いくつかの選択は過去の結果と複数の数字が重なりました（参考用）';

  @override
  String get generateEmptyPrompt => '過去の記録から数字セットを生成 🎲';

  @override
  String get numberSetReady => '✨ 数字セットが準備できました';

  @override
  String historicalSimilarityReference(int score) {
    return '📊 過去との類似度（参考）: $score / 100';
  }

  @override
  String dayStreak(int count) {
    return '🔥 $count日連続';
  }

  @override
  String countdownWithHourglass(Object text) {
    return '⏳ $text';
  }

  @override
  String get saveAll => 'すべて保存';

  @override
  String get savedToSavedPicks => '保存した選択に保存しました';

  @override
  String get pickSaved => '選択を保存しました';

  @override
  String get alreadySaved => '既に保存済み';

  @override
  String get allThreePicksSaved => '3つすべて保存しました';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました。';

  @override
  String pickCopiedToClipboard(Object label) {
    return '$labelをクリップボードにコピーしました。';
  }

  @override
  String get savedPicksTooltip => '保存した選択';

  @override
  String get historyTooltip => '履歴';

  @override
  String get settingsTooltip => '設定';

  @override
  String get addMyNumbersTooltip => '自分の数字を追加';

  @override
  String get deleteTooltip => '削除';

  @override
  String get collapseTooltip => '折りたたむ';

  @override
  String get styleBalanced => 'バランス型';

  @override
  String get styleObservedPattern => '観察型';

  @override
  String get styleLessCommon => '低頻度型';

  @override
  String get styleRandom => 'ランダム';

  @override
  String get styleBalancedTagline => 'バランス選択';

  @override
  String get styleHotTagline => 'パターン例';

  @override
  String get styleColdTagline => '過去の数字例';

  @override
  String get styleRandomTagline => 'ランダム選択';

  @override
  String get styleBalancedSubtitle => 'すべての数字範囲に均等に分散。';

  @override
  String get styleHotSubtitle => '過去の結果でより頻繁に観察された数字。';

  @override
  String get styleColdSubtitle => '過去の結果であまり観察されなかった数字。';

  @override
  String get styleRandomSubtitle => '完全にランダムな選択。楽しみのため。';

  @override
  String get styleBalancedDescription => '数字範囲全体に均等に分散';

  @override
  String get styleHotDescription => '過去の結果の最近の頻度に基づく（参考用）';

  @override
  String get styleColdDescription => '頻度の低い過去の数字に基づく（参考用）';

  @override
  String get styleRandomDescription => 'ランダム選択（参考用）';

  @override
  String get threePickExample => '例';

  @override
  String get threePickExampleStar => '⭐ 例';

  @override
  String get threePickCommonPattern => 'よくあるパターン';

  @override
  String get threePickRandomSurprise => 'ランダムサプライズ';

  @override
  String get threePickRandomSurpriseDice => '🎲 ランダムサプライズ';

  @override
  String get threePickBalancedMicrocopy => '過去の結果に基づくバランス選択';

  @override
  String get threePickHotMicrocopy => '過去の結果でより頻繁に観察された数字';

  @override
  String get threePickRandomMicrocopy => '参考用のランダム選択 🎲';

  @override
  String get insightBalancedOne => '過去のデータに基づくと、これは参考のためのバランスの取れた分散を示しています';

  @override
  String get insightBalancedTwo => '過去は均等な分布を示しています';

  @override
  String get insightBalancedThree => '過去の結果で見られたバランスの取れた数字分散';

  @override
  String get insightHotOne => '最近の結果は同様のパターンを示しています';

  @override
  String get insightHotTwo => '過去の結果で頻繁に観察されました';

  @override
  String get insightHotThree => '過去の結果に基づくと、同様のパターンが観察されました';

  @override
  String get insightColdOne => '過去の結果に基づくと、あまり出ない数字が観察されました ❄️';

  @override
  String get insightColdTwo => '過去の結果からのあまり出ない数字';

  @override
  String get insightRandomOne => '時にはランダムも楽しいです 🎲';

  @override
  String get insightRandomTwo => '参考用のランダムパターン';

  @override
  String get insightRandomThree => '楽しみのためのランダム選択';

  @override
  String nextResultUpdateDays(int days) {
    return '次の結果更新まで$days日';
  }

  @override
  String nextResultUpdateHours(int hours) {
    return '次の結果更新まで$hours時間';
  }

  @override
  String get resultUpdateSoon => 'まもなく結果更新！';

  @override
  String get referencePickLabel => '参考選択';

  @override
  String referencePickWithStyle(Object style) {
    return '参考選択 · $style';
  }

  @override
  String get manualPickLabel => '👤 自分の数字';

  @override
  String trackingResult(Object date) {
    return '結果追跡中: $date';
  }

  @override
  String pickMainNumbers(int count, int min, int max) {
    return '$count個の数字を選択  ($min–$max)';
  }

  @override
  String pickBonusNumbers(int count, Object label, int min, int max) {
    return '$count個の$labelを選択  ($min–$max)';
  }

  @override
  String get saveMyNumbers => '自分の数字を保存';

  @override
  String pickMoreNumbers(int count) {
    return 'あと$count個の数字を選択';
  }

  @override
  String pickMoreBonus(int count, Object label) {
    return 'あと$count個の$labelを選択';
  }

  @override
  String get disclaimerTitle => '楽しみのため — 責任を持って遊びましょう。';

  @override
  String get disclaimerBody =>
      'このアプリは過去のデータのみに基づいた数字選択を提供します。結果を予測したり、当選確率を上げたり、結果を保証するものではありません。';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsResults => '結果';

  @override
  String get settingsResultsSubtitle => '保存した選択の過去の結果が利用可能なとき';

  @override
  String get settingsMyPicks => '自分の選択';

  @override
  String get settingsMyPicksSubtitle => '保存した数字が最近の結果に現れたとき';

  @override
  String get settingsDailyInsights => 'デイリーインサイト';

  @override
  String get settingsDailyInsightsSubtitle => '1日1回の短いトレンド観察';

  @override
  String get settingsWeeklySummary => '週間サマリー';

  @override
  String get settingsWeeklySummarySubtitle => '毎週日曜日の簡単な週間パターンサマリー';

  @override
  String get settingsNotificationTime => '通知時刻';

  @override
  String settingsNotificationTimeSubtitle(Object time) {
    return 'デイリーおよび週間インサイトは$timeに予定されています。';
  }

  @override
  String get settingsMaxNotifications => '1日最大2件の通知。';

  @override
  String get settingsLanguage => '言語';

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
  String get settingsAnalysisStyle => '分析スタイル';

  @override
  String get settingsAnalysisStyleSubtitle => '過去のトレンドの重み付け方法';

  @override
  String get analysisStyleRecentTrend => '最近のトレンド';

  @override
  String get analysisStyleRecentTrendDescription =>
      '最近のパターンを重視（0〜12週: 70%、13〜52週: 20%、1〜5年: 10%）';

  @override
  String get analysisStyleBalanced => 'バランス型';

  @override
  String get analysisStyleBalancedDescription =>
      '期間全体で均等に考慮（0〜12週: 50%、13〜52週: 30%、1〜5年: 20%）';

  @override
  String get analysisStyleLongTermPattern => '長期パターン';

  @override
  String get analysisStyleLongTermPatternDescription =>
      '過去のパターンを重視（0〜12週: 30%、13〜52週: 30%、1〜5年: 40%）';

  @override
  String get analysisStyleDisclaimer =>
      'これは過去のトレンドの重み付け方法を変更するだけです。当選確率を改善するものではありません。';

  @override
  String get settingsAbout => 'アプリについて';

  @override
  String get settingsHistoricalResultsOnly => '過去の結果のみ';

  @override
  String get settingsHistoricalResultsOnlyBody =>
      'すべての分析は過去の結果に基づいています。このアプリは予測を提供したり、結果を改善したりするものではありません。';

  @override
  String get clearAllSavedPicksTitle => '保存したすべての選択を削除しますか？';

  @override
  String get clearAll => 'すべて削除';

  @override
  String get pickDeleted => '選択を削除しました';

  @override
  String get yourStats => 'あなたの統計';

  @override
  String resultsChecked(int count) {
    return '$count件の結果を確認';
  }

  @override
  String get top => 'トップ';

  @override
  String get topWithTrophy => '🏆 トップ';

  @override
  String get totalHits => '合計ヒット数';

  @override
  String get similarityScore => '類似度スコア';

  @override
  String get myPick => '👤 自分の選択';

  @override
  String get noneYet => 'まだありません';

  @override
  String mainCountLabel(int count) {
    return '$count個本数字';
  }

  @override
  String suppCountLabel(int count) {
    return '$count個追加';
  }

  @override
  String mainSuppCountLabel(int main, int supp) {
    return '$main+$supp';
  }

  @override
  String totalMainHits(int main) {
    return '$main個本数字';
  }

  @override
  String totalMainSuppHits(int main, int supp) {
    return '$main個本数字 · $supp個追加';
  }

  @override
  String get pending => '保留中';

  @override
  String pendingWithDate(Object date) {
    return '保留中 · $date';
  }

  @override
  String copyPickText(
    Object lotteryName,
    Object label,
    Object main,
    Object bonus,
  ) {
    return '🎯 $lotteryNameの数字セット\n$label\n\n$main$bonus\n\n楽しみのため生成 — NumberRun';
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
    return '$label\n$lotteryName: $main$bonus\n楽しみのため生成 — NumberRun 🎯';
  }

  @override
  String inlinePickBonusInline(Object numbers) {
    return ' + $numbers';
  }

  @override
  String get savedWithCheck => '保存済み ✓';

  @override
  String historyPastResultsCount(int count) {
    return '$count件の過去の結果';
  }

  @override
  String get offlineModeSavedResults => 'オフラインモード: 保存された結果を表示';

  @override
  String offlineModeSavedResultsFrom(Object date) {
    return 'オフラインモード: $dateからの保存された結果を表示';
  }

  @override
  String get noHistoryData => '履歴データはまだありません。';

  @override
  String get noInternetNoSavedHistory => 'インターネット接続がなく、保存された宝くじ履歴もありません。';

  @override
  String get noInternetNoSavedResultHistory => 'インターネット接続がなく、保存された結果履歴もありません。';

  @override
  String get failedToLoadHistory => '履歴の読み込みに失敗しました。';

  @override
  String get recentPatternsTitle => '最近の過去の結果パターン';

  @override
  String recentPatternsSubtitle(int count) {
    return '過去$count件の結果に基づく';
  }

  @override
  String get historicalComparisonOnly => '過去との比較のみ · 結果を保証するものではありません';

  @override
  String get frequentNumbers => 'よく出る数字';

  @override
  String get frequentNumbersTooltip => '過去の結果でより頻繁に観察';

  @override
  String get lessCommonNumbers => 'あまり出ない数字';

  @override
  String get lessCommonNumbersTooltip => '過去の結果であまり観察されない';

  @override
  String get avgSum => '平均合計';

  @override
  String get oddEven => '奇数/偶数';

  @override
  String get lowHigh => '低/高';

  @override
  String get avgConsecPairs => '平均連続ペア';

  @override
  String get notEnoughHistory => '分析するための十分な過去の結果履歴がありません。';

  @override
  String get patternNotable => '注目すべきパターン';

  @override
  String get patternBalanced => 'バランス型';

  @override
  String get patternRandomLike => 'ランダム的';

  @override
  String get odd => '奇数';

  @override
  String get even => '偶数';

  @override
  String get low => '低';

  @override
  String get high => '高';

  @override
  String get dailyInsightTitle => '今日のインサイト';

  @override
  String get savedPicksAnalysisTitle => '保存した選択の分析';

  @override
  String get savedPicksAnalysisSubtitle => '最近20件の過去の結果と比較 · 結果後の比較のみ';

  @override
  String get topOverlap => 'トップ一致';

  @override
  String numbersCount(int count) {
    return '$count個の数字';
  }

  @override
  String get avgOverlap => '平均一致';

  @override
  String get perPastResult => '過去の結果ごと';

  @override
  String get oftenPicked => 'よく選ばれた';

  @override
  String get inRecentDraws => '最近の抽選で';

  @override
  String get overlapLevelHigh => '一致レベル: 高';

  @override
  String get overlapLevelMedium => '一致レベル: 中';

  @override
  String get overlapLevelLow => '一致レベル: 低';

  @override
  String get historicalPatternNotEnough =>
      'パターン分析には十分な履歴がありません（52件以上の過去の抽選が必要）。';

  @override
  String get historicalPatternTitle => '過去のパターン比較';

  @override
  String get historicalPatternSubtitle => '過去5年間の過去の結果に基づく';

  @override
  String get trendComparison => 'トレンド比較';

  @override
  String get observedLessCommonComparison => 'よく出る/あまり出ない比較';

  @override
  String get oddEvenStructure => '奇数/偶数構造';

  @override
  String get lowHighStructure => '低/高構造';

  @override
  String get sumRange => '合計範囲';

  @override
  String get consecutivePairs => '連続ペア';

  @override
  String consecutivePairCount(int count) {
    return '$count個の連続ペア';
  }

  @override
  String get topSimilarPastResults => 'トップ10の類似過去結果（参考用）';

  @override
  String similarSharedNumbers(int count) {
    return '$count個の数字が一致';
  }

  @override
  String similarStructuralSimilarity(Object percent) {
    return '$percent%の構造的類似性';
  }

  @override
  String observedMoreLessCommonCounts(int hotCount, int coldCount) {
    return '🔥 $hotCount個よく出る · ❄️ $coldCount個あまり出ない';
  }

  @override
  String get historicalPatternStrong => '過去のパターンと強い比較（参考用）';

  @override
  String get historicalPatternModerate => '過去のパターンと中程度の比較（参考用）';

  @override
  String get historicalPatternLimited => '過去のパターンと限定的な比較（参考用）';

  @override
  String get drawResult => '抽選結果';

  @override
  String get supplementary => '追加数字';

  @override
  String get yourNumbers => 'あなたの数字';

  @override
  String get noMainMatched => '本数字の一致なし';

  @override
  String get checkOfficialResults => '詳細は公式結果を確認してください';

  @override
  String get noNumbersMatched => '数字の一致なし';

  @override
  String bonusMatched(Object label) {
    return '$labelが一致';
  }

  @override
  String matchedCount(int count) {
    return '$count個一致';
  }

  @override
  String matchedCountWithBonus(int count, Object label) {
    return '$count個一致 + $label';
  }

  @override
  String noMainWithSupp(int count) {
    return '本数字なし · $count個追加';
  }

  @override
  String matchedWithSupp(int main, int supp) {
    return '$main個一致 + $supp個追加';
  }

  @override
  String get noMatch => '一致なし';

  @override
  String get levelLightHit => '軽い一致';

  @override
  String get levelNice => '良い';

  @override
  String get levelSolid => '確実';

  @override
  String get levelStrong => '強い';

  @override
  String get levelGreat => '素晴らしい';

  @override
  String get unknown => '不明';

  @override
  String get belowTypicalRange => '通常範囲以下';

  @override
  String get aboveTypicalRange => '通常範囲以上';

  @override
  String get withinTypicalRange => '通常範囲内';

  @override
  String get drawAnalysisNotEnough => '分析するための十分な抽選履歴がありません。';

  @override
  String get drawAnalysisNoSavedPicks => '比較するための保存した選択または抽選履歴がありません。';

  @override
  String get recentDrawsConcentrated =>
      '最近の抽選は少数の数字にアクティビティが集中しています — この期間の注目すべき集中。';

  @override
  String get periodMidRangeActive => 'この期間はいくつかの中間範囲の数字でアクティビティが高くなっています。';

  @override
  String get recentDrawsHigherRange => '最近の抽選は高範囲の数字に傾いています。';

  @override
  String get recentDrawsLowerRange => '最近の抽選は低範囲の数字に傾いています。';

  @override
  String get recentDrawsModerateSpread =>
      '最近の抽選は数字全体に中程度の分散があり、かなりバランスが取れています。';

  @override
  String get recentDrawsNoStrongPattern =>
      '最近の抽選はかなりバランスが取れており、強いパターンは検出されていません。';

  @override
  String get weeklyNotableConcentration => '今週は少数の数字に注目すべき集中が見られました。';

  @override
  String get weeklyModerateSpread => '今週は中程度の分散でバランスの取れた分布を示しました。';

  @override
  String get weeklyNoStrongTrend => '今週は強いトレンドのないバランスの取れた分布を示しました。';

  @override
  String dailyInsightStrongDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
  ) {
    return '$lotteryName: 最新$drawCount回の抽選に基づくと、最もアクティブな数字は$hotNumbersです。';
  }

  @override
  String dailyInsightMidRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
  ) {
    return '$lotteryName: 最新$drawCount回の抽選は中間範囲で余分なアクティビティを示しています。アクティブな数字: $hotNumbers。';
  }

  @override
  String dailyInsightHigherRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object averageSum,
  ) {
    return '$lotteryName: 最新$drawCount回の抽選は高めに傾いており、本数字の平均合計は$averageSumです。';
  }

  @override
  String dailyInsightLowerRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object averageSum,
  ) {
    return '$lotteryName: 最新$drawCount回の抽選は低めに傾いており、本数字の平均合計は$averageSumです。';
  }

  @override
  String dailyInsightBalancedDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object oddEvenPattern,
  ) {
    return '$lotteryName: 最新$drawCount回の抽選はバランスが取れています。アクティブな数字: $hotNumbers; 一般的な構造: $oddEvenPattern。';
  }

  @override
  String dailyInsightNoTrendDynamic(
    Object lotteryName,
    int drawCount,
    Object oddEvenPattern,
  ) {
    return '$lotteryName: 最新$drawCount回の抽選に強いパターンはありません。一般的な構造: $oddEvenPattern。';
  }

  @override
  String weeklySummaryStrongDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object oddEvenPattern,
  ) {
    return '$lotteryName: 最新$drawCount回の抽選からの週間サマリー。よく出る数字: $hotNumbers; 一般的な構造: $oddEvenPattern。';
  }

  @override
  String weeklySummaryBalancedDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object lowHighPattern,
  ) {
    return '$lotteryName: 最新$drawCount回の抽選からの週間サマリー。よく出る数字: $hotNumbers; 範囲パターン: $lowHighPattern。';
  }

  @override
  String weeklySummaryNoTrendDynamic(
    Object lotteryName,
    int drawCount,
    Object oddEvenPattern,
    Object lowHighPattern,
  ) {
    return '$lotteryName: 最新$drawCount回の抽選からの週間サマリーは強いトレンドを示していません。構造: $oddEvenPattern; 範囲: $lowHighPattern。';
  }

  @override
  String get savedPicksModerate => '保存した選択は最近の抽選と中程度に一致しています。';

  @override
  String get savedNumbersAppeared => '保存したいくつかの数字が最近の結果に現れました。';

  @override
  String get savedPicksLimited => '保存した選択は最近の抽選結果と限定的な一致を示しています。';

  @override
  String get drawStrongHistoricalComparison =>
      'この抽選は過去5年間の過去のパターンと強い比較を示しています。';

  @override
  String get drawModerateHistoricalComparison =>
      'この抽選は過去の分布パターンと中程度の比較を示しています。';

  @override
  String get drawLimitedHistoricalComparison =>
      'この抽選は典型的な過去のパターンと限定的な比較を示しています。';

  @override
  String get generatedForFunHistoricalPatterns => '過去のパターンを使用して楽しみのために生成。';

  @override
  String get suppShort => '追';

  @override
  String mainAndBonusMatched(int main, Object bonusLabel) {
    return '$main個本数字 + $bonusLabel一致';
  }

  @override
  String mainMatched(int main) {
    return '$main個本数字一致';
  }

  @override
  String suppMatched(int supp) {
    return '$supp個追加一致';
  }

  @override
  String mainAndSuppMatched(int main, int supp) {
    return '$main個本数字 + $supp個追加一致';
  }

  @override
  String get shareNearMatch => '🔥 惜しい！';

  @override
  String get shareOnlyOneAway => 'あと1つでした 👀';

  @override
  String get shareCanYouBeatThis => 'これを超えられますか？ 👀';

  @override
  String get shareNotBad => '🎯 悪くない！';

  @override
  String shareOfMainCount(int count) {
    return '$count個中';
  }

  @override
  String get shareTemplate => 'テンプレート';

  @override
  String get shareReferencePick => '⭐ 参考選択';

  @override
  String get sharePng => 'PNG共有';

  @override
  String get shareDefaultPick => '私の数字選択 🎯 — NumberRunで生成';

  @override
  String get shareDefaultPicks => '私の数字選択 🎯 — NumberRunで生成';

  @override
  String get shareNumberComparison => '🔥 NumberRunからの数字比較';

  @override
  String get shareNumberOverlap => '🎯 NumberRunからの数字一致';

  @override
  String get shareRandomResult => '😆 NumberRunからのランダム結果';

  @override
  String get shareTemplateFireLabel => '🔥 ほぼ一致';

  @override
  String get shareTemplateElectricLabel => '🎯 数字一致';

  @override
  String get shareTemplateWarmLabel => '😂 ランダム結果';

  @override
  String get shareTemplateFireDescription => '惜しいケースと強いヒット連続のためのドラマチックな金色カード。';

  @override
  String get shareTemplateElectricDescription =>
      '小さな勝利と部分的な一致のためのクリーンなネオン統計カード。';

  @override
  String get shareTemplateWarmDescription =>
      '保留中の抽選、外れ、または選択のみの共有のための楽しい励ましカード。';

  @override
  String get shareNotToday => '今日はダメ';

  @override
  String get shareZeroOverlapped => '0個一致';

  @override
  String get shareRandomResultPlain => 'ランダム結果';

  @override
  String get shareResultIncoming => '結果更新まもなく！';

  @override
  String get shareWaitingForResults => '結果待ち 🤞';

  @override
  String get shareMyNumberPick => '私の数字選択';

  @override
  String get shareLetsSee => 'どうなるか見てみましょう 👀';

  @override
  String get shareTheseAreMyNumbers => 'これが私の数字です ↑';

  @override
  String get shareFunnyFail => '😂 面白い失敗';

  @override
  String get shareCardPreviewTitle => '共有カードプレビュー';

  @override
  String shareCardPreviewSubtitle(Object lotteryName) {
    return '$lotteryNameのスタイルを選択するか、デフォルトオプションのままにしてください。';
  }

  @override
  String resultPanelNoOverlap(Object date) {
    return '最後の過去の結果（$date）で一致なし';
  }

  @override
  String resultPanelBonusAppeared(Object bonusLabel, Object date) {
    return '$bonusLabelが最後の過去の結果（$date）に現れました';
  }

  @override
  String resultPanelOverlap(int count, Object bonusSuffix, Object date) {
    return '$count個$bonusSuffixが最後の過去の結果（$date）で一致';
  }

  @override
  String bonusSuffix(Object bonusLabel) {
    return ' + $bonusLabel';
  }

  @override
  String get notificationResultReadyChannel => '結果準備完了';

  @override
  String get notificationResultReadyTitle => '結果準備完了 🎯';

  @override
  String notificationResultsReadyTitle(int count) {
    return '$count件の結果準備完了 🎯';
  }

  @override
  String get notificationSavedNumbersReady => '保存した宝くじ数字の確認準備ができました';

  @override
  String get notificationDailyInsightsChannel => 'デイリーインサイト';

  @override
  String get notificationDailyInsightTitle => '今日のインサイト 📊';

  @override
  String get notificationWeeklySummaryChannel => '週間サマリー';

  @override
  String get notificationWeeklySummaryTitle => '週間サマリー 📅';

  @override
  String get notificationResultsDescription => '宝くじ抽選結果が利用可能なときに通知';

  @override
  String get notificationDailyDescription => '毎日の抽選トレンド観察';

  @override
  String get notificationWeeklyDescription => '週間抽選パターンサマリー';

  @override
  String lotteryHistoryNoRemoteCsv(Object lottery) {
    return '$lotteryのリモートCSVが設定されていません。';
  }

  @override
  String lotteryHistoryLoadFailed(int statusCode) {
    return '履歴CSVの読み込みに失敗しました（$statusCode）。';
  }

  @override
  String get lotteryHistoryCsvEmpty => '履歴CSVが空です。';

  @override
  String get lotteryHistoryNoValidRows => 'CSVに有効な抽選行が見つかりません。';

  @override
  String lotteryHistoryParseFailed(Object error) {
    return '履歴CSVの解析に失敗しました: $error';
  }

  @override
  String get completeMyNumbers => '自分の数字を補完';

  @override
  String get completeMyNumbersTitle => 'ラッキーナンバーをロック';

  @override
  String get completeMyNumbersSubtitle => '保持したい数字を選択すると、選択した戦略に基づいて残りを生成します。';

  @override
  String get selectYourNumbers => 'あなたの数字';

  @override
  String tapToLockNumbers(int locked, int total) {
    return 'タップして数字をロック（$locked/$total）';
  }

  @override
  String get bonusNumbers => 'ボーナス数字';

  @override
  String tapToLockBonusNumbers(int locked, int total) {
    return 'タップしてボーナスをロック（$locked/$total）';
  }

  @override
  String get generationStrategy => '生成戦略';

  @override
  String get generateAllNumbers => '数字を生成';

  @override
  String get completeRemainingNumbers => '自分の数字を補完';

  @override
  String get yourCompletedNumbers => 'あなたの完成した数字';

  @override
  String get locked => 'あなたの選択';

  @override
  String get generated => '生成済み';

  @override
  String maxNumbersSelected(int max) {
    return '最大$max個の数字まで';
  }

  @override
  String get reset => 'リセット';

  @override
  String get regenerate => 'もう一度試す';

  @override
  String get completeMyNumbersDisclaimer =>
      'この機能は娯楽および統計的参考のみを目的としています。生成された数字は過去のデータに基づいており、当選確率を上げるものではありません。';

  @override
  String get numberAlreadySelected => 'この数字は既に他のセクションで選択されています';

  @override
  String get duplicateNumbersError =>
      '生成できません: 重複した数字が見つかりました。本数字と追加数字のセクションに同じ数字が含まれていないことを確認してください。';
}
