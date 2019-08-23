import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:allset/data/payment_data.dart';
import 'package:allset/data/user_data.dart';
import 'package:allset/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

Firestore db = Firestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage>, SingleTickerProviderStateMixin<HomePage> {
  Function(FirebaseUser) watchAuthState;
  StreamSubscription<FirebaseUser> authStateSubscription;
  FirebaseUser currentUser;

  AnimationController fadeController;
  Animation fadeAnimation;

  @override
  void afterFirstLayout(BuildContext context) async {
    watchAuthState = (user) async {
      this.setState(() => currentUser = user);
      if (user == null) {
        authStateSubscription?.cancel();
        await Navigator.pushNamed(context, '/register');
        authStateSubscription = auth.onAuthStateChanged.listen(watchAuthState);
      }
    };

    authStateSubscription = auth.onAuthStateChanged.listen(watchAuthState);
  }

  @override
  void initState() {
    super.initState();
    fadeController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    fadeAnimation = Tween(begin: 0.2, end: 0.7).chain(CurveTween(curve: Curves.easeInOut)).animate(fadeController);
    fadeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    authStateSubscription?.cancel();
    super.dispose();
  }

  void updatePayment(UserData userData) async {
    final payment = await Navigator.pushNamed(context, '/payment', arguments: userData.payment ?? null) as PaymentData;

    db.collection('users').document(currentUser.uid).updateData({'payment': payment.toJson()});
  }

  Widget buildChargeIndicator(UserData userData) {
    return CircularPercentIndicator(
      percent: userData.percent,
      progressColor: Color.lerp(Colors.red[900], Colors.green[900], userData.percent),
      backgroundColor: Color.fromRGBO(255, 255, 255, 0.06),
      circularStrokeCap: CircularStrokeCap.round,
      radius: 300,
      lineWidth: 16,
      animation: true,
      animationDuration: 300,
      animateFromLastPercent: true,
      center: Stack(
        alignment: Alignment.center,
        children: [
          if (userData.charging) ...[
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
            userData.hPercent,
            style: TextStyle(
              fontSize: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIdle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No vehicle found!',
          style: TextStyle(fontSize: 30),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Icon(
              FontAwesomeIcons.chargingStation,
              size: 150,
              color: Colors.grey[800],
            ),
          ),
        ),
        Text(
          'Plug in your vehicle to start using Allset.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildHomeTheme(),
      child: StreamBuilder<DocumentSnapshot>(
        stream: this.currentUser != null
            ? db.collection('/users').document(this.currentUser.uid).snapshots()
            : Stream.empty(),
        builder: (context, snapshot) {
          UserData userData = UserData.fromJson(snapshot.data?.data ?? {});
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: Text(
                'AllSet',
              ),
              actions: [
                IconButton(
                  onPressed: !snapshot.hasData ? null : () => updatePayment(userData),
                  tooltip: 'Payment',
                  icon: Icon(FontAwesomeIcons.dollarSign),
                ),
              ],
            ),
            body: Center(
              child: !snapshot.hasData
                  ? CircularProgressIndicator()
                  : userData.hasVehicle ? buildChargeIndicator(userData) : buildIdle(),
            ),
          );
        },
      ),
    );
  }
}
