import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState with ChangeNotifier {
  ThemeState({ThemeMode themeMode}) {
    _themeMode = themeMode;
  }

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('darkMode', mode == ThemeMode.dark);
    });
  }
}

class UserState with ChangeNotifier {
  UserState({String userID}) {
    _userID = userID;
  }

  String _userID;
  String get userID => _userID ?? '';
  set userID(String id) {
    _userID = id;
    notifyListeners();
  }
}