import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

/// Central analytics service. All event logging flows through here so
/// parameter names and values stay consistent across the codebase.
///
/// Call [AnalyticsService.init] once in main() with the Firebase.initializeApp
/// future. Every log method awaits that future internally before proceeding, so
/// no event ever fires before Firebase is ready — and runApp() is never blocked.
class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalytics get instance => _analytics;

  // Stored so every log call can await Firebase being ready.
  static Future<FirebaseApp>? _initFuture;

  /// Called once from main() immediately after Firebase.initializeApp().
  static void init(Future<FirebaseApp> firebaseInit) {
    _initFuture = firebaseInit;
    // Log app_open as soon as Firebase is ready (fire-and-forget from here).
    unawaited(firebaseInit.then((_) => _analytics.logAppOpen()));
  }

  /// Awaits Firebase init before returning. All log methods call this first.
  static Future<void> _ready() async {
    if (_initFuture != null) await _initFuture;
  }

  // ── Core events ──────────────────────────────────────────────────────────────

  /// Fired every time a pick is produced.
  /// [source] is stable: 'home' | 'three_picks'
  static Future<void> logGenerateNumbers({
    required String lottery,
    required String strategy,
    required int pickCount,
    required String source,
  }) async {
    await _ready();
    return _analytics.logEvent(
      name: 'generate_numbers',
      parameters: {
        'lottery': lottery,
        'strategy': strategy,
        'pick_count': pickCount,
        'source': source,
      },
    );
  }

  /// Fired when the user switches play style (Balanced / Hot / Cold / Random).
  static Future<void> logPickStrategySelected({
    required String strategy,
    required String lottery,
  }) async {
    await _ready();
    return _analytics.logEvent(
      name: 'pick_strategy_selected',
      parameters: {'strategy': strategy, 'lottery': lottery},
    );
  }

  /// Fired when the History screen mounts.
  static Future<void> logHistoryOpened({required String lottery}) async {
    await _ready();
    return _analytics.logEvent(
      name: 'history_opened',
      parameters: {'lottery': lottery},
    );
  }

  /// Fired when the user switches from one lottery to another.
  static Future<void> logLotteryChanged({
    required String fromLottery,
    required String toLottery,
  }) async {
    await _ready();
    return _analytics.logEvent(
      name: 'lottery_changed',
      parameters: {'from_lottery': fromLottery, 'to_lottery': toLottery},
    );
  }

  /// Fired when the user saves a pick locally.
  static Future<void> logNumbersSaved({
    required String lottery,
    required String strategy,
  }) async {
    await _ready();
    return _analytics.logEvent(
      name: 'numbers_saved',
      parameters: {'lottery': lottery, 'strategy': strategy},
    );
  }
}
