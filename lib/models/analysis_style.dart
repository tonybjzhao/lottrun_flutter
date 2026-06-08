/// Represents different analysis styles with preset historical weight configurations.
///
/// Each style defines how much weight to give to different time periods
/// when analyzing historical lottery data. This affects hot/cold number
/// calculations, historical match scores, and trend analysis.
///
/// Note: These weights only change how historical trends are weighted.
/// They do not improve the odds of winning.
enum AnalysisStyle {
  /// Recent Trend - Emphasizes recent patterns
  ///
  /// - 0-12 weeks: 70%
  /// - 13-52 weeks: 20%
  /// - 1-5 years: 10%
  recentTrend,

  /// Balanced - Equal consideration across time periods
  ///
  /// - 0-12 weeks: 50%
  /// - 13-52 weeks: 30%
  /// - 1-5 years: 20%
  balanced,

  /// Long-Term Pattern - Emphasizes historical patterns
  ///
  /// - 0-12 weeks: 30%
  /// - 13-52 weeks: 30%
  /// - 1-5 years: 40%
  longTermPattern,
}

/// Extension to provide weight configurations for each analysis style
extension AnalysisStyleWeights on AnalysisStyle {
  /// Returns the weight configuration for this analysis style.
  ///
  /// Returns a map with three keys:
  /// - 'recent' (0-12 weeks)
  /// - 'medium' (13-52 weeks)
  /// - 'longTerm' (1-5 years)
  ///
  /// All weights sum to 1.0 (100%).
  Map<String, double> get weights {
    switch (this) {
      case AnalysisStyle.recentTrend:
        return {
          'recent': 0.70,
          'medium': 0.20,
          'longTerm': 0.10,
        };
      case AnalysisStyle.balanced:
        return {
          'recent': 0.50,
          'medium': 0.30,
          'longTerm': 0.20,
        };
      case AnalysisStyle.longTermPattern:
        return {
          'recent': 0.30,
          'medium': 0.30,
          'longTerm': 0.40,
        };
    }
  }

  /// Returns a string identifier for persisting this style
  String get id {
    switch (this) {
      case AnalysisStyle.recentTrend:
        return 'recent_trend';
      case AnalysisStyle.balanced:
        return 'balanced';
      case AnalysisStyle.longTermPattern:
        return 'long_term_pattern';
    }
  }

  /// Creates an AnalysisStyle from a persisted string identifier
  static AnalysisStyle fromId(String id) {
    switch (id) {
      case 'recent_trend':
        return AnalysisStyle.recentTrend;
      case 'balanced':
        return AnalysisStyle.balanced;
      case 'long_term_pattern':
        return AnalysisStyle.longTermPattern;
      default:
        return AnalysisStyle.balanced; // Default fallback
    }
  }
}
