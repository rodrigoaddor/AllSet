import 'package:AllSet/page/home.dart';
import 'package:AllSet/page/qr.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> router = {
  '/': (context) => HomePage(),
  '/qr': (context) => QRPage(),
};