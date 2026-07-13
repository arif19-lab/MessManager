import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isImmersiveMode = true;

  bool get isDarkMode => _isDarkMode;
  bool get isImmersiveMode => _isImmersiveMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  void setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', value);
    }
  }

  void setImmersiveMode(bool value) async {
    if (_isImmersiveMode != value) {
      _isImmersiveMode = value;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isImmersiveMode', value);
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isImmersiveMode = prefs.getBool('isImmersiveMode') ?? true;
    notifyListeners();
  }

  /// Returns light or dark color based on current theme.
  Color resolveColor({
    required Color light,
    required Color dark,
  }) {
    return _isDarkMode ? dark : light;
  }
}
