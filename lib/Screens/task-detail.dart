import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskDetail extends StatelessWidget {

  const TaskDetail({Key? key, required this.title, required this.description, required this.xp, required this.time, required this.id}) : super(key: key);

  final String title;
  final String description;
  final int xp;
  final String time;
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
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Padding(padding: EdgeInsets.all(10)),
            Text(description),
            Padding(padding: EdgeInsets.all(10)),
            Text('XP: ' + xp.toString()),
            Padding(padding: EdgeInsets.all(10)),
            Text(time)
          ],
        )
      )
    ));
  }
}