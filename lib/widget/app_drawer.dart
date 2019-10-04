import 'package:allset/widget/plate_dialog.dart';
import 'package:flutter/material.dart';

import 'package:allset/data/app_state.dart';
import 'package:allset/page/base_page.dart';
import 'package:allset/widget/payment_dialog.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  final AppPage currentPage;
  final Function(AppPage) changePage;

  AppDrawer({
    @required this.currentPage,
    @required this.changePage,
  });

  @override
  Widget build(BuildContext context) {
    Widget generateDrawerTile(String title, IconData icon, AppPage page) {
      return ListTile(
        title: Text(title),
        leading: Icon(icon),
        selected: currentPage == page,
        onTap: () {
          Navigator.pop(context);
          this.changePage(page);
        },
      );
    }

    final themeState = Provider.of<ThemeState>(context);

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ALLSET',
                  style: TextStyle(
                    fontFamily: 'Tesla',
                    fontSize: 32,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          generateDrawerTile('Carregamento', FontAwesomeIcons.bolt, AppPage.CHARGING),
          generateDrawerTile('Mapa de Estações', FontAwesomeIcons.mapMarkedAlt, AppPage.STATIONS),
          Divider(),
          ListTile(
            title: const Text('Pagamento'),
            leading: const Icon(FontAwesomeIcons.dollarSign),
            onTap: () {
              showDialog(context: context, builder: (context) => PaymentDialog());
            },
          ),
          ListTile(
            title: const Text('Placa'),
              leading: Icon(FontAwesomeIcons.car),
            onTap: () {
              showDialog(context: context, builder: (context) => PlateDialog());
            },
          ),
          SwitchListTile(
            title: const Text('Tema Escuro'),
            secondary: const Icon(FontAwesomeIcons.adjust),
            value: themeState.themeMode == ThemeMode.dark,
            onChanged: (enabled) => {themeState.themeMode = enabled ? ThemeMode.dark : ThemeMode.light},
          )
        ],
      ),
    );
  }
}
