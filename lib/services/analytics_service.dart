import 'package:firebase_analytics/firebase_analytics.dart';

/// Central analytics service. All event logging flows through here so
/// parameter names and values stay consistent across the codebase.
class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalytics get instance => _analytics;

  // ── Core events ──────────────────────────────────────────────────────────────

  /// Fired every time a pick is produced.
  /// [source] is stable: 'home' | 'three_picks'
  static Future<void> logGenerateNumbers({
    required String lottery,
    required String strategy,
    required int pickCount,
    required String source,
  }) =>
      _analytics.logEvent(
        name: 'generate_numbers',
        parameters: {
          'lottery': lottery,
          'strategy': strategy,
          'pick_count': pickCount,
          'source': source,
        },
      );

  /// Fired when the user switches play style (Balanced / Hot / Cold / Random).
  static Future<void> logPickStrategySelected({
    required String strategy,
    required String lottery,
  }) =>
      _analytics.logEvent(
        name: 'pick_strategy_selected',
        parameters: {'strategy': strategy, 'lottery': lottery},
      );

  /// Fired when the History screen mounts.
  static Future<void> logHistoryOpened({required String lottery}) =>
      _analytics.logEvent(
        name: 'history_opened',
        parameters: {'lottery': lottery},
      );

  /// Fired when the user switches from one lottery to another.
  static Future<void> logLotteryChanged({
    required String fromLottery,
    required String toLottery,
  }) =>
      _analytics.logEvent(
        name: 'lottery_changed',
        parameters: {'from_lottery': fromLottery, 'to_lottery': toLottery},
      );

  /// Fired when the user saves a pick locally.
  static Future<void> logNumbersSaved({
    required String lottery,
    required String strategy,
  }) =>
      _analytics.logEvent(
        name: 'numbers_saved',
        parameters: {'lottery': lottery, 'strategy': strategy},
      );
}
