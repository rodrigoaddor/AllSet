import 'package:allset/data/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

Firestore db = Firestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class ChargingPage extends StatefulWidget {
  @override
  _ChargingPageState createState() => _ChargingPageState();
}

class _ChargingPageState extends State<ChargingPage> with SingleTickerProviderStateMixin<ChargingPage> {
  AnimationController fadeController;
  Animation fadeAnimation;

  @override
  void initState() {
    super.initState();
    fadeController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    fadeAnimation = Tween(begin: 0.2, end: 0.7).chain(CurveTween(curve: Curves.easeInOut)).animate(fadeController);
    fadeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    fadeController.dispose();
    super.dispose();
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

  Widget buildChargeIndicator(UserData userData) {
    return CircularPercentIndicator(
      percent: userData.percent,
      progressColor: Colors.red[400],
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.1),
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
                color: Color.fromRGBO(0, 0, 0, 0.1),
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<FirebaseUser>(
        future: auth.currentUser(),
        builder: (context, snapshot) {
          return !snapshot.hasData ? CircularProgressIndicator() : StreamBuilder<DocumentSnapshot>(
            stream: db.document('/users/${snapshot.data.uid}').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              final userData = UserData.fromJson(snapshot.data.data);
              return userData.hasVehicle ? buildChargeIndicator(userData) : buildIdle();
            },
          );
        },
      ),
    );
  }
}
