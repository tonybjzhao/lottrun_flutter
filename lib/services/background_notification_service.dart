import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import 'insight_service.dart';
import 'locale_service.dart';
import 'result_notification_service.dart';

const String kInsightNotificationRefreshTask =
    'com.lottfun.notifications.refresh';

class BackgroundNotificationService {
  BackgroundNotificationService._();
  static final instance = BackgroundNotificationService._();

  static const _taskName = 'refreshInsightNotificationSchedule';
  static const _refreshLead = Duration(minutes: 15);

  Future<void> initialize() async {
    await Workmanager().initialize(notificationBackgroundDispatcher);
  }

  Future<void> refreshRegistration() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final dailyEnabled = await InsightService.instance.getNotifPref(
      kNotifKeyDailyInsight,
      defaultValue: false,
    );
    final weeklyEnabled = await InsightService.instance.getNotifPref(
      kNotifKeyWeeklySummary,
    );

    if (!dailyEnabled && !weeklyEnabled) {
      await Workmanager().cancelByUniqueName(kInsightNotificationRefreshTask);
      return;
    }

    final scheduleTime = await InsightService.instance
        .getNotificationScheduleTime();
    await Workmanager().registerPeriodicTask(
      kInsightNotificationRefreshTask,
      _taskName,
      frequency: const Duration(hours: 24),
      flexInterval: const Duration(hours: 1),
      initialDelay: _initialDelayBefore(
        hour: scheduleTime.hour,
        minute: scheduleTime.minute,
      ),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  Duration _initialDelayBefore({required int hour, required int minute}) {
    final now = DateTime.now();
    var refreshAt = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).subtract(_refreshLead);
    if (!refreshAt.isAfter(now)) {
      refreshAt = refreshAt.add(const Duration(days: 1));
    }
    return refreshAt.difference(now);
  }
}

@pragma('vm:entry-point')
void notificationBackgroundDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    try {
      await LocaleService.instance.load();
      await ResultNotificationService.instance
          .refreshScheduledInsightNotifications();
      await BackgroundNotificationService.instance.refreshRegistration();
      return true;
    } catch (_) {
      return false;
    }
  });
}
