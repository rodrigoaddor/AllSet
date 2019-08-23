import 'package:allset/page/home.dart';
import 'package:allset/page/payment.dart';
import 'package:allset/page/register.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> router = {
  '/': (context) => HomePage(),
  '/register': (context) => RegisterPage(),
  '/payment': (context) => PaymentPage(),
};
