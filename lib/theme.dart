import 'package:flutter/material.dart';

ThemeData buildTheme() => ThemeData.dark().copyWith(
  backgroundColor: Colors.lightBlueAccent,
  textTheme: Typography.whiteMountainView.copyWith(
    title: TextStyle(fontFamily: 'OpenSans'),
  ),
);

ThemeData buildHomeTheme() =>
    ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.grey[900],
      accentColor: Colors.blue,
      primaryColor: Colors.grey[900],
      primaryTextTheme: TextTheme(
        title: TextStyle(fontFamily: 'OpenSans'),
      ),
    );

ThemeData buildQRTheme() =>
    ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.grey[900],
    );
