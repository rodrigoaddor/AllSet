import 'package:allset/page/home.dart';
import 'package:allset/page/payment.dart';
import 'package:allset/page/qr.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> router = {
  '/': (context) => HomePage(),
  '/qr': (context) => QRPage(),
  '/payment': (context) => PaymentPage(),
};