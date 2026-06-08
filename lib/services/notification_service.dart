import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../l10n/generated/app_localizations.dart';
import '../navigator_key.dart';
import '../screens/saved_picks_screen.dart';
import 'locale_service.dart';

class NotificationService {
  static final instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Future<void>? _initFuture;

  static const _channelId = 'result_ready';
  static const _notifId = 42;
  static const _insightNotifId = 43;
  static const _weeklyNotifId = 44;

  Future<void> init() async {
    if (_initialized) {
      debugPrint('[NotificationService] Already initialized');
      return;
    }
    if (_initFuture != null) {
      await _initFuture;
      return;
    }
    _initFuture = _init();
    try {
      await _initFuture;
    } finally {
      if (!_initialized) {
        _initFuture = null;
      }
    }
  }

  Future<void> _init() async {
    debugPrint('[NotificationService] Initializing...');

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _handleTap,
    );
    _initialized = true;
    debugPrint('[NotificationService] Initialized successfully');
  }

  AppLocalizations get _l10n => lookupAppLocalizations(
    LocaleService.instance.locale ?? const Locale('en'),
  );

  void _handleTap(NotificationResponse response) {
    final navigator = globalNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.push(MaterialPageRoute(builder: (_) => const SavedPicksScreen()));
  }

  /// Returns true if the app was cold-launched by tapping a notification.
  Future<bool> checkLaunchedFromNotification() async {
    await init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false;
  }

  /// Requests OS permission and shows the result-ready notification.
  Future<void> showResultReady(int count) async {
    await init();
    final l10n = _l10n;
    debugPrint(
      '[NotificationService] Attempting to show result-ready notification (count: $count)',
    );
    final granted = await _requestPermission();
    if (!granted) {
      debugPrint(
        '[NotificationService] Permission denied for result-ready notification',
      );
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      l10n.notificationResultReadyChannel,
      channelDescription: l10n.notificationResultsDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    final title = count == 1
        ? l10n.notificationResultReadyTitle
        : l10n.notificationResultsReadyTitle(count);

    await _plugin.show(
      _notifId,
      title,
      l10n.notificationSavedNumbersReady,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
    debugPrint(
      '[NotificationService] Result-ready notification sent successfully',
    );
  }

  /// Shows a daily insight notification.
  Future<void> showDailyInsight(String body) async {
    await init();
    final l10n = _l10n;
    debugPrint(
      '[NotificationService] Attempting to show daily insight notification',
    );
    final granted = await _requestPermission();
    if (!granted) {
      debugPrint(
        '[NotificationService] Permission denied for daily insight notification',
      );
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'insights',
      l10n.notificationDailyInsightsChannel,
      channelDescription: l10n.notificationDailyDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    await _plugin.show(
      _insightNotifId,
      l10n.notificationDailyInsightTitle,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
    debugPrint(
      '[NotificationService] Daily insight notification sent successfully',
    );
  }

  /// Shows a weekly summary notification.
  Future<void> showWeeklySummary(String body) async {
    await init();
    final l10n = _l10n;
    debugPrint(
      '[NotificationService] Attempting to show weekly summary notification',
    );
    final granted = await _requestPermission();
    if (!granted) {
      debugPrint(
        '[NotificationService] Permission denied for weekly summary notification',
      );
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'weekly_summary',
      l10n.notificationWeeklySummaryChannel,
      channelDescription: l10n.notificationWeeklyDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    await _plugin.show(
      _weeklyNotifId,
      l10n.notificationWeeklySummaryTitle,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
    debugPrint(
      '[NotificationService] Weekly summary notification sent successfully',
    );
  }

  Future<bool> _requestPermission() async {
    debugPrint('[NotificationService] Requesting notification permission...');
    bool granted = false;
    if (Platform.isIOS) {
      granted =
          await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: false, sound: true) ??
          false;
    } else if (Platform.isAndroid) {
      granted =
          await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    debugPrint(
      '[NotificationService] Permission ${granted ? "GRANTED" : "DENIED"}',
    );
    return granted;
  }
}
