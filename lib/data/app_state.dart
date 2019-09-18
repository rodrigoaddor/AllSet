import 'package:flutter/material.dart';

class ThemeState with ChangeNotifier {
  ThemeState({ThemeMode initialTheme}) {
    _themeMode = initialTheme;
  }

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class AskConfirmation with ChangeNotifier {
  AskConfirmation();

  void ask() {
    notifyListeners();
  }
} 