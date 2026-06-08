import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/data/seed_lotteries.dart';
import 'package:lottfun_flutter/l10n/generated/app_localizations.dart';
import 'package:lottfun_flutter/models/lottery_draw.dart';
import 'package:lottfun_flutter/widgets/historical_pattern_match_card.dart';

void main() {
  group('Historical Pattern Match Card i18n Tests', () {
    final lottery = kSeedLotteries.first;

    // Create sufficient historical draws (52+ required for analysis)
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

    testWidgets('Shows localized odd/even pattern in English', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HistoricalPatternMatchCard(
                lottery: lottery,
                targetDraw: targetDraw,
                allDraws: mockDraws,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for English odd/even text in chips
      expect(find.textContaining('odd'), findsAtLeastNWidgets(1));
      expect(find.textContaining('even'), findsAtLeastNWidgets(1));

      // Check for English low/high text
      expect(find.textContaining('low'), findsAtLeastNWidgets(1));
      expect(find.textContaining('high'), findsAtLeastNWidgets(1));

      // Check for English range labels
      final rangeLabelFinder = find.textContaining('range');
      expect(rangeLabelFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('Shows localized odd/even pattern in Chinese', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HistoricalPatternMatchCard(
                lottery: lottery,
                targetDraw: targetDraw,
                allDraws: mockDraws,
              ),
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

      // Check for Chinese range labels (范围)
      expect(find.textContaining('范围'), findsAtLeastNWidgets(1));

      // Ensure no English text appears in odd/even
      expect(find.textContaining('odd'), findsNothing);
      expect(find.textContaining('even'), findsNothing);

      // Note: 'low' and 'high' as standalone words shouldn't appear
      // but we need to be careful not to match them in other contexts
      final textFinder = find.byType(Text);
      final textWidgets = tester.widgetList<Text>(textFinder);

      for (final textWidget in textWidgets) {
        final text = textWidget.data ?? '';
        // Check that pattern strings don't contain English odd/even/low/high
        if (text.contains('/')) {
          expect(text.contains('odd'), false,
            reason: 'Found English "odd" in pattern text: $text');
          expect(text.contains('even'), false,
            reason: 'Found English "even" in pattern text: $text');
          expect(text.contains('low'), false,
            reason: 'Found English "low" in pattern text: $text');
          expect(text.contains('high'), false,
            reason: 'Found English "high" in pattern text: $text');
        }
      }
    });

    testWidgets('Shows localized summary in Chinese', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HistoricalPatternMatchCard(
                lottery: lottery,
                targetDraw: targetDraw,
                allDraws: mockDraws,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for Chinese summary text
      // The summary should contain Chinese text about historical comparison
      expect(find.textContaining('历史'), findsAtLeastNWidgets(1));
    });

    testWidgets('All chips render without truncation on small screen in Chinese', (
      WidgetTester tester,
    ) async {
      // Set small screen size (360dp width)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HistoricalPatternMatchCard(
                lottery: lottery,
                targetDraw: targetDraw,
                allDraws: mockDraws,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify chips rendered with Chinese text
      expect(find.textContaining('奇'), findsAtLeastNWidgets(1));
      expect(find.textContaining('偶'), findsAtLeastNWidgets(1));
      expect(find.textContaining('低'), findsAtLeastNWidgets(1));
      expect(find.textContaining('高'), findsAtLeastNWidgets(1));

      // No overflow errors should occur
    });

    testWidgets('Score labels are localized in Chinese', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HistoricalPatternMatchCard(
                lottery: lottery,
                targetDraw: targetDraw,
                allDraws: mockDraws,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for Chinese comparison labels
      final labelFinder = find.textContaining('比较');
      expect(labelFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('Component score labels are localized in Chinese', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HistoricalPatternMatchCard(
                lottery: lottery,
                targetDraw: targetDraw,
                allDraws: mockDraws,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for Chinese component labels
      expect(find.text('趋势比较'), findsOneWidget);
      expect(find.text('常见/低频比较'), findsOneWidget);
      expect(find.text('奇偶结构'), findsOneWidget);
      expect(find.text('低高结构'), findsOneWidget);
      expect(find.text('和值范围'), findsOneWidget);
      expect(find.text('连续对'), findsOneWidget);
    });
  });
}
