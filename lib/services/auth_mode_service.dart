import 'package:shared_preferences/shared_preferences.dart';

class AuthModeService {
  static const _keyAuthMode = 'auth_mode';
  static const _keyIsLoggedIn = 'isLoggedIn';

  static Future<String> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthMode) ?? 'offline';
  }

  static Future<void> setMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthMode, mode);
  }

  static Future<bool> isOnline() async {
    return await getMode() == 'google';
  }

  static Future<bool> isOffline() async {
    return await getMode() != 'google';
  }

  static Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> setIsLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  static Future<void> setOffline() async {
    await setMode('offline');
    await setIsLoggedIn(true);
  }

  static Future<void> setGoogle() async {
    await setMode('google');
    await setIsLoggedIn(true);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.setString(_keyAuthMode, 'offline');
  }
}

