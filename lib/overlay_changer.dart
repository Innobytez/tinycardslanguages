import 'package:flutter/foundation.dart';

class OverlayChanger with ChangeNotifier {
  bool _isVibrationOn = true;
  bool _isOverlayOn = true;

  bool get isVibrationOn => _isVibrationOn;
  bool get isOverlayOn => _isOverlayOn;

  void toggleVibration(bool value) {
    _isVibrationOn = value;
    notifyListeners();
  }

  void toggleOverlay(bool value) {
    _isOverlayOn = value;
    notifyListeners();
  }
}