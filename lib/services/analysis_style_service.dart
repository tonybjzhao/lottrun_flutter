import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/analysis_style.dart';

/// Service for managing the user's selected analysis style preference.
///
/// The analysis style determines how historical lottery data is weighted
/// when calculating hot/cold numbers, match scores, and trends.
class AnalysisStyleService extends ChangeNotifier {
  AnalysisStyleService._();

  static final instance = AnalysisStyleService._();

  static const _prefKey = 'analysis_style';

  AnalysisStyle _style = AnalysisStyle.balanced;

  /// Returns the currently selected analysis style
  AnalysisStyle get style => _style;

  /// Returns the weight configuration for the current analysis style
  Map<String, double> get weights => _style.weights;

  /// Loads the saved analysis style from preferences.
  ///
  /// Should be called during app initialization.
  /// Defaults to [AnalysisStyle.balanced] if no preference is saved.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final styleId = prefs.getString(_prefKey);

    if (styleId != null) {
      _style = AnalysisStyleWeights.fromId(styleId);
    } else {
      _style = AnalysisStyle.balanced; // Default
    }
  }

  /// Sets the analysis style and persists the preference.
  ///
  /// Notifies listeners after the style is updated.
  Future<void> setStyle(AnalysisStyle style) async {
    if (_style == style) return;

    _style = style;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, style.id);

    notifyListeners();
  }
}
