import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListTileModel {
  bool checked;
  String text;

  ListTileModel(this.checked, this.text);
}

class TaskDetail extends StatefulWidget {

  const TaskDetail({Key? key, required this.title, required this.description, required this.subTasks, required this.xp, required this.time,
    required this.id, required this.accepted, required this.finished, required this.userId}) : super(key: key);

  final String title;
  final String description;
  final subTasks;
  final int xp;
  final String time;
  final String id;
  final bool accepted;
  final bool finished;
  final String userId;

  @override
  _TaskDetailState createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {

  List<ListTileModel> _items = [];
  final FirebaseAuth auth = FirebaseAuth.instance;

  String getUid() {
    final User? user = auth.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  void _add(String input) {
    _items.add(ListTileModel(false, input));
    setState(() {});
  }

  void initState() {
    for (int i = 0; i < widget.subTasks.length; i++) {
      _add(widget.subTasks[i]);
    }
  }

  Widget getSubtasks() {
    if (widget.subTasks.length != 0) {
      return new ListView(
          shrinkWrap: true,
          children: _items
              .map((item) =>
              CheckboxListTile(title: Text(item.text),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: item.checked,
                  onChanged: (checked) {
                    item.checked = checked!;
                    setState(() {});
                  })).toList());
    } else {
      return Padding(padding: EdgeInsets.all(10));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          bool willLeave = false;
          // show the confirm dialog
          await showDialog(
              context: context,
              builder: (_) =>
                  AlertDialog(
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
        }, child: Scaffold(
        appBar: AppBar(title: const Text('Aufgaben')
            , leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
              Navigator.pop(context);
            })),
        body: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 24)),
                Padding(padding: EdgeInsets.all(10)),
                Text(widget.description),
                getSubtasks(),
                Text('XP: ' + widget.xp.toString()),
                Padding(padding: EdgeInsets.all(10)),
                Row(children: [
                  Icon(Icons.access_time_outlined),
                  Text(' Hochgeladen am '),
                  Text(widget.time)
                ],),
                Padding(padding: EdgeInsets.all(10)),
                if(widget.finished && widget.userId == getUid())
                  SizedBox()
                else if(widget.accepted && widget.userId == getUid())
                  Row(children: [
                    ElevatedButton(onPressed: () => finishTask(widget.id), child: Text('Abschließen')),
                    Padding(padding: EdgeInsets.all(10)),
                    ElevatedButton(onPressed: () => cancelTask(widget.id), child: Text('Abbrechen'))
                  ],)
                else if (!widget.accepted)
                  ElevatedButton(
                    onPressed: () => acceptTask(widget.id), child: Text('Annehmen'))
              ],
            )
        )
    ));
  }

  void acceptTask(String id) {
    FirebaseFirestore.instance.collection('tasks').doc(id).update({'accepted': true, 'user': getUid()});
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, 'tasks');
  }
  void finishTask(String id) {
    FirebaseFirestore.instance.collection('tasks').doc(id).update({'finished': true});
    FirebaseFirestore.instance.collection('user').doc(widget.userId).update({'finishedTasksCount': FieldValue.increment(1)});
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, 'tasks');
  }
  void cancelTask(String id) {
    FirebaseFirestore.instance.collection('tasks').doc(id).update({'accepted': false, 'user': ''});
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, 'tasks');
  }
}