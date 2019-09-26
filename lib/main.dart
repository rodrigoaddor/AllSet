import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:allset/data/app_notifier.dart';
import 'package:allset/data/app_state.dart';
import 'package:allset/theme.dart';
import 'package:allset/router.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Firestore db = Firestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseMessaging msg = FirebaseMessaging();

ThemeState appTheme;

Future<ThemeState> getThemeState() async {
  final prefs = await SharedPreferences.getInstance();
  final darkMode = prefs.getBool('darkMode') ?? true;

  return appTheme = ThemeState(themeMode: darkMode ? ThemeMode.dark : ThemeMode.light);
}

void main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Colors.grey[900],
    ),
  );

  final appNotifier = AppNotifier();
  Future<void> processNotification(Map<String, dynamic> notification) async {
    print(notification);
    appNotifier.notification = AppNotification.START_CHARGE;
  }

  msg.requestNotificationPermissions();
  msg.configure(onMessage: processNotification, onLaunch: processNotification, onResume: processNotification);

  try {
    final currentUser = await auth.currentUser();
    final userID = currentUser != null
        ? currentUser.uid
        : await auth.signInAnonymously().then((authResult) => authResult.user.uid);
    db.document('/users/$userID').setData({'token': await msg.getToken()}, merge: true);
  } catch (e) {}

  final List<SingleChildCloneableWidget> providers = [
    ChangeNotifierProvider<AppNotifier>.value(value: appNotifier),
    ChangeNotifierProvider<ThemeState>.value(value: await getThemeState()),
  ];

  runApp(AllsetApp(providers: providers));
}

class AllsetApp extends StatelessWidget {
  final List<SingleChildCloneableWidget> providers;

  AllsetApp({this.providers});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: this.providers,
        child: Builder(
          builder: (context) => MaterialApp(
            title: 'AllSet App',
            routes: router,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: Provider.of<ThemeState>(context).themeMode,
            debugShowCheckedModeBanner: false,
          ),
        ),
      );
}
