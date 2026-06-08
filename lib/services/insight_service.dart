import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/generated/app_localizations_en.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';
import 'draw_analysis_service.dart';

// ── Notification preference keys ──────────────────────────────────────────────

const String kNotifKeyResults = 'notif_results';
const String kNotifKeyMyPicks = 'notif_my_picks';
const String kNotifKeyDailyInsight = 'notif_daily_insight';
const String kNotifKeyWeeklySummary = 'notif_weekly_summary';

const String _kDailyInsightText = 'daily_insight_text';
const String _kDailyInsightDate = 'daily_insight_date';
const String _kLastNotifDate = 'last_notif_date';
const String _kNotifCountToday = 'notif_count_today';
const String _kLastWeeklySummaryDate = 'last_weekly_summary_date';

const int _kDailyNotifCap = 2;
final _l10nFallback = AppLocalizationsEn();

class InsightService {
  InsightService._();
  static final instance = InsightService._();

  // ── Daily Insight ─────────────────────────────────────────────────────────

  /// Returns a cached insight for today, or generates a fresh one.
  /// Note: Cache is locale-independent. For localized insights, always regenerate.
  Future<String> getDailyInsight({
    required Lottery lottery,
    required List<LotteryDraw> draws,
    AppLocalizations? l10n,
  }) async {
    final localizations = l10n ?? _l10nFallback;

    // For now, skip caching to ensure localized insights are always fresh
    // TODO: Consider locale-aware caching if needed
    final text = _generateInsight(
      lottery: lottery,
      draws: draws,
      l10n: localizations,
    );
    return text;
  }

  String _generateInsight({
    required Lottery lottery,
    required List<LotteryDraw> draws,
    required AppLocalizations l10n,
  }) {
    if (draws.isEmpty) {
      return l10n.recentDrawsNoStrongPattern;
    }

    final trends = DrawAnalysisService.analyzeRecentTrends(
      lottery: lottery,
      draws: draws,
      drawCount: 20,
      l10n: l10n,
    );

    final topInMid = trends.topFrequent
        .where(
          (n) =>
              n >
                  lottery.mainMin +
                      (lottery.mainMax - lottery.mainMin) * 0.25 &&
              n < lottery.mainMax - (lottery.mainMax - lottery.mainMin) * 0.25,
        )
        .length;

    switch (trends.trendStrength) {
      case TrendStrength.strong:
        return l10n.recentDrawsConcentrated;
      case TrendStrength.balanced:
        if (topInMid >= 3) {
          return l10n.periodMidRangeActive;
        }
        final avgSum = trends.averageSum;
        final expectedMid =
            (lottery.mainMin + lottery.mainMax) / 2 * lottery.mainCount;
        if (avgSum > expectedMid * 1.05) {
          return l10n.recentDrawsHigherRange;
        }
        if (avgSum < expectedMid * 0.95) {
          return l10n.recentDrawsLowerRange;
        }
        return l10n.recentDrawsModerateSpread;
      case TrendStrength.random:
        return l10n.recentDrawsNoStrongPattern;
    }
  }

  // ── Notification preferences ──────────────────────────────────────────────

  Future<bool> getNotifPref(String key, {bool defaultValue = true}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setNotifPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // ── Daily cap tracking ────────────────────────────────────────────────────

  /// Returns true if we can still send a notification today (cap = 2/day).
  Future<bool> canSendNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final lastDate = prefs.getString(_kLastNotifDate);
    final count = lastDate == today
        ? (prefs.getInt(_kNotifCountToday) ?? 0)
        : 0;
    return count < _kDailyNotifCap;
  }

  Future<void> recordNotificationSent() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final lastDate = prefs.getString(_kLastNotifDate);
    final count = lastDate == today
        ? (prefs.getInt(_kNotifCountToday) ?? 0)
        : 0;
    await prefs.setString(_kLastNotifDate, today);
    await prefs.setInt(_kNotifCountToday, count + 1);
  }

  // ── Weekly summary gate ───────────────────────────────────────────────────

  /// Returns true if a weekly summary should be sent (once per week, Sunday).
  Future<bool> shouldSendWeeklySummary() async {
    final now = DateTime.now();
    if (now.weekday != DateTime.sunday) return false;
    final prefs = await SharedPreferences.getInstance();
    final lastKey = prefs.getString(_kLastWeeklySummaryDate);
    final thisWeek = _weekKey(now);
    return lastKey != thisWeek;
  }

  Future<void> recordWeeklySummarySent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastWeeklySummaryDate, _weekKey(DateTime.now()));
  }

  String _generateWeeklySummary({
    required Lottery lottery,
    required List<LotteryDraw> draws,
    AppLocalizations? l10n,
  }) {
    final localizations = l10n ?? _l10nFallback;
    if (draws.isEmpty) return localizations.weeklyNoStrongTrend;
    final trends = DrawAnalysisService.analyzeRecentTrends(
      lottery: lottery,
      draws: draws,
      drawCount: 20,
      l10n: localizations,
    );
    switch (trends.trendStrength) {
      case TrendStrength.strong:
        return localizations.weeklyNotableConcentration;
      case TrendStrength.balanced:
        return localizations.weeklyModerateSpread;
      case TrendStrength.random:
        return localizations.weeklyNoStrongTrend;
    }
  }

  String weeklySummaryBody({
    required Lottery lottery,
    required List<LotteryDraw> draws,
    AppLocalizations? l10n,
  }) => _generateWeeklySummary(lottery: lottery, draws: draws, l10n: l10n);

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _weekKey(DateTime d) {
    final monday = d.subtract(Duration(days: d.weekday - 1));
    return _dateKey(monday);
  }
}
