import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  LocaleService._();

  static final instance = LocaleService._();

  static const _prefKey = 'selected_locale';
  static const supportedLanguageCodes = ['en', 'zh', 'fr', 'es', 'de', 'ja'];

  Locale? _locale;

  Locale? get locale => _locale;

  String get languageCode => _locale?.languageCode ?? 'en';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null && supportedLanguageCodes.contains(code)) {
      _locale = Locale(code);
    }
  }

  Future<void> setLanguageCode(String code) async {
    if (!supportedLanguageCodes.contains(code)) return;
    if (_locale?.languageCode == code) return;

    _locale = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
    notifyListeners();
  }
}
