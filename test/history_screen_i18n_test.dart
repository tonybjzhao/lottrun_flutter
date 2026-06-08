import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/data/seed_lotteries.dart';
import 'package:lottfun_flutter/l10n/generated/app_localizations.dart';
import 'package:lottfun_flutter/models/lottery_draw.dart';
import 'package:lottfun_flutter/screens/history_screen.dart';
import 'package:lottfun_flutter/widgets/recent_draw_trends_section.dart';

void main() {
  group('History Screen i18n Tests', () {
    testWidgets('Shows localized odd/even pattern in English', (
      WidgetTester tester,
    ) async {
      final lottery = kSeedLotteries.first;
      final mockDraws = [
        LotteryDraw(
          lotteryId: lottery.id,
          drawDate: DateTime.now().subtract(const Duration(days: 1)),
          mainNumbers: [1, 2, 3, 4, 5, 6, 7],
          bonusNumbers: [],
        ),
        LotteryDraw(
          lotteryId: lottery.id,
          drawDate: DateTime.now().subtract(const Duration(days: 2)),
          mainNumbers: [2, 4, 6, 8, 10, 12, 14],
          bonusNumbers: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RecentDrawTrendsSection(
              lottery: lottery,
              draws: mockDraws,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for English odd/even text
      expect(find.textContaining('odd'), findsAtLeastNWidgets(1));
      expect(find.textContaining('even'), findsAtLeastNWidgets(1));

      // Check for English low/high text
      expect(find.textContaining('low'), findsAtLeastNWidgets(1));
      expect(find.textContaining('high'), findsAtLeastNWidgets(1));
    });

    testWidgets('Shows localized odd/even pattern in Chinese', (
      WidgetTester tester,
    ) async {
      final lottery = kSeedLotteries.first;
      final mockDraws = [
        LotteryDraw(
          lotteryId: lottery.id,
          drawDate: DateTime.now().subtract(const Duration(days: 1)),
          mainNumbers: [1, 2, 3, 4, 5, 6, 7],
          bonusNumbers: [],
        ),
        LotteryDraw(
          lotteryId: lottery.id,
          drawDate: DateTime.now().subtract(const Duration(days: 2)),
          mainNumbers: [2, 4, 6, 8, 10, 12, 14],
          bonusNumbers: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RecentDrawTrendsSection(
              lottery: lottery,
              draws: mockDraws,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for Chinese odd/even text (奇/偶)
      expect(find.textContaining('奇'), findsAtLeastNWidgets(1));
      expect(find.textContaining('偶'), findsAtLeastNWidgets(1));

      // Check for Chinese low/high text (低/高)
      expect(find.textContaining('低'), findsAtLeastNWidgets(1));
      expect(find.textContaining('高'), findsAtLeastNWidgets(1));

      // Ensure no English text appears
      expect(find.textContaining('odd'), findsNothing);
      expect(find.textContaining('even'), findsNothing);
      expect(find.textContaining('low'), findsNothing);
      expect(find.textContaining('high'), findsNothing);
    });

    testWidgets('Stat cards render without truncation on small screen (360dp)', (
      WidgetTester tester,
    ) async {
      // Set small screen size (360x640 is a common small Android screen)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final lottery = kSeedLotteries.first;
      final mockDraws = [
        LotteryDraw(
          lotteryId: lottery.id,
          drawDate: DateTime.now().subtract(const Duration(days: 1)),
          mainNumbers: [1, 3, 5, 7, 9, 11, 13],
          bonusNumbers: [],
        ),
        LotteryDraw(
          lotteryId: lottery.id,
          drawDate: DateTime.now().subtract(const Duration(days: 2)),
          mainNumbers: [2, 4, 6, 8, 10, 12, 14],
          bonusNumbers: [],
        ),
      ];

      // Test with English (longer text)
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RecentDrawTrendsSection(
              lottery: lottery,
              draws: mockDraws,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find stat chips and verify they rendered
      final oddEvenFinder = find.textContaining('odd');
      final lowHighFinder = find.textContaining('low');

      expect(oddEvenFinder, findsAtLeastNWidgets(1));
      expect(lowHighFinder, findsAtLeastNWidgets(1));

      // Verify no overflow warnings (would cause test failure if present)
    });

    testWidgets('Stat cards render without truncation in Chinese on small screen', (
      WidgetTester tester,
    ) async {
      // Set small screen size
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final lottery = kSeedLotteries.first;
      final mockDraws = [
        LotteryDraw(
          lotteryId: lottery.id,
          drawDate: DateTime.now().subtract(const Duration(days: 1)),
          mainNumbers: [1, 3, 5, 7, 9, 11, 13],
          bonusNumbers: [],
        ),
        LotteryDraw(
          lotteryId: lottery.id,
          drawDate: DateTime.now().subtract(const Duration(days: 2)),
          mainNumbers: [2, 4, 6, 8, 10, 12, 14],
          bonusNumbers: [],
        ),
      ];

      // Test with Chinese (shorter text, but still validate)
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RecentDrawTrendsSection(
              lottery: lottery,
              draws: mockDraws,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find stat chips and verify they rendered
      final oddEvenFinder = find.textContaining('奇');
      final lowHighFinder = find.textContaining('低');

      expect(oddEvenFinder, findsAtLeastNWidgets(1));
      expect(lowHighFinder, findsAtLeastNWidgets(1));

      // Verify no overflow warnings
    });
  });
}
