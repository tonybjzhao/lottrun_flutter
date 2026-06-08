// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/app.dart';
import 'package:lottfun_flutter/services/locale_service.dart';

void main() {
  testWidgets('App smoke test — LottFun renders home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(LottFunApp(localeService: LocaleService.instance));
    await tester.pumpAndSettle();
    expect(find.text('LottFun'), findsNothing); // RichText, not plain Text
    expect(find.text('Generate 1 Pick'), findsOneWidget);
  });
}
