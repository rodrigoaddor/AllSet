import 'package:allset/router.dart';
import 'package:allset/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseMessaging msg = FirebaseMessaging();

void main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Colors.grey[900],
    ),
  );

  msg.requestNotificationPermissions();
  msg.configure(onMessage: (Map<String, dynamic> message) async {
    print('onMessage $message');
  });

  final bool hasUser = await auth.currentUser() != null;

  runApp(AllsetApp(initialRoute: hasUser ? '/' : 'register'));
}

class AllsetApp extends StatelessWidget {
  final String initialRoute;

  AllsetApp({this.initialRoute = '/'});

  @override
  Widget build(BuildContext context) =>
      MaterialApp(title: 'AllSet App', theme: buildTheme(), routes: router, initialRoute: this.initialRoute);
}
