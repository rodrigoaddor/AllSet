import 'package:allset/data/app_state.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<ThemeState>(context);

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
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
          SwitchListTile(
            title: Text('Tema Escuro'),
            secondary: Icon(FontAwesomeIcons.adjust),
            value: themeState.themeMode == ThemeMode.dark,
            onChanged: (enabled) => {themeState.themeMode = enabled ? ThemeMode.dark : ThemeMode.light},
          )
        ],
      ),
    );
  }
}
