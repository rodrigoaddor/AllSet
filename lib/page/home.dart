import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:allset/data/payment_data.dart';
import 'package:allset/page/charging.dart';
import 'package:allset/theme.dart';
import 'package:allset/utils/page_item.dart';
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

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage>, SingleTickerProviderStateMixin {
  TabController tabController;
  int currentIndex = 1;

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
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: this.currentIndex,
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    authStateSubscription?.cancel();
    super.dispose();
  }

  void updatePayment() async {
    final payment = await Navigator.pushNamed(context, '/payment') as PaymentData;
    db.collection('users').document(currentUser.uid).updateData({'payment': payment.toJson()});
  }

  final pages = <PageItem>[
    PageItem(
      name: 'Stations',
      icon: FontAwesomeIcons.chargingStation,
      page: Container(color: Colors.blue),
    ),
    PageItem(
      name: 'Your Car',
      icon: FontAwesomeIcons.car,
      page: ChargingPage(),
    ),
  ];

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
          actions: [
            IconButton(
              onPressed: updatePayment,
              tooltip: 'Payment',
              icon: Icon(FontAwesomeIcons.dollarSign),
            ),
          ],
        ),
        body: TabBarView(
          controller: tabController,
          children: pages.map((page) => page.page).toList(),
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: this.currentIndex,
          items: this.pages.map((item) => item.navItem).toList(),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            tabController.animateTo(index);
            setState(() {
              this.currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
