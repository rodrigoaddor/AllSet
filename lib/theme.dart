import 'package:flutter/material.dart';

ThemeData buildTheme() => ThemeData.dark().copyWith(
      backgroundColor: Colors.lightBlueAccent,
      textTheme: Typography.whiteMountainView.copyWith(
        title: TextStyle(fontFamily: 'OpenSans'),
      ),
    );

ThemeData buildHomeTheme() => ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.white,
      accentColor: Colors.blue,
      primaryColor: Colors.grey[900],
      primaryTextTheme: TextTheme(
        title: TextStyle(fontFamily: 'OpenSans'),
      ),
    );

ThemeData buildRegisterTheme() => ThemeData.light().copyWith();

ThemeData buildPaymentTheme() => ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.grey[900],
      dividerColor: Colors.red[900],
      accentColor: Colors.redAccent[700],
      hintColor: Colors.red[700],
      cursorColor: Colors.redAccent[700]
    );
