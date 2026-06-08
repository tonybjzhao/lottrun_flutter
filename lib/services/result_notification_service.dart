import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../data/seed_lotteries.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/lottery_draw.dart';
import '../services/insight_service.dart';
import '../services/locale_service.dart';
import '../services/local_storage_service.dart';
import '../services/lottery_history_csv_service.dart';
import '../services/lottery_service.dart';
import '../services/notification_service.dart';
import '../services/pick_result_service.dart';

class ResultNotificationService {
  static final instance = ResultNotificationService._();
  ResultNotificationService._();

  AppLocalizations get _l10n => lookupAppLocalizations(
    LocaleService.instance.locale ?? const Locale('en'),
  );

  /// Rebuilds local OS schedules for daily and weekly insight notifications.
  /// The body is generated from the latest history available in the app when
  /// schedules are refreshed.
  Future<void> refreshScheduledInsightNotifications() async {
    debugPrint('[ResultNotificationService] Refreshing scheduled insights...');
    await NotificationService.instance.cancelScheduledInsights();

    if (kSeedLotteries.isEmpty) return;
    final time = await InsightService.instance.getNotificationScheduleTime();
    final lottery = kSeedLotteries.first;
    final draws = LotteryService.instance.getDraws(lottery.id);
    final l10n = _l10n;

    final dailyEnabled = await InsightService.instance.getNotifPref(
      kNotifKeyDailyInsight,
      defaultValue: false,
    );
    if (dailyEnabled) {
      final body = await InsightService.instance.getDailyInsight(
        lottery: lottery,
        draws: draws,
        l10n: l10n,
      );
      await NotificationService.instance.scheduleDailyInsight(
        hour: time.hour,
        minute: time.minute,
        body: body,
      );
    }

    final weeklyEnabled = await InsightService.instance.getNotifPref(
      kNotifKeyWeeklySummary,
    );
    if (weeklyEnabled) {
      final body = InsightService.instance.weeklySummaryBody(
        lottery: lottery,
        draws: draws,
        l10n: l10n,
      );
      await NotificationService.instance.scheduleWeeklySummary(
        hour: time.hour,
        minute: time.minute,
        body: body,
      );
    }
  }

  /// Checks all saved picks for newly resolved results and fires a local
  /// notification if any pick transitioned from pending → result ready.
  /// Also fires daily insight and weekly summary notifications when enabled.
  /// Hard cap: max 2 notifications per day total.
  Future<void> checkAndNotify() async {
    debugPrint(
      '[ResultNotificationService] ═══ Starting notification check at ${DateTime.now()} ═══',
    );
    try {
      await _checkResults();
      await _checkWeeklySummary();
      await _checkDailyInsight();
      debugPrint(
        '[ResultNotificationService] ═══ Notification check complete ═══',
      );
    } catch (e, stack) {
      debugPrint('[ResultNotificationService] ❌ ERROR: $e');
      debugPrint('[ResultNotificationService] Stack trace: $stack');
    }
  }

  Future<void> _checkResults() async {
    debugPrint('[ResultNotificationService] Checking results...');
    final resultsEnabled = await InsightService.instance.getNotifPref(
      kNotifKeyResults,
    );
    final myPicksEnabled = await InsightService.instance.getNotifPref(
      kNotifKeyMyPicks,
    );
    debugPrint(
      '[ResultNotificationService] Results enabled: $resultsEnabled, My Picks enabled: $myPicksEnabled',
    );
    if (!resultsEnabled || !myPicksEnabled) {
      debugPrint(
        '[ResultNotificationService] Result notifications disabled, skipping',
      );
      return;
    }

    final picks = await LocalStorageService.instance.getSavedPicks();
    final newlyResolved = <String>[];

    final uniqueIds = picks
        .where((p) => !p.hasNotifiedResultReady && p.drawDate != null)
        .map((p) => p.lotteryId)
        .toSet();

    final drawsCache = <String, List<LotteryDraw>>{};
    await Future.wait(
      uniqueIds.map((id) async {
        final lottery = LotteryService.instance.getLotteryById(id);
        if (lottery == null) return;
        try {
          final result = await LotteryHistoryCsvService.instance.fetchDraws(
            lottery,
          );
          drawsCache[id] = result.draws;
        } catch (_) {
          drawsCache[id] = LotteryService.instance.getDraws(id);
        }
      }),
    );

    for (final pick in picks) {
      if (pick.hasNotifiedResultReady) continue;
      if (pick.drawDate == null) continue;
      final lottery = LotteryService.instance.getLotteryById(pick.lotteryId);
      if (lottery == null) continue;
      final draws =
          drawsCache[pick.lotteryId] ??
          LotteryService.instance.getDraws(pick.lotteryId);
      final result = checkPickResult(pick, lottery, draws);
      if (result != null && !result.isPending) {
        newlyResolved.add(pick.id);
      }
    }

    debugPrint(
      '[ResultNotificationService] Found ${newlyResolved.length} newly resolved picks',
    );
    if (newlyResolved.isEmpty) {
      debugPrint(
        '[ResultNotificationService] No newly resolved picks, skipping notification',
      );
      return;
    }
    final canSend = await InsightService.instance.canSendNotification();
    debugPrint(
      '[ResultNotificationService] Can send notification (daily cap check): $canSend',
    );
    if (!canSend) {
      debugPrint(
        '[ResultNotificationService] Daily notification cap reached, skipping',
      );
      return;
    }

    await LocalStorageService.instance.markPicksNotified(newlyResolved.toSet());
    await NotificationService.instance.showResultReady(newlyResolved.length);
    await InsightService.instance.recordNotificationSent();
    debugPrint(
      '[ResultNotificationService] ✓ Result notification sent for ${newlyResolved.length} picks',
    );
  }

  Future<void> _checkWeeklySummary() async {
    debugPrint('[ResultNotificationService] Checking weekly summary...');
    final enabled = await InsightService.instance.getNotifPref(
      kNotifKeyWeeklySummary,
    );
    debugPrint('[ResultNotificationService] Weekly summary enabled: $enabled');
    if (!enabled) {
      debugPrint(
        '[ResultNotificationService] Weekly summary disabled, skipping',
      );
      return;
    }
    final shouldSend = await InsightService.instance.shouldSendWeeklySummary();
    debugPrint(
      '[ResultNotificationService] Should send weekly (timing check): $shouldSend',
    );
    if (!shouldSend) {
      debugPrint(
        '[ResultNotificationService] Not Sunday or already sent this week, skipping',
      );
      return;
    }
    final canSend = await InsightService.instance.canSendNotification();
    debugPrint(
      '[ResultNotificationService] Can send notification (daily cap check): $canSend',
    );
    if (!canSend) {
      debugPrint(
        '[ResultNotificationService] Daily notification cap reached, skipping',
      );
      return;
    }

    // Use the first available lottery for the summary
    if (kSeedLotteries.isEmpty) return;
    final lottery = kSeedLotteries.first;
    final draws = LotteryService.instance.getDraws(lottery.id);

    final body = InsightService.instance.weeklySummaryBody(
      lottery: lottery,
      draws: draws,
      l10n: _l10n,
    );

    await NotificationService.instance.showWeeklySummary(body);
    await InsightService.instance.recordNotificationSent();
    await InsightService.instance.recordWeeklySummarySent();
    debugPrint(
      '[ResultNotificationService] ✓ Weekly summary notification sent',
    );
  }

  Future<void> _checkDailyInsight() async {
    debugPrint('[ResultNotificationService] Checking daily insight...');
    final enabled = await InsightService.instance.getNotifPref(
      kNotifKeyDailyInsight,
      defaultValue: false,
    );
    debugPrint('[ResultNotificationService] Daily insight enabled: $enabled');
    if (!enabled) {
      debugPrint(
        '[ResultNotificationService] Daily insight disabled, skipping',
      );
      return;
    }
    final canSend = await InsightService.instance.canSendNotification();
    debugPrint(
      '[ResultNotificationService] Can send notification (daily cap check): $canSend',
    );
    if (!canSend) {
      debugPrint(
        '[ResultNotificationService] Daily notification cap reached, skipping',
      );
      return;
    }

    if (kSeedLotteries.isEmpty) return;
    final lottery = kSeedLotteries.first;
    final draws = LotteryService.instance.getDraws(lottery.id);

    final body = await InsightService.instance.getDailyInsight(
      lottery: lottery,
      draws: draws,
      l10n: _l10n,
    );

    await NotificationService.instance.showDailyInsight(body);
    await InsightService.instance.recordNotificationSent();
    debugPrint('[ResultNotificationService] ✓ Daily insight notification sent');
  }
}
