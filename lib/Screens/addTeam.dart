import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class addTeam extends StatelessWidget {
  const addTeam({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {

    CollectionReference users = FirebaseFirestore.instance.collection('user');
    CollectionReference teams = FirebaseFirestore.instance.collection('teams');

    Future<void> addTeam() async {
      return users
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
      body: Center(
          child: const Text('Erstelle ein neues Team!')
      ),
    ));
  }
}