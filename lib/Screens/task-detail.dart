import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/level/calculateLevel.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';

class ListTileModel {
  bool checked;
  String text;

  ListTileModel(this.checked, this.text);
}

class TaskDetail extends StatefulWidget {
  const TaskDetail(
      {Key? key,
      required this.title,
      required this.description,
      required this.subTasks,
      required this.xp,
      required this.time,
      required this.id,
      required this.accepted,
      required this.finished,
      required this.userId})
      : super(key: key);

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
              .map((item) => ListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Text(item.text, style: TextStyle(fontSize: 16)),
                  leading: Transform.scale(
                    scale: 1.5,
                    child: Theme(
                        data:
                            ThemeData(unselectedWidgetColor: Color(0xffFB9C26)),
                        child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              shape: CircleBorder(),
                              checkColor: Colors.white,
                              activeColor: Color(0xffFB9C26),
                              onChanged: (checked) {
                                item.checked = checked!;
                                setState(() {});
                              },
                              value: item.checked,
                            ))),
                  )))
              .toList());
    } else {
      return Padding(padding: EdgeInsets.all(10));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyWillPopScope(
        text: 'Zur Aufgaben-Übersicht zurückkehren?',
        destination: '/tasks',
        child: Scaffold(
          appBar: MyAppbar(title: 'Aufgaben', leading: true, admin: true, doDelete: deleteTask, mode: 'task'),
          body: Container(
            width: double.infinity,
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24)),
                          Padding(padding: EdgeInsets.all(10)),
                          Text(widget.description,
                              style: TextStyle(fontSize: 18)),
                          getSubtasks(),
                          Text('XP: ' + widget.xp.toString()),
                          Padding(padding: EdgeInsets.all(10)),
                          Row(
                            children: [
                              Icon(Icons.access_time_outlined),
                              Text(' Hochgeladen am ',
                                  style: TextStyle(fontSize: 16)),
                              Text(widget.time, style: TextStyle(fontSize: 16))
                            ],
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                        ],
                      )),
                  if (widget.finished && widget.userId == getUid())
                    SizedBox()
                  else if (widget.accepted && widget.userId == getUid())
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 300,
                            height: 50,
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  // 10% of the width, so there are ten blinds.
                                  colors: <Color>[
                                    Color(0xffE53147),
                                    Color(0xffFB9C26)
                                  ],
                                  // red to yellow
                                  tileMode: TileMode
                                      .repeated, // repeats the gradient over the canvas
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    shadowColor: MaterialStateProperty.all(
                                        Colors.transparent)),
                                onPressed: () => finishTask(widget.id),
                                child: Text('Abschließen'))),
                        Padding(padding: EdgeInsets.all(10)),
                        Container(
                            height: 50,
                            width: 300,
                            child: OutlinedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    shadowColor: MaterialStateProperty.all(
                                        Colors.transparent)),
                                onPressed: () => cancelTask(widget.id),
                                child: Text('Abbrechen')))
                      ],
                    )
                  else if (!widget.accepted)
                    Container(
                        width: 300,
                        height: 50,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              // 10% of the width, so there are ten blinds.
                              colors: <Color>[
                                Color(0xffE53147),
                                Color(0xffFB9C26)
                              ],
                              // red to yellow
                              tileMode: TileMode
                                  .repeated, // repeats the gradient over the canvas
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.transparent)),
                            onPressed: () => acceptTask(widget.id),
                            child: Text('Annehmen')))
                ],
              )),
          bottomNavigationBar: NavigationBar(0),
        ));
  }

  void deleteTask() {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.id)
        .delete();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void acceptTask(String id) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(id)
        .update({'accepted': true, 'user': getUid()});
    Navigator.of(context).pop();
  }

  Future<void> finishTask(String id) async {
    var task = await FirebaseFirestore.instance
        .collection('tasks')
        .where('id', isEqualTo: id)
        .get();
    var taskXp = task.docs[0].data()['xp'];
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(id)
        .update({'finished': true});

    var user = FirebaseFirestore.instance
        .collection('user')
        .doc(getUid());

    final CalculateLevel logic = new CalculateLevel();
    logic.levelUp(user);

    user.update({'finishedTasksCount': FieldValue.increment(1)});
    user.update({'xp': FieldValue.increment(taskXp)});

    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, 'tasks');
  }

  void cancelTask(String id) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(id)
        .update({'accepted': false, 'user': ''});
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, 'tasks');
  }
}
