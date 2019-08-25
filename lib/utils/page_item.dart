import 'package:flutter/material.dart';

class PageItem {
  final String name;
  final IconData icon;
  final Widget page;

  const PageItem({
    @required this.name,
    @required this.icon,
    @required this.page,
  });

  BottomNavigationBarItem get navItem => BottomNavigationBarItem(
        title: Text(this.name),
        icon: Icon(this.icon),
      );
}
