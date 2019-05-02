import 'package:allset/router.dart';
import 'package:allset/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AllSet App',
    theme: buildTheme(),
        routes: router,
      );
}
