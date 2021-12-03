import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/globalMethods/achievementHub.dart';
import 'package:master_projekt/globalMethods/calculateLevel.dart';
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
  // initialize needed variables
  List<ListTileModel> _items = [];
  final FirebaseAuth auth = FirebaseAuth.instance;

  // get id of current logged in user
  String getUid() {
    final User? user = auth.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  // add subtasks to list
  void _add(String input) {
    _items.add(ListTileModel(false, input));
    setState(() {});
  }
  void initState() {
    for (int i = 0; i < widget.subTasks.length; i++) {
      _add(widget.subTasks[i]);
    }
  }

  // get all subtasks
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
                          // task title
                          Text(widget.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24)),
                          Padding(padding: EdgeInsets.all(10)),
                          // task description
                          Text(widget.description,
                              style: TextStyle(fontSize: 18)),
                          // Subtasks
                          getSubtasks(),
                          // task xp
                          Text('XP: ' + widget.xp.toString()),
                          Padding(padding: EdgeInsets.all(10)),
                          // upload time and date
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
                  // Buttons depending on finished/accepted status
                  // no button if finished by user
                  if (widget.finished && widget.userId == getUid())
                    SizedBox()
                    // finish and cancel buttons if accepted by user
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
                    // accept button if not finished or accepted
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

  // delete task from database
  void deleteTask() {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.id)
        .delete();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  // set task as accepted in database
  void acceptTask(String id) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(id)
        .update({'accepted': true, 'user': getUid()});
    Navigator.of(context).pop();
  }

  // set task as finished in database and check if user has levelup
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

    // check for levelup
    final CalculateLevel logic = new CalculateLevel();
    logic.levelUp(user);

    // update user in database
    user.update({'finishedTasksCount': FieldValue.increment(1)});
    user.update({'xp': FieldValue.increment(taskXp)});


    final AchievementHub logic2 = new AchievementHub();
    logic2.checkAchievement(user);

    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, 'tasks');
  }

  // set task as not accepted in database
  void cancelTask(String id) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(id)
        .update({'accepted': false, 'user': ''});
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, 'tasks');
  }
}
