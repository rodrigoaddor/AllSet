import 'package:flutter/material.dart';

import 'package:allset/page/stations.dart';
import 'package:allset/page/charging.dart';

final router = <String, WidgetBuilder>{
  '/': (context) => ChargingPage(),
  '/stations': (context) => StationsPage(),
};
