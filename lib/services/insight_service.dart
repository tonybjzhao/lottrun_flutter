import 'package:shared_preferences/shared_preferences.dart';
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

class InsightService {
  InsightService._();
  static final instance = InsightService._();

  // ── Daily Insight ─────────────────────────────────────────────────────────

  /// Returns a cached insight for today, or generates a fresh one.
  Future<String> getDailyInsight({
    required Lottery lottery,
    required List<LotteryDraw> draws,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final cachedDate = prefs.getString(_kDailyInsightDate);
    final cachedText = prefs.getString(_kDailyInsightText);

    if (cachedDate == today && cachedText != null && cachedText.isNotEmpty) {
      return cachedText;
    }

    final text = _generateInsight(lottery: lottery, draws: draws);
    await prefs.setString(_kDailyInsightDate, today);
    await prefs.setString(_kDailyInsightText, text);
    return text;
  }

  String _generateInsight({
    required Lottery lottery,
    required List<LotteryDraw> draws,
  }) {
    if (draws.isEmpty) {
      return 'Recent draws are fairly balanced with no strong pattern detected.';
    }

    final trends = DrawAnalysisService.analyzeRecentTrends(
      lottery: lottery,
      draws: draws,
      drawCount: 20,
    );

    final topInMid = trends.topFrequent
        .where((n) =>
            n > lottery.mainMin + (lottery.mainMax - lottery.mainMin) * 0.25 &&
            n < lottery.mainMax - (lottery.mainMax - lottery.mainMin) * 0.25)
        .length;

    switch (trends.trendStrength) {
      case TrendStrength.strong:
        return 'Recent draws show a notable concentration among a few numbers.';
      case TrendStrength.balanced:
        if (topInMid >= 3) {
          return 'Mid-range numbers have been slightly more active recently.';
        }
        final avgSum = trends.averageSum;
        final expectedMid =
            (lottery.mainMin + lottery.mainMax) / 2 * lottery.mainCount;
        if (avgSum > expectedMid * 1.05) {
          return 'Recent draws have leaned toward higher-range numbers.';
        }
        if (avgSum < expectedMid * 0.95) {
          return 'Recent draws have leaned toward lower-range numbers.';
        }
        return 'Recent draws are fairly balanced with a moderate spread.';
      case TrendStrength.random:
        return 'Recent draws are fairly balanced with no strong pattern detected.';
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
    final count = lastDate == today ? (prefs.getInt(_kNotifCountToday) ?? 0) : 0;
    return count < _kDailyNotifCap;
  }

  Future<void> recordNotificationSent() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final lastDate = prefs.getString(_kLastNotifDate);
    final count = lastDate == today ? (prefs.getInt(_kNotifCountToday) ?? 0) : 0;
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
  }) {
    if (draws.isEmpty) return 'No strong trend detected this week.';
    final trends = DrawAnalysisService.analyzeRecentTrends(
      lottery: lottery,
      draws: draws,
      drawCount: 20,
    );
    switch (trends.trendStrength) {
      case TrendStrength.strong:
        return 'This week showed a notable concentration among a few numbers.';
      case TrendStrength.balanced:
        return 'This week showed a balanced distribution with moderate spread.';
      case TrendStrength.random:
        return 'This week showed a balanced distribution with no strong trend.';
    }
  }

  String weeklySummaryBody({
    required Lottery lottery,
    required List<LotteryDraw> draws,
  }) =>
      _generateWeeklySummary(lottery: lottery, draws: draws);

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _weekKey(DateTime d) {
    final monday = d.subtract(Duration(days: d.weekday - 1));
    return _dateKey(monday);
  }
}
