import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartupSoundChanger extends ChangeNotifier {
  bool _isStartupSoundOn = true; // Set your default value here

  StartupSoundChanger() {
    loadStartupSoundPreference();
  }

  bool get isStartupSoundOn => _isStartupSoundOn;

  void toggleStartupSound(bool value) async {
    _isStartupSoundOn = value;
    notifyListeners();
    await _saveStartupSoundPreference();
  }

  Future<void> loadStartupSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isStartupSoundOn = prefs.getBool('isStartupSoundOn') ?? true;
    notifyListeners(); // Notify listeners after loading preference
  }

  Future<void> _saveStartupSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isStartupSoundOn', _isStartupSoundOn);
  }
}

