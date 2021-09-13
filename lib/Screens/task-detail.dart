import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskDetail extends StatelessWidget {

  const TaskDetail({Key? key, required this.title, required this.description, required this.xp, required this.id}) : super(key: key);

  final String title;
  final String description;
  final int xp;
  final String id;

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
      appBar: AppBar(title: const Text('Aufgaben')
          ,leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
            Navigator.pop(context);
          })),
      body: Text('Title: ' + title + ' Description: ' + description + ' xp: ' + xp.toString() + ' id: ' + id)
    ));
  }
}