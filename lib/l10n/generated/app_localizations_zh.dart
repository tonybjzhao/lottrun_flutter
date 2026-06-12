// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'LottFun';

  @override
  String get brandTitle => 'NumberRun';

  @override
  String get brandSubtitle => '基于历史记录的号码组合';

  @override
  String get commonCancel => '取消';

  @override
  String get commonRetry => '重试';

  @override
  String get commonShare => '分享';

  @override
  String get commonCopy => '复制';

  @override
  String get commonSave => '保存';

  @override
  String get commonSaved => '已保存';

  @override
  String get commonLoad => '加载';

  @override
  String get commonDelete => '删除';

  @override
  String get commonBonus => '特别号';

  @override
  String get commonSupp => '附加号';

  @override
  String get commonView => '查看';

  @override
  String get commonLoading => '加载中...';

  @override
  String get commonGenerating => '生成中…';

  @override
  String get commonPreparing => '准备中...';

  @override
  String get countryUnitedStates => '美国';

  @override
  String get countryAustralia => '澳大利亚';

  @override
  String get countryUnitedKingdom => '英国';

  @override
  String get countryCanada => '加拿大';

  @override
  String get countryGermany => '德国';

  @override
  String get countryOther => '其他';

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
  String get bonusLuckyStars => '幸运星';

  @override
  String get bonusSuperzahl => 'Superzahl';

  @override
  String get bonusEuroNumbers => 'Euro Numbers';

  @override
  String get screenHistoryTitle => '历史记录';

  @override
  String get screenSettingsTitle => '设置';

  @override
  String get screenSavedPicksTitle => '已保存号码';

  @override
  String get screenAddMyNumbersTitle => '添加我的号码';

  @override
  String get numberSelectionLabel => '号码选择';

  @override
  String get lotteryLabel => '彩票';

  @override
  String get homeCardTitle => '号码组合';

  @override
  String get homeCardSubtitle => '选择一种风格，或生成 3 组号码';

  @override
  String get generateOnePick => '生成 1 组号码';

  @override
  String get generateThreeNumberSets => '🎲 生成 3 组号码';

  @override
  String get generateThreeNumberSetsDescription => '3 组号码会结合均衡、观察模式和随机风格，仅供参考。';

  @override
  String get pastOverlapReferenceNote => '✨ 有些号码组合曾与历史结果中的多个号码重合（仅供参考）';

  @override
  String get generateEmptyPrompt => '根据历史记录生成一组号码 🎲';

  @override
  String get numberSetReady => '✨ 你的号码组合已准备好';

  @override
  String historicalSimilarityReference(int score) {
    return '📊 历史相似度（仅供参考）：$score / 100';
  }

  @override
  String dayStreak(int count) {
    return '🔥 连续 $count 天';
  }

  @override
  String countdownWithHourglass(Object text) {
    return '⏳ $text';
  }

  @override
  String get saveAll => '全部保存';

  @override
  String get savedToSavedPicks => '已保存到已保存号码';

  @override
  String get pickSaved => '号码已保存';

  @override
  String get alreadySaved => '已保存过';

  @override
  String get allThreePicksSaved => '3 组号码已全部保存';

  @override
  String get copiedToClipboard => '已复制到剪贴板。';

  @override
  String pickCopiedToClipboard(Object label) {
    return '$label 已复制到剪贴板。';
  }

  @override
  String get savedPicksTooltip => '已保存号码';

  @override
  String get historyTooltip => '历史记录';

  @override
  String get settingsTooltip => '设置';

  @override
  String get addMyNumbersTooltip => '添加我的号码';

  @override
  String get deleteTooltip => '删除';

  @override
  String get collapseTooltip => '收起';

  @override
  String get styleBalanced => '均衡';

  @override
  String get styleObservedPattern => '观察模式';

  @override
  String get styleLessCommon => '较少出现';

  @override
  String get styleRandom => '随机';

  @override
  String get styleBalancedTagline => '均衡号码';

  @override
  String get styleHotTagline => '示例模式号码';

  @override
  String get styleColdTagline => '历史低频号码示例';

  @override
  String get styleRandomTagline => '随机号码';

  @override
  String get styleBalancedSubtitle => '在所有号码区间中分布均匀。';

  @override
  String get styleHotSubtitle => '这些号码在过去结果中出现得更频繁。';

  @override
  String get styleColdSubtitle => '这些号码在过去结果中出现得较少。';

  @override
  String get styleRandomSubtitle => '完全随机选择。仅供娱乐。';

  @override
  String get styleBalancedDescription => '号码区间分布均衡';

  @override
  String get styleHotDescription => '基于近期历史结果频率（仅供参考）';

  @override
  String get styleColdDescription => '基于历史中较少出现的号码（仅供参考）';

  @override
  String get styleRandomDescription => '随机选择（仅供参考）';

  @override
  String get threePickExample => '示例号码';

  @override
  String get threePickExampleStar => '⭐ 示例号码';

  @override
  String get threePickCommonPattern => '常见模式';

  @override
  String get threePickRandomSurprise => '随机惊喜';

  @override
  String get threePickRandomSurpriseDice => '🎲 随机惊喜';

  @override
  String get threePickBalancedMicrocopy => '基于历史结果的均衡选择';

  @override
  String get threePickHotMicrocopy => '这些号码在过去结果中出现得更频繁';

  @override
  String get threePickRandomMicrocopy => '随机选择，仅供参考 🎲';

  @override
  String get insightBalancedOne => '根据历史数据，这显示出均衡分布，仅供参考';

  @override
  String get insightBalancedTwo => '历史记录显示分布较均匀';

  @override
  String get insightBalancedThree => '过去结果中可见均衡号码分布';

  @override
  String get insightHotOne => '近期结果显示类似模式';

  @override
  String get insightHotTwo => '过去结果中较常出现';

  @override
  String get insightHotThree => '根据过去结果，曾观察到类似模式';

  @override
  String get insightColdOne => '根据过去结果，观察到较少出现的号码 ❄️';

  @override
  String get insightColdTwo => '来自过去结果的较少出现号码';

  @override
  String get insightRandomOne => '有时随机也很有趣 🎲';

  @override
  String get insightRandomTwo => '随机模式，仅供参考';

  @override
  String get insightRandomThree => '随机选择，仅供娱乐';

  @override
  String nextResultUpdateDays(int days) {
    return '距离下次结果更新还有 $days 天';
  }

  @override
  String nextResultUpdateHours(int hours) {
    return '距离下次结果更新还有 $hours 小时';
  }

  @override
  String get resultUpdateSoon => '结果即将更新！';

  @override
  String get referencePickLabel => '参考号码';

  @override
  String referencePickWithStyle(Object style) {
    return '参考号码 · $style';
  }

  @override
  String get manualPickLabel => '👤 我的号码';

  @override
  String trackingResult(Object date) {
    return '跟踪结果：$date';
  }

  @override
  String pickMainNumbers(int count, int min, int max) {
    return '选择 $count 个号码（$min–$max）';
  }

  @override
  String pickBonusNumbers(int count, Object label, int min, int max) {
    return '选择 $count 个$label（$min–$max）';
  }

  @override
  String get saveMyNumbers => '保存我的号码';

  @override
  String pickMoreNumbers(int count) {
    return '还需选择 $count 个号码';
  }

  @override
  String pickMoreBonus(int count, Object label) {
    return '还需选择 $count 个$label';
  }

  @override
  String get disclaimerTitle => '仅供娱乐 — 请理性参与。';

  @override
  String get disclaimerBody => '本应用仅基于历史数据提供号码选择。它不会预测结果、提高概率或保证任何结果。';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsResults => '结果';

  @override
  String get settingsResultsSubtitle => '当你的已保存号码有可用历史结果时';

  @override
  String get settingsMyPicks => '我的号码';

  @override
  String get settingsMyPicksSubtitle => '当你保存的号码出现在近期结果中时';

  @override
  String get settingsDailyInsights => '每日洞察';

  @override
  String get settingsDailyInsightsSubtitle => '每天一条简短趋势观察';

  @override
  String get settingsWeeklySummary => '每周摘要';

  @override
  String get settingsWeeklySummarySubtitle => '每周日一份简短模式摘要';

  @override
  String get settingsNotificationTime => '通知时间';

  @override
  String settingsNotificationTimeSubtitle(Object time) {
    return '每日洞察和每周摘要会安排在 $time 发送。';
  }

  @override
  String get settingsMaxNotifications => '每天最多 2 条通知。';

  @override
  String get settingsLanguage => '语言';

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
  String get settingsAnalysisStyle => '分析风格';

  @override
  String get settingsAnalysisStyleSubtitle => '历史趋势的权重方式';

  @override
  String get analysisStyleRecentTrend => '近期趋势';

  @override
  String get analysisStyleRecentTrendDescription =>
      '强调近期模式（0-12周：70%，13-52周：20%，1-5年：10%）';

  @override
  String get analysisStyleBalanced => '平衡';

  @override
  String get analysisStyleBalancedDescription =>
      '各时间段均衡考虑（0-12周：50%，13-52周：30%，1-5年：20%）';

  @override
  String get analysisStyleLongTermPattern => '长期模式';

  @override
  String get analysisStyleLongTermPatternDescription =>
      '强调历史模式（0-12周：30%，13-52周：30%，1-5年：40%）';

  @override
  String get analysisStyleDisclaimer => '这只改变历史趋势的权重方式，不会提高中奖几率。';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsHistoricalResultsOnly => '仅使用历史结果';

  @override
  String get settingsHistoricalResultsOnlyBody =>
      '所有分析均基于历史结果。本应用不提供预测，也不会改善结果。';

  @override
  String get clearAllSavedPicksTitle => '清除所有已保存号码？';

  @override
  String get clearAll => '全部清除';

  @override
  String get pickDeleted => '号码已删除';

  @override
  String get yourStats => '你的统计';

  @override
  String resultsChecked(int count) {
    return '已检查 $count 个结果';
  }

  @override
  String get top => '最佳';

  @override
  String get topWithTrophy => '🏆 最佳';

  @override
  String get totalHits => '总命中';

  @override
  String get similarityScore => '相似度分数';

  @override
  String get myPick => '👤 我的号码';

  @override
  String get noneYet => '暂无';

  @override
  String mainCountLabel(int count) {
    return '$count 个主号';
  }

  @override
  String suppCountLabel(int count) {
    return '$count 个附加号';
  }

  @override
  String mainSuppCountLabel(int main, int supp) {
    return '$main+$supp';
  }

  @override
  String totalMainHits(int main) {
    return '$main 个主号';
  }

  @override
  String totalMainSuppHits(int main, int supp) {
    return '$main 个主号 · $supp 个附加号';
  }

  @override
  String get pending => '待定';

  @override
  String pendingWithDate(Object date) {
    return '待定 · $date';
  }

  @override
  String copyPickText(
    Object lotteryName,
    Object label,
    Object main,
    Object bonus,
  ) {
    return '🎯 我的 $lotteryName 号码组合\n$label\n\n$main$bonus\n\n仅供娱乐生成 — NumberRun';
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
    return '$label\n$lotteryName: $main$bonus\n仅供娱乐生成 — NumberRun 🎯';
  }

  @override
  String inlinePickBonusInline(Object numbers) {
    return ' + $numbers';
  }

  @override
  String get savedWithCheck => '已保存 ✓';

  @override
  String historyPastResultsCount(int count) {
    return '$count 条过去结果';
  }

  @override
  String get offlineModeSavedResults => '离线模式：显示已保存结果';

  @override
  String offlineModeSavedResultsFrom(Object date) {
    return '离线模式：显示来自 $date 的已保存结果';
  }

  @override
  String get noHistoryData => '暂无历史数据。';

  @override
  String get noInternetNoSavedHistory => '没有网络连接，也没有已保存的彩票历史记录。';

  @override
  String get noInternetNoSavedResultHistory => '没有网络连接，也没有已保存的结果历史记录。';

  @override
  String get failedToLoadHistory => '加载历史记录失败。';

  @override
  String get recentPatternsTitle => '近期过去结果模式';

  @override
  String recentPatternsSubtitle(int count) {
    return '基于最近 $count 条过去结果';
  }

  @override
  String get historicalComparisonOnly => '仅作历史比较 · 不保证结果';

  @override
  String get frequentNumbers => '较常出现的号码';

  @override
  String get frequentNumbersTooltip => '在过去结果中出现得更频繁';

  @override
  String get lessCommonNumbers => '较少出现的号码';

  @override
  String get lessCommonNumbersTooltip => '在过去结果中出现得较少';

  @override
  String get avgSum => '平均和值';

  @override
  String get oddEven => '奇/偶';

  @override
  String get lowHigh => '低/高';

  @override
  String get avgConsecPairs => '平均连续对数';

  @override
  String get notEnoughHistory => '历史结果不足，无法分析。';

  @override
  String get patternNotable => '显著模式';

  @override
  String get patternBalanced => '均衡';

  @override
  String get patternRandomLike => '类似随机';

  @override
  String get odd => '奇';

  @override
  String get even => '偶';

  @override
  String get low => '低';

  @override
  String get high => '高';

  @override
  String get dailyInsightTitle => '今日洞察';

  @override
  String get savedPicksAnalysisTitle => '我的已保存号码分析';

  @override
  String get savedPicksAnalysisSubtitle => '与最近 20 条过去结果比较 · 仅作开奖后比较';

  @override
  String get topOverlap => '最高重合';

  @override
  String numbersCount(int count) {
    return '$count 个号码';
  }

  @override
  String get avgOverlap => '平均重合';

  @override
  String get perPastResult => '每条过去结果';

  @override
  String get oftenPicked => '常被选择';

  @override
  String get inRecentDraws => '出现在近期结果中';

  @override
  String get overlapLevelHigh => '重合等级：高';

  @override
  String get overlapLevelMedium => '重合等级：中';

  @override
  String get overlapLevelLow => '重合等级：低';

  @override
  String get historicalPatternNotEnough => '历史记录不足，无法进行模式分析（需要 52+ 条过去开奖）。';

  @override
  String get historicalPatternTitle => '历史模式比较';

  @override
  String get historicalPatternSubtitle => '基于过去 5 年的历史结果';

  @override
  String get trendComparison => '趋势比较';

  @override
  String get observedLessCommonComparison => '常见/低频比较';

  @override
  String get oddEvenStructure => '奇偶结构';

  @override
  String get lowHighStructure => '低高结构';

  @override
  String get sumRange => '和值范围';

  @override
  String get consecutivePairs => '连续对';

  @override
  String consecutivePairCount(int count) {
    return '$count 个连续对';
  }

  @override
  String get topSimilarPastResults => '前 10 个相似过去结果（仅供参考）';

  @override
  String similarSharedNumbers(int count) {
    return '重合 $count 个号码';
  }

  @override
  String similarStructuralSimilarity(Object percent) {
    return '$percent% 结构相似度';
  }

  @override
  String observedMoreLessCommonCounts(int hotCount, int coldCount) {
    return '🔥 $hotCount 个较常出现 · ❄️ $coldCount 个较少出现';
  }

  @override
  String get historicalPatternStrong => '与历史模式高度相似（仅供参考）';

  @override
  String get historicalPatternModerate => '与历史模式中度相似（仅供参考）';

  @override
  String get historicalPatternLimited => '与典型历史模式相似度有限（仅供参考）';

  @override
  String get drawResult => '开奖结果';

  @override
  String get supplementary => '附加号';

  @override
  String get yourNumbers => '你的号码';

  @override
  String get noMainMatched => '没有主号命中';

  @override
  String get checkOfficialResults => '请查看官方结果了解详情';

  @override
  String get noNumbersMatched => '没有号码命中';

  @override
  String bonusMatched(Object label) {
    return '$label 命中';
  }

  @override
  String matchedCount(int count) {
    return '命中 $count 个';
  }

  @override
  String matchedCountWithBonus(int count, Object label) {
    return '命中 $count 个 + $label';
  }

  @override
  String noMainWithSupp(int count) {
    return '无主号 · $count 个附加号';
  }

  @override
  String matchedWithSupp(int main, int supp) {
    return '命中 $main 个 + $supp 个附加号';
  }

  @override
  String get noMatch => '未命中';

  @override
  String get levelLightHit => '轻微命中';

  @override
  String get levelNice => '不错';

  @override
  String get levelSolid => '扎实';

  @override
  String get levelStrong => '强';

  @override
  String get levelGreat => '很好';

  @override
  String get unknown => '未知';

  @override
  String get belowTypicalRange => '低于典型范围';

  @override
  String get aboveTypicalRange => '高于典型范围';

  @override
  String get withinTypicalRange => '在典型范围内';

  @override
  String get drawAnalysisNotEnough => '开奖历史不足，无法分析。';

  @override
  String get drawAnalysisNoSavedPicks => '没有已保存号码或开奖记录可比较。';

  @override
  String get recentDrawsConcentrated => '近期结果显示少数号码活跃度较高 — 这一时期有明显集中。';

  @override
  String get periodMidRangeActive => '这一时期多个中段号码更活跃。';

  @override
  String get recentDrawsHigherRange => '近期结果偏向较高号码区间。';

  @override
  String get recentDrawsLowerRange => '近期结果偏向较低号码区间。';

  @override
  String get recentDrawsModerateSpread => '近期结果较均衡，号码分布适中。';

  @override
  String get recentDrawsNoStrongPattern => '近期结果较均衡，未检测到强模式。';

  @override
  String get weeklyNotableConcentration => '本周少数号码出现明显集中。';

  @override
  String get weeklyModerateSpread => '本周分布均衡，离散程度适中。';

  @override
  String get weeklyNoStrongTrend => '本周分布均衡，没有明显趋势。';

  @override
  String dailyInsightStrongDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
  ) {
    return '$lotteryName：基于最近 $drawCount 期开奖，活跃号码是 $hotNumbers。';
  }

  @override
  String dailyInsightMidRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
  ) {
    return '$lotteryName：最近 $drawCount 期开奖中段号码更活跃。活跃号码：$hotNumbers。';
  }

  @override
  String dailyInsightHigherRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object averageSum,
  ) {
    return '$lotteryName：最近 $drawCount 期开奖偏向高号码区间，主号平均和值为 $averageSum。';
  }

  @override
  String dailyInsightLowerRangeDynamic(
    Object lotteryName,
    int drawCount,
    Object averageSum,
  ) {
    return '$lotteryName：最近 $drawCount 期开奖偏向低号码区间，主号平均和值为 $averageSum。';
  }

  @override
  String dailyInsightBalancedDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object oddEvenPattern,
  ) {
    return '$lotteryName：最近 $drawCount 期开奖分布较均衡。活跃号码：$hotNumbers；常见结构：$oddEvenPattern。';
  }

  @override
  String dailyInsightNoTrendDynamic(
    Object lotteryName,
    int drawCount,
    Object oddEvenPattern,
  ) {
    return '$lotteryName：最近 $drawCount 期开奖未检测到强模式。常见结构：$oddEvenPattern。';
  }

  @override
  String weeklySummaryStrongDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object oddEvenPattern,
  ) {
    return '$lotteryName：每周摘要基于最近 $drawCount 期开奖。热门号码：$hotNumbers；常见结构：$oddEvenPattern。';
  }

  @override
  String weeklySummaryBalancedDynamic(
    Object lotteryName,
    int drawCount,
    Object hotNumbers,
    Object lowHighPattern,
  ) {
    return '$lotteryName：每周摘要基于最近 $drawCount 期开奖。热门号码：$hotNumbers；高低区间：$lowHighPattern。';
  }

  @override
  String weeklySummaryNoTrendDynamic(
    Object lotteryName,
    int drawCount,
    Object oddEvenPattern,
    Object lowHighPattern,
  ) {
    return '$lotteryName：每周摘要显示最近 $drawCount 期开奖没有强趋势。结构：$oddEvenPattern；区间：$lowHighPattern。';
  }

  @override
  String get savedPicksModerate => '你的已保存号码与近期结果有中等程度匹配。';

  @override
  String get savedNumbersAppeared => '你保存的多个号码出现在近期结果中。';

  @override
  String get savedPicksLimited => '你的已保存号码与近期开奖结果重合有限。';

  @override
  String get drawStrongHistoricalComparison => '本次开奖与过去 5 年的历史模式比较相似度较高。';

  @override
  String get drawModerateHistoricalComparison => '本次开奖与历史分布模式比较相似度中等。';

  @override
  String get drawLimitedHistoricalComparison => '本次开奖与典型历史模式比较相似度有限。';

  @override
  String get generatedForFunHistoricalPatterns => '基于历史模式生成，仅供娱乐。';

  @override
  String get suppShort => '附';

  @override
  String mainAndBonusMatched(int main, Object bonusLabel) {
    return '$main 个主号 + $bonusLabel 命中';
  }

  @override
  String mainMatched(int main) {
    return '$main 个主号命中';
  }

  @override
  String suppMatched(int supp) {
    return '$supp 个附加号命中';
  }

  @override
  String mainAndSuppMatched(int main, int supp) {
    return '$main 个主号 + $supp 个附加号命中';
  }

  @override
  String get shareNearMatch => '🔥 接近命中！';

  @override
  String get shareOnlyOneAway => '只差一个号码 👀';

  @override
  String get shareCanYouBeatThis => '你能超过这个吗？👀';

  @override
  String get shareNotBad => '🎯 还不错！';

  @override
  String shareOfMainCount(int count) {
    return '共 $count 个';
  }

  @override
  String get shareTemplate => '模板';

  @override
  String get shareReferencePick => '⭐ 参考号码';

  @override
  String get sharePng => '分享 PNG';

  @override
  String get shareDefaultPick => '我的号码组合 🎯 — 由 NumberRun 生成';

  @override
  String get shareDefaultPicks => '我的号码组合 🎯 — 由 NumberRun 生成';

  @override
  String get shareNumberComparison => '🔥 NumberRun 号码比较';

  @override
  String get shareNumberOverlap => '🎯 NumberRun 号码重合';

  @override
  String get shareRandomResult => '😆 NumberRun 随机结果';

  @override
  String get shareTemplateFireLabel => '🔥 接近重合';

  @override
  String get shareTemplateElectricLabel => '🎯 号码重合';

  @override
  String get shareTemplateWarmLabel => '😂 随机结果';

  @override
  String get shareTemplateFireDescription => '金色深色风格卡片，适合接近命中和强命中记录。';

  @override
  String get shareTemplateElectricDescription => '简洁霓虹统计卡，适合较小命中和部分匹配。';

  @override
  String get shareTemplateWarmDescription => '轻松有趣的激励卡，适合待开奖、未命中或仅分享号码。';

  @override
  String get shareNotToday => '今天还不是';

  @override
  String get shareZeroOverlapped => '0 个重合';

  @override
  String get shareRandomResultPlain => '随机结果';

  @override
  String get shareResultIncoming => '结果即将更新！';

  @override
  String get shareWaitingForResults => '等待结果中 🤞';

  @override
  String get shareMyNumberPick => '我的号码组合';

  @override
  String get shareLetsSee => '看看会发生什么 👀';

  @override
  String get shareTheseAreMyNumbers => '这些是我的号码 ↑';

  @override
  String get shareFunnyFail => '😂 有趣未中';

  @override
  String get shareCardPreviewTitle => '分享卡片预览';

  @override
  String shareCardPreviewSubtitle(Object lotteryName) {
    return '为 $lotteryName 选择一种样式，或保留默认选项。';
  }

  @override
  String resultPanelNoOverlap(Object date) {
    return '上一条过去结果（$date）没有重合';
  }

  @override
  String resultPanelBonusAppeared(Object bonusLabel, Object date) {
    return '$bonusLabel 出现在上一条过去结果中（$date）';
  }

  @override
  String resultPanelOverlap(int count, Object bonusSuffix, Object date) {
    return '$count$bonusSuffix 个号码与上一条过去结果重合（$date）';
  }

  @override
  String bonusSuffix(Object bonusLabel) {
    return ' + $bonusLabel';
  }

  @override
  String get notificationResultReadyChannel => '结果已准备好';

  @override
  String get notificationResultReadyTitle => '结果已准备好 🎯';

  @override
  String notificationResultsReadyTitle(int count) {
    return '$count 个结果已准备好 🎯';
  }

  @override
  String get notificationSavedNumbersReady => '你保存的彩票号码可以查看了';

  @override
  String get notificationDailyInsightsChannel => '每日洞察';

  @override
  String get notificationDailyInsightTitle => '今日洞察 📊';

  @override
  String get notificationWeeklySummaryChannel => '每周摘要';

  @override
  String get notificationWeeklySummaryTitle => '每周摘要 📅';

  @override
  String get notificationResultsDescription => '当彩票开奖结果可用时通知';

  @override
  String get notificationDailyDescription => '每日开奖趋势观察';

  @override
  String get notificationWeeklyDescription => '每周开奖模式摘要';

  @override
  String lotteryHistoryNoRemoteCsv(Object lottery) {
    return '未为 $lottery 配置远程 CSV。';
  }

  @override
  String lotteryHistoryLoadFailed(int statusCode) {
    return '加载历史 CSV 失败（$statusCode）。';
  }

  @override
  String get lotteryHistoryCsvEmpty => '历史 CSV 为空。';

  @override
  String get lotteryHistoryNoValidRows => 'CSV 中没有找到有效开奖行。';

  @override
  String lotteryHistoryParseFailed(Object error) {
    return '解析历史 CSV 失败：$error';
  }

  @override
  String get completeMyNumbers => '完成我的号码';

  @override
  String get completeMyNumbersTitle => '锁定你的幸运号码';

  @override
  String get completeMyNumbersSubtitle => '选择你想保留的号码，我们会根据你选择的策略生成其余号码。';

  @override
  String get selectYourNumbers => '你的号码';

  @override
  String tapToLockNumbers(int locked, int total) {
    return '点击锁定号码（$locked/$total）';
  }

  @override
  String get bonusNumbers => '特别号码';

  @override
  String tapToLockBonusNumbers(int locked, int total) {
    return '点击锁定特别号码（$locked/$total）';
  }

  @override
  String get generationStrategy => '生成策略';

  @override
  String get generateAllNumbers => '生成号码';

  @override
  String get completeRemainingNumbers => '完成我的号码';

  @override
  String get yourCompletedNumbers => '你的完整号码';

  @override
  String get locked => '你选的';

  @override
  String get generated => '已生成';

  @override
  String maxNumbersSelected(int max) {
    return '最多允许 $max 个号码';
  }

  @override
  String get reset => '重置';

  @override
  String get regenerate => '重新生成';

  @override
  String get completeMyNumbersDisclaimer =>
      '此功能仅供娱乐和统计参考。生成的号码基于历史数据，不会增加中奖机会。';

  @override
  String get numberAlreadySelected => '此号码已在另一区域中选择';

  @override
  String get duplicateNumbersError => '无法生成：发现重复号码。请确保没有号码同时出现在主号码和补充号码中。';
}
