import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/data/seed_lotteries.dart';
import 'package:lottfun_flutter/l10n/generated/app_localizations.dart';
import 'package:lottfun_flutter/models/lottery_draw.dart';
import 'package:lottfun_flutter/services/insight_service.dart';

void main() {
  group('Daily Insight i18n Tests', () {
    final lottery = kSeedLotteries.first;

    final mockDraws = List.generate(30, (index) {
      return LotteryDraw(
        lotteryId: lottery.id,
        drawDate: DateTime.now().subtract(Duration(days: index + 1)),
        mainNumbers: [
          1 + (index % 3),
          5 + (index % 4),
          10 + (index % 5),
          15 + (index % 6),
          20 + (index % 7),
          25 + (index % 8),
          30 + (index % 9),
        ],
        bonusNumbers: [],
      );
    });

    test('Daily insight returns Chinese text when locale is zh', () async {
      final l10nZh = lookupAppLocalizations(const Locale('zh'));

      final insight = await InsightService.instance.getDailyInsight(
        lottery: lottery,
        draws: mockDraws,
        l10n: l10nZh,
      );

      // Verify the insight contains Chinese characters
      expect(
        insight.contains('近期') ||
            insight.contains('结果') ||
            insight.contains('号码') ||
            insight.contains('均衡') ||
            insight.contains('模式'),
        true,
        reason: 'Daily insight should contain Chinese text, got: $insight',
      );

      // Verify it does NOT contain common English words
      expect(
        insight.toLowerCase().contains('recent'),
        false,
        reason: 'Should not contain English "recent"',
      );
      expect(
        insight.toLowerCase().contains('draws'),
        false,
        reason: 'Should not contain English "draws"',
      );
      expect(
        insight.toLowerCase().contains('pattern'),
        false,
        reason: 'Should not contain English "pattern"',
      );
      expect(
        insight.toLowerCase().contains('show'),
        false,
        reason: 'Should not contain English "show"',
      );
    });

    test('Daily insight returns English text when locale is en', () async {
      final l10nEn = lookupAppLocalizations(const Locale('en'));

      final insight = await InsightService.instance.getDailyInsight(
        lottery: lottery,
        draws: mockDraws,
        l10n: l10nEn,
      );

      // Verify the insight contains English text
      expect(
        insight.toLowerCase().contains('recent') ||
            insight.toLowerCase().contains('draw') ||
            insight.toLowerCase().contains('balanced') ||
            insight.toLowerCase().contains('pattern'),
        true,
        reason: 'Daily insight should contain English text',
      );
    });

    test('Daily insight handles empty draws gracefully in Chinese', () async {
      final l10nZh = lookupAppLocalizations(const Locale('zh'));

      final insight = await InsightService.instance.getDailyInsight(
        lottery: lottery,
        draws: [],
        l10n: l10nZh,
      );

      // Should return a Chinese message
      expect(
        insight.contains('均衡') ||
            insight.contains('模式') ||
            insight.contains('强') ||
            insight.contains('检测'),
        true,
        reason: 'Empty draws should return Chinese text',
      );
    });

    test('Daily insight uses fallback when no locale provided', () async {
      final insight = await InsightService.instance.getDailyInsight(
        lottery: lottery,
        draws: mockDraws,
      );

      // Should return English (fallback)
      expect(insight.isNotEmpty, true);
    });

    test('Weekly summary returns Chinese text when locale is zh', () {
      final l10nZh = lookupAppLocalizations(const Locale('zh'));

      final summary = InsightService.instance.weeklySummaryBody(
        lottery: lottery,
        draws: mockDraws,
        l10n: l10nZh,
      );

      // Verify the summary contains Chinese characters
      expect(
        summary.contains('本周') ||
            summary.contains('每周') ||
            summary.contains('最近') ||
            summary.contains('热门') ||
            summary.contains('分布') ||
            summary.contains('均衡') ||
            summary.contains('集中') ||
            summary.contains('趋势'),
        true,
        reason: 'Weekly summary should contain Chinese text, got: $summary',
      );

      // Verify it does NOT contain English words
      expect(
        summary.toLowerCase().contains('week'),
        false,
        reason: 'Should not contain English "week"',
      );
      expect(
        summary.toLowerCase().contains('distribution'),
        false,
        reason: 'Should not contain English "distribution"',
      );
      expect(
        summary.contains('20'),
        true,
        reason: 'Weekly summary should include the dynamic draw count',
      );
    });

    test('Weekly summary returns English text when locale is en', () {
      final l10nEn = lookupAppLocalizations(const Locale('en'));

      final summary = InsightService.instance.weeklySummaryBody(
        lottery: lottery,
        draws: mockDraws,
        l10n: l10nEn,
      );

      // Verify the summary contains English text
      expect(
        summary.toLowerCase().contains('week') ||
            summary.toLowerCase().contains('latest') ||
            summary.toLowerCase().contains('hot') ||
            summary.toLowerCase().contains('balanced') ||
            summary.toLowerCase().contains('concentration'),
        true,
        reason: 'Weekly summary should contain English text',
      );
      expect(
        summary.contains('20'),
        true,
        reason: 'Weekly summary should include the dynamic draw count',
      );
    });
  });
}
