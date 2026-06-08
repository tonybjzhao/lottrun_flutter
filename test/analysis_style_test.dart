import 'package:flutter_test/flutter_test.dart';
import 'package:lottfun_flutter/models/analysis_style.dart';
import 'package:lottfun_flutter/services/analysis_style_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AnalysisStyle Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('Default style is balanced', () async {
      await AnalysisStyleService.instance.load();
      expect(
        AnalysisStyleService.instance.style,
        AnalysisStyle.balanced,
      );
    });

    test('Recent trend weights are correct', () {
      final weights = AnalysisStyle.recentTrend.weights;
      expect(weights['recent'], 0.70);
      expect(weights['medium'], 0.20);
      expect(weights['longTerm'], 0.10);
      expect(weights['recent']! + weights['medium']! + weights['longTerm']!,
          closeTo(1.0, 0.001));
    });

    test('Balanced weights are correct', () {
      final weights = AnalysisStyle.balanced.weights;
      expect(weights['recent'], 0.50);
      expect(weights['medium'], 0.30);
      expect(weights['longTerm'], 0.20);
      expect(weights['recent']! + weights['medium']! + weights['longTerm']!,
          closeTo(1.0, 0.001));
    });

    test('Long-term pattern weights are correct', () {
      final weights = AnalysisStyle.longTermPattern.weights;
      expect(weights['recent'], 0.30);
      expect(weights['medium'], 0.30);
      expect(weights['longTerm'], 0.40);
      expect(weights['recent']! + weights['medium']! + weights['longTerm']!,
          closeTo(1.0, 0.001));
    });

    test('Style ID conversion works', () {
      expect(AnalysisStyle.recentTrend.id, 'recent_trend');
      expect(AnalysisStyle.balanced.id, 'balanced');
      expect(AnalysisStyle.longTermPattern.id, 'long_term_pattern');

      expect(
        AnalysisStyleWeights.fromId('recent_trend'),
        AnalysisStyle.recentTrend,
      );
      expect(
        AnalysisStyleWeights.fromId('balanced'),
        AnalysisStyle.balanced,
      );
      expect(
        AnalysisStyleWeights.fromId('long_term_pattern'),
        AnalysisStyle.longTermPattern,
      );
    });

    test('Invalid ID defaults to balanced', () {
      expect(
        AnalysisStyleWeights.fromId('invalid'),
        AnalysisStyle.balanced,
      );
    });

    test('Style persists correctly', () async {
      await AnalysisStyleService.instance.load();

      // Set to recent trend
      await AnalysisStyleService.instance
          .setStyle(AnalysisStyle.recentTrend);
      expect(
        AnalysisStyleService.instance.style,
        AnalysisStyle.recentTrend,
      );

      // Simulate app restart by creating new instance and loading
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('analysis_style');
      expect(savedId, 'recent_trend');

      // Verify it loads correctly
      final loadedStyle = AnalysisStyleWeights.fromId(savedId!);
      expect(loadedStyle, AnalysisStyle.recentTrend);
    });

    test('All styles have three weight categories', () {
      for (final style in AnalysisStyle.values) {
        final weights = style.weights;
        expect(weights.containsKey('recent'), true);
        expect(weights.containsKey('medium'), true);
        expect(weights.containsKey('longTerm'), true);
        expect(weights.length, 3);
      }
    });

    test('All weight values are between 0 and 1', () {
      for (final style in AnalysisStyle.values) {
        final weights = style.weights;
        for (final weight in weights.values) {
          expect(weight, greaterThanOrEqualTo(0.0));
          expect(weight, lessThanOrEqualTo(1.0));
        }
      }
    });

    test('Service provides weights accessor', () {
      AnalysisStyleService.instance
          .setStyle(AnalysisStyle.longTermPattern);

      final weights = AnalysisStyleService.instance.weights;
      expect(weights['recent'], 0.30);
      expect(weights['medium'], 0.30);
      expect(weights['longTerm'], 0.40);
    });
  });
}
