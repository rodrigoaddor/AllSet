import 'package:allset/data/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatefulWidget {
  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<ThemeState>(context);

    return Theme(
      data: themeState.themeMode == ThemeMode.dark ? ThemeData.dark() : ThemeData.light(),
      child: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(190),
              ),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'AllSet',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
            SwitchListTile(
              title: Text('Tema Escuro'),
              value: themeState.themeMode == ThemeMode.dark,
              onChanged: (enabled) => {themeState.themeMode = enabled ? ThemeMode.dark : ThemeMode.light},
            )
          ],
        ),
      ),
    );
  }
}
