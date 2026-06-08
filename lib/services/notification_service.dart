import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../l10n/generated/app_localizations_en.dart';
import '../navigator_key.dart';
import '../screens/saved_picks_screen.dart';

final _l10n = AppLocalizationsEn();

class NotificationService {
  static final instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'result_ready';
  static const _notifId = 42;
  static const _insightNotifId = 43;
  static const _weeklyNotifId = 44;

  Future<void> init() async {
    if (_initialized) {
      debugPrint('[NotificationService] Already initialized');
      return;
    }
    _initialized = true;
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
    debugPrint('[NotificationService] Initialized successfully');
  }

  void _handleTap(NotificationResponse response) {
    final navigator = globalNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.push(MaterialPageRoute(builder: (_) => const SavedPicksScreen()));
  }

  /// Returns true if the app was cold-launched by tapping a notification.
  Future<bool> checkLaunchedFromNotification() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false;
  }

  /// Requests OS permission and shows the result-ready notification.
  Future<void> showResultReady(int count) async {
    debugPrint('[NotificationService] Attempting to show result-ready notification (count: $count)');
    final granted = await _requestPermission();
    if (!granted) {
      debugPrint('[NotificationService] Permission denied for result-ready notification');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _l10n.notificationResultReadyChannel,
      channelDescription: _l10n.notificationResultsDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    final title = count == 1
        ? _l10n.notificationResultReadyTitle
        : _l10n.notificationResultsReadyTitle(count);

    await _plugin.show(
      _notifId,
      title,
      _l10n.notificationSavedNumbersReady,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
    debugPrint('[NotificationService] Result-ready notification sent successfully');
  }

  /// Shows a daily insight notification.
  Future<void> showDailyInsight(String body) async {
    debugPrint('[NotificationService] Attempting to show daily insight notification');
    final granted = await _requestPermission();
    if (!granted) {
      debugPrint('[NotificationService] Permission denied for daily insight notification');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'insights',
      _l10n.notificationDailyInsightsChannel,
      channelDescription: _l10n.notificationDailyDescription,
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
      _l10n.notificationDailyInsightTitle,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
    debugPrint('[NotificationService] Daily insight notification sent successfully');
  }

  /// Shows a weekly summary notification.
  Future<void> showWeeklySummary(String body) async {
    debugPrint('[NotificationService] Attempting to show weekly summary notification');
    final granted = await _requestPermission();
    if (!granted) {
      debugPrint('[NotificationService] Permission denied for weekly summary notification');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'weekly_summary',
      _l10n.notificationWeeklySummaryChannel,
      channelDescription: _l10n.notificationWeeklyDescription,
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
      _l10n.notificationWeeklySummaryTitle,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
    debugPrint('[NotificationService] Weekly summary notification sent successfully');
  }

  Future<bool> _requestPermission() async {
    debugPrint('[NotificationService] Requesting notification permission...');
    bool granted = false;
    if (Platform.isIOS) {
      granted = await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: false, sound: true) ??
          false;
    } else if (Platform.isAndroid) {
      granted = await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    debugPrint('[NotificationService] Permission ${granted ? "GRANTED" : "DENIED"}');
    return granted;
  }
}
