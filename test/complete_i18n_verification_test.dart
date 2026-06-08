import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/data/seed_lotteries.dart';
import 'package:lottfun_flutter/l10n/generated/app_localizations.dart';
import 'package:lottfun_flutter/models/lottery_draw.dart';
import 'package:lottfun_flutter/services/draw_analysis_service.dart';

void main() {
  group('Complete i18n Verification', () {
    final lottery = kSeedLotteries.first;

    // Create draws with specific patterns for testing
    final mockDraws = List.generate(60, (index) {
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

    final targetDraw = LotteryDraw(
      lotteryId: lottery.id,
      drawDate: DateTime.now(),
      mainNumbers: [1, 5, 10, 15, 20, 25, 30],
      bonusNumbers: [],
    );

    test('Recent trends analysis returns Chinese text for all fields', () {
      final l10nZh = lookupAppLocalizations(const Locale('zh'));

      final trends = DrawAnalysisService.analyzeRecentTrends(
        lottery: lottery,
        draws: mockDraws,
        drawCount: 20,
        l10n: l10nZh,
      );

      // Verify odd/even pattern uses Chinese characters
      expect(trends.mostCommonOddEven.contains('奇'), true,
        reason: 'Odd/Even pattern should contain 奇 (odd)');
      expect(trends.mostCommonOddEven.contains('偶'), true,
        reason: 'Odd/Even pattern should contain 偶 (even)');
      expect(trends.mostCommonOddEven.contains('odd'), false,
        reason: 'Odd/Even pattern should not contain English "odd"');
      expect(trends.mostCommonOddEven.contains('even'), false,
        reason: 'Odd/Even pattern should not contain English "even"');

      // Verify low/high pattern uses Chinese characters
      expect(trends.mostCommonLowHigh.contains('低'), true,
        reason: 'Low/High pattern should contain 低 (low)');
      expect(trends.mostCommonLowHigh.contains('高'), true,
        reason: 'Low/High pattern should contain 高 (high)');
      expect(trends.mostCommonLowHigh.contains('low'), false,
        reason: 'Low/High pattern should not contain English "low"');
      expect(trends.mostCommonLowHigh.contains('high'), false,
        reason: 'Low/High pattern should not contain English "high"');

      // Verify summary is in Chinese
      expect(trends.summary.contains('近期') ||
             trends.summary.contains('结果') ||
             trends.summary.contains('均衡'), true,
        reason: 'Summary should contain Chinese text');
    });

    test('Historical pattern analysis returns Chinese text for all fields', () {
      final l10nZh = lookupAppLocalizations(const Locale('zh'));

      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: targetDraw,
        allDraws: mockDraws,
        similarDrawsLimit: 10,
        l10n: l10nZh,
      );

      expect(result, isNotNull, reason: 'Should have enough history for analysis');

      // Verify odd/even pattern uses Chinese characters
      expect(result!.oddEvenPattern.contains('奇'), true,
        reason: 'Odd/Even pattern should contain 奇');
      expect(result.oddEvenPattern.contains('偶'), true,
        reason: 'Odd/Even pattern should contain 偶');
      expect(result.oddEvenPattern.contains('odd'), false,
        reason: 'Should not contain English "odd"');
      expect(result.oddEvenPattern.contains('even'), false,
        reason: 'Should not contain English "even"');

      // Verify low/high pattern uses Chinese characters
      expect(result.lowHighPattern.contains('低'), true,
        reason: 'Low/High pattern should contain 低');
      expect(result.lowHighPattern.contains('高'), true,
        reason: 'Low/High pattern should contain 高');
      expect(result.lowHighPattern.contains('low'), false,
        reason: 'Should not contain English "low"');
      expect(result.lowHighPattern.contains('high'), false,
        reason: 'Should not contain English "high"');

      // Verify sum range label is in Chinese
      expect(result.sumRangeLabel.contains('范围') ||
             result.sumRangeLabel.contains('未知'), true,
        reason: 'Sum range label should be in Chinese');
      expect(result.sumRangeLabel.toLowerCase().contains('range'), false,
        reason: 'Should not contain English "range"');
      expect(result.sumRangeLabel.toLowerCase().contains('typical'), false,
        reason: 'Should not contain English "typical"');

      // Verify summary is in Chinese
      expect(result.summary.contains('历史') ||
             result.summary.contains('模式') ||
             result.summary.contains('比较'), true,
        reason: 'Summary should contain Chinese text');
      expect(result.summary.toLowerCase().contains('historical'), false,
        reason: 'Summary should not contain English text');
    });

    test('Saved picks analysis returns Chinese text for all fields', () {
      final l10nZh = lookupAppLocalizations(const Locale('zh'));

      final savedPicks = [
        [1, 5, 10, 15, 20, 25, 30],
        [2, 6, 11, 16, 21, 26, 31],
      ];

      final analysis = DrawAnalysisService.analyzeSavedPicks(
        savedMainNumbers: savedPicks,
        recentDraws: mockDraws,
        compareDrawCount: 20,
        l10n: l10nZh,
      );

      // Verify summary is in Chinese
      expect(analysis.summary.contains('号码') ||
             analysis.summary.contains('结果') ||
             analysis.summary.contains('重合'), true,
        reason: 'Summary should contain Chinese text');
    });

    test('English localization still works correctly', () {
      final l10nEn = lookupAppLocalizations(const Locale('en'));

      final trends = DrawAnalysisService.analyzeRecentTrends(
        lottery: lottery,
        draws: mockDraws,
        drawCount: 20,
        l10n: l10nEn,
      );

      // Verify English text is present
      expect(trends.mostCommonOddEven.contains('odd'), true);
      expect(trends.mostCommonOddEven.contains('even'), true);
      expect(trends.mostCommonLowHigh.contains('low'), true);
      expect(trends.mostCommonLowHigh.contains('high'), true);

      final result = DrawAnalysisService.analyzeHistoricalPattern(
        lottery: lottery,
        targetDraw: targetDraw,
        allDraws: mockDraws,
        l10n: l10nEn,
      );

      expect(result!.oddEvenPattern.contains('odd'), true);
      expect(result.oddEvenPattern.contains('even'), true);
      expect(result.lowHighPattern.contains('low'), true);
      expect(result.lowHighPattern.contains('high'), true);
      expect(result.sumRangeLabel.toLowerCase().contains('range') ||
             result.sumRangeLabel.contains('Unknown'), true);
    });

    test('Pattern format is consistent across locales', () {
      final l10nEn = lookupAppLocalizations(const Locale('en'));
      final l10nZh = lookupAppLocalizations(const Locale('zh'));

      final trendsEn = DrawAnalysisService.analyzeRecentTrends(
        lottery: lottery,
        draws: mockDraws,
        drawCount: 20,
        l10n: l10nEn,
      );

      final trendsZh = DrawAnalysisService.analyzeRecentTrends(
        lottery: lottery,
        draws: mockDraws,
        drawCount: 20,
        l10n: l10nZh,
      );

      // Both should contain the separator '/'
      expect(trendsEn.mostCommonOddEven.contains('/'), true);
      expect(trendsZh.mostCommonOddEven.contains('/'), true);
      expect(trendsEn.mostCommonLowHigh.contains('/'), true);
      expect(trendsZh.mostCommonLowHigh.contains('/'), true);

      // Both should have similar structure (number + word / number + word)
      final enOddEvenParts = trendsEn.mostCommonOddEven.split('/');
      final zhOddEvenParts = trendsZh.mostCommonOddEven.split('/');
      expect(enOddEvenParts.length, 2);
      expect(zhOddEvenParts.length, 2);
    });
  });
}
