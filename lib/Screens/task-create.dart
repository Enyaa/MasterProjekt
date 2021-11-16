import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
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
            appBar: MyAppbar(title: 'Aufgaben', actions: false, bottom: false, leading: false,),
            drawer: MyDrawer(),
            body: Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: titleController,
                        maxLength: 20,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Titel',
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
                        maxLines: 5,
                        maxLength: 200,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Beschreibung',
                            labelText: 'Beschreibung'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte geben Sie eine Beschreibung an.';
                          }
                          return null;
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
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Hier Teilaufgaben hinzufügen',
                                  labelText: 'Teilaufgabe',
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(10)),
                            Container(
                                width: 50,
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
                                    onPressed: () {
                                      addSubTask(subTaskController.text);
                                      subTaskController.text = '';
                                    },
                                    child: Icon(Icons.add, size: 25),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.transparent),
                                      shadowColor: MaterialStateProperty.all(
                                          Colors.transparent),
                                    )))
                          ]),
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      SizedBox(
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
                                margin: EdgeInsets.all(7.0),
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 0.5,
                                          blurRadius: 0.5,
                                          offset: Offset(1, 1))
                                    ]),
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
                                          Text(subTasks[index]),
                                        ],
                                      )),
                                )),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      TextFormField(
                        controller: xpController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Punkte',
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
