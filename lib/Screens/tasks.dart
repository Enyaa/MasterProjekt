import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/drawer.dart';

class Tasks extends StatelessWidget {
  const Tasks({Key? key}) : super(key: key);

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
    },child: Scaffold(
      appBar: AppBar(title: const Text('Aufgaben')),
      drawer: MyDrawer(),
      body: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/task-create');
        },
        child: Text('Neue Aufgabe erstellen'),
      )
    ));
  }
}