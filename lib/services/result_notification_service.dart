import 'package:flutter/foundation.dart';

import '../models/lottery_draw.dart';
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
  /// Safe to call on every app launch / resume — already-notified picks
  /// are skipped via the [GeneratedPick.hasNotifiedResultReady] flag.
  Future<void> checkAndNotify() async {
    try {
      final picks = await LocalStorageService.instance.getSavedPicks();
      final newlyResolved = <String>[];

      // Fetch network draws per lottery ID (deduplicated).
      final uniqueIds = picks
          .where((p) => !p.hasNotifiedResultReady && p.drawDate != null)
          .map((p) => p.lotteryId)
          .toSet();

      final drawsCache = <String, List<LotteryDraw>>{};
      await Future.wait(uniqueIds.map((id) async {
        final lottery = LotteryService.instance.getLotteryById(id);
        if (lottery == null) return;
        try {
          final result = await LotteryHistoryCsvService.instance.fetchDraws(lottery);
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

        final draws = drawsCache[pick.lotteryId] ?? LotteryService.instance.getDraws(pick.lotteryId);
        final result = checkPickResult(pick, lottery, draws);
        if (result != null && !result.isPending) {
          newlyResolved.add(pick.id);
        }
      }

      if (newlyResolved.isEmpty) return;

      // Mark first so a rapid second call doesn't double-notify.
      await LocalStorageService.instance.markPicksNotified(newlyResolved.toSet());
      await NotificationService.instance.showResultReady(newlyResolved.length);
    } catch (e) {
      debugPrint('ResultNotificationService error: $e');
    }
  }
}
