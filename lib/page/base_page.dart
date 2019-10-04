import 'package:allset/page/charging.dart';
import 'package:allset/page/stations.dart';
import 'package:flutter/material.dart';

import 'package:allset/widget/app_drawer.dart';
import 'package:allset/data/app_notifier.dart';

import 'package:after_layout/after_layout.dart';
import 'package:provider/provider.dart';

enum AppPage { CHARGING, STATIONS }

class BasePage extends StatefulWidget {
  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> with SingleTickerProviderStateMixin, AfterLayoutMixin {
  TabController tabController;
  AppPage currentPage = AppPage.CHARGING;
  Function removeListener;

  @override
  void afterFirstLayout(BuildContext context) {
    final appNotifier = Provider.of<AppNotifier>(context);

    void listenForNotification() {
      if (appNotifier.handler != null) appNotifier.handler(context);
    }

    if (appNotifier.handler != null) appNotifier.handler(context);

    appNotifier.addListener(listenForNotification);
    removeListener = () => appNotifier.removeListener(listenForNotification);
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: this.currentPage.index,
      length: AppPage.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    if (removeListener != null) removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'ALLSET',
            style: TextStyle(
              fontFamily: 'Tesla',
            ),
          ),
        ),
      ),
      drawer: AppDrawer(
          currentPage: this.currentPage,
          changePage: (appPage) {
            tabController.animateTo(appPage.index);
            setState(() => currentPage = appPage);
          }),
      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ChargingPage(),
          StationsPage(),
        ],
      ),
    );
  }
}
