import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../navigator_key.dart';
import '../screens/saved_picks_screen.dart';

class NotificationService {
  static final instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'result_ready';
  static const _channelName = 'Result Ready';
  static const _notifId = 42;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _handleTap,
    );
  }

  void _handleTap(NotificationResponse response) {
    final navigator = globalNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.push(
      MaterialPageRoute(builder: (_) => const SavedPicksScreen()),
    );
  }

  /// Returns true if the app was cold-launched by tapping a notification.
  Future<bool> checkLaunchedFromNotification() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false;
  }

  /// Requests OS permission and shows the notification.
  /// Silently skips if the user has denied permission.
  Future<void> showResultReady(int count) async {
    final granted = await _requestPermission();
    if (!granted) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifies when lottery draw results are available',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    final title =
        count == 1 ? 'Result Ready 🎯' : '$count Results Ready 🎯';

    await _plugin.show(
      _notifId,
      title,
      'Your saved lottery numbers are ready to check',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<bool> _requestPermission() async {
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: false, sound: true) ??
          false;
    }
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return false;
  }
}
