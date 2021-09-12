import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/drawer.dart';

class Tasks extends StatelessWidget {
  const Tasks({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    CollectionReference tasks = FirebaseFirestore.instance.collection('tasks');

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
      body: StreamBuilder<QuerySnapshot>(
        stream: tasks.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(!snapshot.hasData) return new Text("Es gibt aktuell keine Aufgaben.");
          return new ListView(
            children: getTasks(snapshot),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/task-create');
        },
        child: const Icon(Icons.add_circle),
        backgroundColor: Colors.deepOrange,
      ),
    ));
  }

  getTasks(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs
        .map((doc) => Card(child: ListTile(title: new Text(doc['title']), subtitle: new Text(doc['description']), trailing: Icon(Icons.arrow_forward_ios_rounded),)))
        .toList();
  }
}