import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:allset/data/userData.dart';
import 'package:allset/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

Firestore firestore = Firestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage>, SingleTickerProviderStateMixin<HomePage> {
  FirebaseUser currentUser;
  UserData userData;

  Function(FirebaseUser) watchAuthState;
  Function(DocumentSnapshot) watchDataState;

  StreamSubscription<FirebaseUser> authStateSubscription;
  StreamSubscription<DocumentSnapshot> watchDataSubscription;

  @override
  void afterFirstLayout(BuildContext context) async {
    watchAuthState = (user) async {
      if (user == null) {
        Navigator.pushNamed(context, '/qr');
      } else {
        watchDataSubscription?.cancel();
        watchDataSubscription = firestore.collection('/users').document(user.uid).snapshots().listen(watchDataState);
        setState(() => currentUser = user);
      }
    };

    watchDataState = (snapshot) async {
      if (!snapshot.exists) {
        await Navigator.pushNamed(context, '/qr');
      } else {
        setState(() => userData = UserData.fromMap(snapshot.data));
      }
    };

    auth.onAuthStateChanged.listen(watchAuthState);
  }

  @override
  void dispose() {
    authStateSubscription?.cancel();
    watchDataSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildHomeTheme(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            'AllSet',
          ),
        ),
        body: Center(
          child: this.currentUser == null || this.userData == null
              ? CircularProgressIndicator()
              : CircularPercentIndicator(
              percent: this.userData.percent,
              center: Stack(
                  alignment: Alignment.center,
                  children: [
                  if (this.userData.charging) ...[
          Padding(
          padding: EdgeInsets.only(top: 8, left: 10),
          child: Icon(
            FontAwesomeIcons.bolt,
            size: 190,
            color: Color.fromRGBO(255, 255, 255, 0.06),
          ),
        ),
        ],
      Text(
      this.userData.hPercent,
      style: TextStyle(
        fontSize: 36,
      ),
    ),
    ],
    ),
    backgroundColor: Color.fromRGBO(255, 255, 255, 0.06),
    circularStrokeCap: CircularStrokeCap.round,
    radius: 300,
    lineWidth: 16,
    animation: true,
    animationDuration: 300,
    animateFromLastPercent: true,
    ),
    ),
      ),
    );
  }
}
