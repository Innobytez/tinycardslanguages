import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;

  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Colors.white,
      onPrimary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: Colors.black,
      onPrimary: Colors.white,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
  );

  final String key = "theme";
  SharedPreferences? _prefs;

  ThemeChanger() : _themeData = lightTheme {
    _loadFromPrefs();
  }

  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _themeData = (_prefs!.getBool(key) ?? false) ? darkTheme : lightTheme;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _prefs!.setBool(key, _themeData == darkTheme);
  }

  getTheme() => _themeData;
  setTheme(ThemeData theme) {
    _themeData = theme;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleDarkMode(bool isOn) {
    if (isOn) {
      _themeData = darkTheme;
    } else {
      _themeData = lightTheme;
    }
    _saveToPrefs();
    notifyListeners();
  }

  bool get isDarkModeOn => _themeData == darkTheme;
}