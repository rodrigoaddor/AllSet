import 'package:allset/router.dart';
import 'package:allset/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseMessaging firebaseMsg = FirebaseMessaging();

void main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Colors.grey[900],
    ),
  );

  firebaseMsg.requestNotificationPermissions();
  firebaseMsg.configure(onMessage: (Map<String, dynamic> message) async {
    print('onMessage $message');
  });

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
