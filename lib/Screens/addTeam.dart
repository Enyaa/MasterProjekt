import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class addTeam extends StatefulWidget {
  const addTeam({Key? key}) : super(key: key);

  @override
  _addTeamState createState() => _addTeamState();
}

class _addTeamState extends State<addTeam> {
  @override
  Widget build (BuildContext context) {

    var snapshots = FirebaseFirestore.instance.collection('user').snapshots();
    final nameController = TextEditingController();

    CollectionReference teams = FirebaseFirestore.instance.collection('teams');

    Future<void> addTeam() async {
      return teams
          .add({
      })
          .then((value) => print("Team Added"))
          .catchError((error) => print("Failed to add team"));
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
      appBar: AppBar(
          title: const Text('Team erstellen'),
          automaticallyImplyLeading: true,
          leading: IconButton(icon: Icon(Icons.arrow_back),
          onPressed:() =>  Navigator.pushReplacementNamed(context, '/teams')
            ,)
      ),
      body: Form(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name *'),
                    controller: nameController,
                    validator: validateName,
                  ),
                  Text('User hinzufügen',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        leadingDistribution: TextLeadingDistribution.even, height: 5.0),
                  ),
                  StreamBuilder(
                    stream: snapshots,
                    builder:
                        (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData)
                        return new Text("Du kennst leider keine User");
                      return new ListView(
                        children: getUsers(snapshot, context),
                      );
                    }
                  )
                ],
              )
            )
          ),
      ),
    ));
  }
}

String? validateName(String? formName) {
  if (formName == null || formName.isEmpty)
    return 'Bitte gib einen Namen ein.';

  if (formName.length < 2)
    return 'Das Name muss mind. 2 Zeichen haben';

  return null;
}

getUsers(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
  return snapshot.data!.docs
      .map((doc) => Card(
      child: ListTile(
          title: new Text(doc['name']),
          subtitle: new Text(doc['level'].toString()),
          trailing: Icon(Icons.add),
          )))
      .toList();
}

