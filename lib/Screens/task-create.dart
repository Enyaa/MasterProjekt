import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:master_projekt/GradientIcon.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:intl/intl.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:uuid/uuid.dart';

class TaskCreate extends StatefulWidget {
  const TaskCreate({Key? key}) : super(key: key);

  @override
  _TaskCreateState createState() => _TaskCreateState();
}

class _TaskCreateState extends State<TaskCreate> {
  List<dynamic> subTasks = [];

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference tasks = firestore.collection('tasks');
    var uid = Uuid().v4();

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final xpController = TextEditingController();
    final subTaskController = TextEditingController();

    Future<void> addTask(title, description, xp) {
      initializeDateFormatting('de', null);
      return tasks
          .doc(uid)
          .set({
            'title': title,
            'description': description,
            'xp': int.parse(xp),
            'time': DateFormat.yMMMd('de').add_Hm().format(DateTime.now()),
            'subtasks': subTasks,
            'accepted': false,
            'finished': false,
            'user': '',
            'id': uid
          })
          .then((value) => print("Task added"))
          .catchError((error) => print("Failed to add task: $error"));
    }

    addSubTask(task) {
      if (task.isEmpty || task == null) {
        print('No subtask');
      } else {
        print(subTasks.toString());
        setState(() {
          subTasks.add(task);
        });
        print(subTasks.toString());
      }
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
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              shadowColor: MaterialStateProperty.all(
                                  Colors.transparent)),
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
        },
        child: Scaffold(
            appBar: MyAppbar(title: 'Aufgaben', leading: true,),
            drawer: MyDrawer(),
            body: Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      TextFormField(
                        controller: titleController,
                        maxLength: 20,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25)
                          ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            labelStyle: TextStyle(color: Color(0xffFB9C26)),
                            labelText: 'Titel'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
                        maxLines: 10,
                        maxLength: 500,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            labelStyle: TextStyle(color: Color(0xffFB9C26)),
                            labelText: 'Beschreibung'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte geben Sie eine Beschreibung an.';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      TextFormField(
                        controller: xpController,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            labelStyle: TextStyle(color: Color(0xffFB9C26)),
                            labelText: 'Punkte'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte geben Sie eine Punktzahl an.';
                          }
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 250,
                              child: TextFormField(
                                controller: subTaskController,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 0.0),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 0.0),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  labelStyle: TextStyle(color: Color(0xffFB9C26)),
                                  labelText: 'Teilaufgabe',
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(2)),
                            ElevatedButton(
                                    onPressed: () {
                                      addSubTask(subTaskController.text);
                                      subTaskController.text = '';
                                    },
                                    child: GradientIcon(Icons.add_circle, 45, LinearGradient(
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
                                    )),
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
                                      backgroundColor:
                                      MaterialStateProperty.all(
                                          Colors.transparent),
                                      shadowColor:
                                      MaterialStateProperty.all(
                                          Colors.transparent)),
                                )
                          ]),
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      if(subTasks.isNotEmpty) SizedBox(
                        height: 50,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: subTasks.length,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                subTasks.remove(subTasks[index]);
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    border:  Border.all(color: Colors.white, width: 0)),
                                child: Center(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4.0),
                                            child: Icon(
                                              Icons.remove_circle_outline,
                                              size: 17,
                                            ),
                                          ),
                                          Text(subTasks[index], style: TextStyle(color: Colors.white),),
                                        ],
                                      )),
                                )),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
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
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  addTask(
                                      titleController.text,
                                      descriptionController.text,
                                      xpController.text);
                                  Navigator.pushReplacementNamed(
                                      context, '/tasks');
                                }
                              },
                              child: Text('Speichern')))
                    ],
                  ),
                )),
            bottomNavigationBar: NavigationBar(0)));
  }
}
