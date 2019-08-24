import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:allset/data/payment_data.dart';
import 'package:allset/data/user_data.dart';
import 'package:allset/page/charging.dart';
import 'package:allset/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Firestore db = Firestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage> {
  Function(FirebaseUser) watchAuthState;
  StreamSubscription<FirebaseUser> authStateSubscription;
  FirebaseUser currentUser;

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
  void dispose() {
    authStateSubscription?.cancel();
    super.dispose();
  }

  void updatePayment(UserData userData) async {
    final payment = await Navigator.pushNamed(context, '/payment', arguments: userData.payment ?? null) as PaymentData;
    db.collection('users').document(currentUser.uid).updateData({'payment': payment.toJson()});
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
            bottomNavigationBar: BottomAppBar(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center ,
                    children: [
                      Icon(FontAwesomeIcons.bolt),
                      Text('Charging'),
                    ],
                  )
                ],
              ),
            ),
            body: Center(
              child: !snapshot.hasData ? CircularProgressIndicator() : ChargingPage(userData),
            ),
          );
        },
      ),
    );
  }
}
