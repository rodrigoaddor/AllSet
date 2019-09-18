import 'package:after_layout/after_layout.dart';
import 'package:allset/page/charging.dart';
import 'package:allset/page/payment.dart';
import 'package:allset/page/stations.dart';
import 'package:allset/theme.dart';
import 'package:allset/utils/notifier.dart';
import 'package:allset/utils/page_item.dart';
import 'package:allset/widget/confirm_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Firestore db = Firestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  final Notifier askConfirmation;

  HomePage(this.askConfirmation);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AfterLayoutMixin {
  TabController tabController;
  int currentIndex = 0;
  Function listenToConfirmation;

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

    widget.askConfirmation.addListener(listenToConfirmation);
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
    widget.askConfirmation.removeListener(this.listenToConfirmation);
    tabController.dispose();
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
    return Theme(
      data: buildHomeTheme(),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: Text(
                'AllSet',
              ),
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
        ],
      ),
    );
  }
}
