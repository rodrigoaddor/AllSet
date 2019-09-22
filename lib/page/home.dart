import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:allset/data/app_state.dart';
import 'package:allset/page/charging.dart';
import 'package:allset/page/payment.dart';
import 'package:allset/page/stations.dart';
import 'package:allset/utils/page_item.dart';
import 'package:allset/widget/confirm_dialog.dart';
import 'package:allset/widget/home_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';

Firestore db = Firestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AfterLayoutMixin {
  TabController tabController;
  int currentIndex = 0;
  Function listenToConfirmation;
  bool hasConnectivity;
  StreamSubscription connectivitySubscription;

  @override
  void afterFirstLayout(BuildContext context) {
    listenToConfirmation = () async {
      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ConfirmDialog(),
      );

      final uid = (await auth.currentUser()).uid;

      if (confirm) {
        db.document('/users/$uid').setData(
          {"isCharging": true},
          merge: true,
        );
      }
    };

    Provider.of<AskConfirmation>(context).addListener(listenToConfirmation);
    
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        hasConnectivity = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: this.currentIndex,
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    Provider.of<AskConfirmation>(context).removeListener(this.listenToConfirmation);
    tabController.dispose();
    connectivitySubscription.cancel();
    super.dispose();
  }

  final pages = <PageItem>[
    PageItem(
      name: 'Estações',
      icon: FontAwesomeIcons.chargingStation,
      page: StationsPage(),
    ),
    PageItem(
      name: 'Seu Carro',
      icon: FontAwesomeIcons.car,
      page: ChargingPage(),
    ),
    PageItem(name: 'Pagamento', icon: FontAwesomeIcons.dollarSign, page: PaymentPage())
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'AllSet',
            ),
          ),
          drawer: HomeDrawer(),
          body: Center(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: this.hasConnectivity == null
                  ? CircularProgressIndicator()
                  : this.hasConnectivity == false
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 64,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  'Sem conexão a internet',
                                  style: Theme.of(context).textTheme.headline,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Icon(
                                Icons.signal_wifi_off,
                                size: 128,
                              ),
                            ),
                            SizedBox(
                              height: 64,
                              child: Text(
                                'Por favor, verifique se está\nconectado a internet.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.body1,
                              ),
                            )
                          ],
                        )
                      : TabBarView(
                          controller: tabController,
                          children: pages.map((page) => page.page).toList(),
                          physics: NeverScrollableScrollPhysics(),
                        ),
            ),
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
      ],
    );
  }
}
