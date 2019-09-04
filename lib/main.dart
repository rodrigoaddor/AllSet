import 'package:allset/router.dart';
import 'package:allset/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final Firestore db = Firestore.instance;
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

  final authResult = await auth.signInAnonymously();
  db.document('/users/${authResult.user.uid}').setData({'token': await msg.getToken()}, merge: true);

  runApp(AllsetApp());
}

class AllsetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AllSet App',
        theme: buildTheme(),
        routes: router,
        debugShowCheckedModeBanner: false,
      );
}
