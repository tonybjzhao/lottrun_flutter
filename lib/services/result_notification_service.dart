import 'package:flutter/foundation.dart';

import '../data/seed_lotteries.dart';
import '../models/lottery_draw.dart';
import '../services/insight_service.dart';
import '../services/local_storage_service.dart';
import '../services/lottery_history_csv_service.dart';
import '../services/lottery_service.dart';
import '../services/notification_service.dart';
import '../services/pick_result_service.dart';

class ResultNotificationService {
  static final instance = ResultNotificationService._();
  ResultNotificationService._();

  /// Checks all saved picks for newly resolved results and fires a local
  /// notification if any pick transitioned from pending → result ready.
  /// Also fires daily insight and weekly summary notifications when enabled.
  /// Hard cap: max 2 notifications per day total.
  Future<void> checkAndNotify() async {
    try {
      await _checkResults();
      await _checkWeeklySummary();
      await _checkDailyInsight();
    } catch (e) {
      debugPrint('ResultNotificationService error: $e');
    }
  }

  Future<void> _checkResults() async {
    final resultsEnabled = await InsightService.instance
        .getNotifPref(kNotifKeyResults);
    final myPicksEnabled = await InsightService.instance
        .getNotifPref(kNotifKeyMyPicks);
    if (!resultsEnabled || !myPicksEnabled) return;

    final picks = await LocalStorageService.instance.getSavedPicks();
    final newlyResolved = <String>[];

    final uniqueIds = picks
        .where((p) => !p.hasNotifiedResultReady && p.drawDate != null)
        .map((p) => p.lotteryId)
        .toSet();

    final drawsCache = <String, List<LotteryDraw>>{};
    await Future.wait(uniqueIds.map((id) async {
      final lottery = LotteryService.instance.getLotteryById(id);
      if (lottery == null) return;
      try {
        final result =
            await LotteryHistoryCsvService.instance.fetchDraws(lottery);
        drawsCache[id] = result.draws;
      } catch (_) {
        drawsCache[id] = LotteryService.instance.getDraws(id);
      }
    }));

    for (final pick in picks) {
      if (pick.hasNotifiedResultReady) continue;
      if (pick.drawDate == null) continue;
      final lottery = LotteryService.instance.getLotteryById(pick.lotteryId);
      if (lottery == null) continue;
      final draws = drawsCache[pick.lotteryId] ??
          LotteryService.instance.getDraws(pick.lotteryId);
      final result = checkPickResult(pick, lottery, draws);
      if (result != null && !result.isPending) {
        newlyResolved.add(pick.id);
      }
    }

    if (newlyResolved.isEmpty) return;
    if (!await InsightService.instance.canSendNotification()) return;

    await LocalStorageService.instance
        .markPicksNotified(newlyResolved.toSet());
    await NotificationService.instance.showResultReady(newlyResolved.length);
    await InsightService.instance.recordNotificationSent();
  }

  Future<void> _checkWeeklySummary() async {
    final enabled = await InsightService.instance
        .getNotifPref(kNotifKeyWeeklySummary);
    if (!enabled) return;
    if (!await InsightService.instance.shouldSendWeeklySummary()) return;
    if (!await InsightService.instance.canSendNotification()) return;

    // Use the first available lottery for the summary
    if (kSeedLotteries.isEmpty) return;
    final lottery = kSeedLotteries.first;
    final draws = LotteryService.instance.getDraws(lottery.id);

    final body = InsightService.instance
        .weeklySummaryBody(lottery: lottery, draws: draws);

    await NotificationService.instance.showWeeklySummary(body);
    await InsightService.instance.recordNotificationSent();
    await InsightService.instance.recordWeeklySummarySent();
  }

  Future<void> _checkDailyInsight() async {
    final enabled = await InsightService.instance
        .getNotifPref(kNotifKeyDailyInsight, defaultValue: false);
    if (!enabled) return;
    if (!await InsightService.instance.canSendNotification()) return;

    if (kSeedLotteries.isEmpty) return;
    final lottery = kSeedLotteries.first;
    final draws = LotteryService.instance.getDraws(lottery.id);

    final body = await InsightService.instance
        .getDailyInsight(lottery: lottery, draws: draws);

    await NotificationService.instance.showDailyInsight(body);
    await InsightService.instance.recordNotificationSent();
  }
}
