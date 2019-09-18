import 'package:allset/page/home.dart';
import 'package:allset/theme.dart';
import 'package:allset/utils/notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final Firestore db = Firestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseMessaging msg = FirebaseMessaging();

final Notifier askConfirmation = Notifier();

void main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Colors.grey[900],
    ),
  );

  msg.requestNotificationPermissions();
  msg.configure(
    onMessage: (Map<String, dynamic> message) async {
      askConfirmation.notifyListeners(); 
    },
    onLaunch: (Map<String, dynamic> message) async {
      askConfirmation.notifyListeners();
    },
    onResume: (Map<String, dynamic> message) async {
      askConfirmation.notifyListeners();
    },
  );

  final authResult = await auth.signInAnonymously();
  db.document('/users/${authResult.user.uid}').setData({'token': await msg.getToken()}, merge: true);

  runApp(AllsetApp(askConfirmation));
}

class AllsetApp extends StatelessWidget {
  final Notifier askConfirmation;

  AllsetApp(this.askConfirmation);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AllSet App',
        theme: buildTheme(),
        home: HomePage(this.askConfirmation),
        debugShowCheckedModeBanner: false,
      );
}
