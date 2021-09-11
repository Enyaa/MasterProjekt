import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/drawer.dart';

class TaskCreate extends StatelessWidget {
  const TaskCreate({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference tasks = firestore.collection('tasks');

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String? title;
    String? description;
    String? xp;

    Future<void> addTask(title, description, xp) {
      return tasks
          .add({
        'title': title,
        'description': description,
        'xp': xp
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
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                onFieldSubmitted: (String value) {title=value;},
                maxLength: 20,
                decoration: const InputDecoration(
                  hintText: 'Titel'
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Bitte geben Sie einen Titel an.';
                  }
                  return null;
                },
              ),
              TextFormField(
                onFieldSubmitted: (String value) {description=value;},
                decoration: const InputDecoration(
                    hintText: 'Beschreibung'
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Bitte geben Sie eine Beschreibung an.';
                  }
                  return null;
                },
              ),
              TextFormField(
                onFieldSubmitted: (String value) {xp=value;},
                decoration: const InputDecoration(
                    hintText: 'Punkte'
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Bitte geben Sie eine Punktzahl an.';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                  onPressed: () {
                    if(_formKey.currentState!.validate()) {
                      addTask(title, description, xp);
                    }
                  },
                  child: Text('Speichern')
              )
            ],
          ),
        )
    ));
  }
}