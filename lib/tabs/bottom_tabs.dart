import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:master_projekt/Screens/challenges.dart';
import 'package:master_projekt/Screens/homepage.dart';
import 'package:master_projekt/Screens/leaderboards.dart';


class TabNavigationItem {
  final Widget page;
  final Widget title;
  final Icon icon;

  TabNavigationItem({required this.page, required this.title, required this.icon});

  static List<TabNavigationItem> get items => [
    TabNavigationItem(
      page: Homepage(),
      icon: Icon(Icons.home),
      title: Text("Home"),
    ),
    TabNavigationItem(
      page: Challenges(),
      icon: Icon(Icons.search),
      title: Text("Search"),
    ),
    TabNavigationItem(
      page: Leaderboards(),
      icon: Icon(Icons.home),
      title: Text("Home"),
    ),
  ];
}