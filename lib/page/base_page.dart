import 'package:flutter/material.dart';

import 'package:allset/widget/app_drawer.dart';
import 'package:allset/data/app_notifier.dart';

import 'package:after_layout/after_layout.dart';
import 'package:provider/provider.dart';

class BasePage extends StatefulWidget {
  final Widget child;
  final String route;

  BasePage({
    @required this.child,
    this.route,
  });

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> with AfterLayoutMixin {
  Function removeListener;

  @override
  void afterFirstLayout(BuildContext context) {
    final appNotifier = Provider.of<AppNotifier>(context);

    void listenForNotification() {
      if (appNotifier.handler != null) appNotifier.handler(context);
    }

    appNotifier.addListener(listenForNotification);
    removeListener = () => appNotifier.removeListener(listenForNotification);
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
        currentRoute: widget.route,
      ),
      body: Center(child: widget.child),
    );
  }
}
