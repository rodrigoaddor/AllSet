import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:allset/widget/confirm_dialog.dart';

final db = Firestore.instance;
final auth = FirebaseAuth.instance;

enum AppNotification { START_CHARGE }

Map<AppNotification, Function(BuildContext)> notificationHandler = {
  AppNotification.START_CHARGE: (BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmDialog(),
    );
    if (confirm) db.document('/users/${(await auth.currentUser()).uid}').setData({"isCharging": true}, merge: true);
  }
};

class AppNotifier with ChangeNotifier {
  AppNotification _notification;

  AppNotification get notification => _notification;
  set notification(AppNotification newNotification) {
    _notification = newNotification;
    notifyListeners();
  }

  Function(BuildContext) get handler => notificationHandler[_notification];
}
