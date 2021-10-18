import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/drawer.dart';

class Leaderboards extends StatelessWidget {
  const Leaderboards({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
        bool willLeave = false;
        // show the confirm dialog
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
        title: Text('Go back to Homepage?'),
        actions: [
          ElevatedButton(
              onPressed: () {
                willLeave = false;
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Yes')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'))
        ],
      ));
    return willLeave;
    },child: DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(title: const Text('Bestenlisten'),
              bottom: const TabBar(tabs: [
                Tab(text: 'XP'),
                Tab(text: 'Aufgaben'),
                Tab(text: 'Herausforderungen')
              ])),
          drawer: MyDrawer(),
          body: const TabBarView(children: [
            Text('XP'),
            Text('Aufgaben'),
            Text('Herausforderungen')
          ])
      ),
    ));
  }
}