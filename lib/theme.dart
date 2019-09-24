import 'package:flutter/material.dart';

ThemeData buildLightTheme() => ThemeData(
      brightness: Brightness.light,
      fontFamily: 'OpenSans',
      primaryColor: Colors.red,
      appBarTheme: AppBarTheme(color: Colors.red[700]),
    );

ThemeData buildDarkTheme() => ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'OpenSans',
      primaryColor: Colors.red,
      appBarTheme: AppBarTheme(color: Colors.black),
      buttonColor: Colors.red[800],
      accentColor: Colors.red[800],
      indicatorColor: Colors.red,
      toggleableActiveColor: Colors.red,
      dividerColor: Colors.red,
      cursorColor: Colors.red,
      textSelectionHandleColor: Colors.red,
    );
