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
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final xpController = TextEditingController();

    Future<void> addTask(title, description, xp) {
      return tasks
          .add({
        'title': title,
        'description': description,
        'xp': int.parse(xp)
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
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              TextFormField(
                controller: titleController,
                maxLength: 20,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Titel',
                  labelText: 'Titel'
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Bitte geben Sie einen Titel an.';
                  }
                  return null;
                },
              ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
              TextFormField(
                controller: descriptionController,
                maxLines: 5,
                maxLength: 200,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Beschreibung',
                    labelText: 'Beschreibung'
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Bitte geben Sie eine Beschreibung an.';
                  }
                  return null;
                },
              ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
              TextFormField(
                controller: xpController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Punkte',
                    labelText: 'Punkte'
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Bitte geben Sie eine Punktzahl an.';
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              ElevatedButton(
                  onPressed: () {
                    if(_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      addTask(titleController.text, descriptionController.text, xpController.text);
                      Navigator.pushReplacementNamed(context, '/tasks');
                    }
                  },
                  child: Text('Speichern')
              )
            ],
          ),
        )
    )));
  }
}