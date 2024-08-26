import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  bool _isLight = true;
  bool get isLight {
    return _isLight;
  }

  set isLight(bool value) {
    _isLight = value;
    notifyListeners();
  }

  void toggle() {
    _isLight = !_isLight;
    notifyListeners();
  }
}
