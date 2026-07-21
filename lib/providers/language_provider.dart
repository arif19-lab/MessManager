import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  static const String _localeKey = 'app_locale';

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLocale();
  }

  bool get isBangla => _locale.languageCode == 'bn';

  void setLocale(Locale locale) async {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    }
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_localeKey) ?? 'en';
    if (langCode == 'bn') {
      _locale = const Locale('bn', 'BD');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
  }
}
