import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tasks extends StatelessWidget {
  const Tasks({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference tasks = firestore.collection('tasks');

    Future<void> addTask() {
      return tasks
          .add({
            'title': 'Aufgabe 1',
            'description': 'Beschreibung 1',
            'xp': 500
      })
          .then((value) => print("Task added"))
          .catchError((error) => print("Failed to add task: $error"));
    }

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
      body: Center(child: TextButton(
        onPressed: addTask,
        child: new Text('Click me'),
      ),)
    ));
  }
}