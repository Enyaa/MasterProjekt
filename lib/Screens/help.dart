import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';

class Help extends StatelessWidget {
  const Help({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return MyWillPopScope(
        text: 'Zur Homepage zurückkehren?',
        child: Scaffold(
        appBar: MyAppbar(title: 'Hilfe', actions: false, bottom: false, leading: false),
        drawer: MyDrawer(),
        body: Center(child: const Text('Hilfe')),
      bottomNavigationBar: NavigationBar(0),
    ));
  }
}