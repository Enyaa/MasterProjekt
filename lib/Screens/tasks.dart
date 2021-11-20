import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/Screens/task-detail.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';

class Tasks extends StatefulWidget {
  const Tasks({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new TasksState();
}

class TasksState extends State<Tasks> {
  var snapshots = FirebaseFirestore.instance.collection('tasks').snapshots();
  final FirebaseAuth auth = FirebaseAuth.instance;

  String getUid() {
    final User? user = auth.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MyWillPopScope(
        child: Scaffold(
          appBar: MyAppbar(title: 'Aufgaben', actions: true, accepted: true, getFiltered: getFiltered),
          drawer: MyDrawer(),
          body: StreamBuilder<QuerySnapshot>(
            stream: snapshots,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return new Text("Es gibt aktuell keine Aufgaben.");
              return new ListView(
                padding: EdgeInsets.all(10),
                children: getTasks(snapshot, context),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/task-create');
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            child: Ink(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    // 10% of the width, so there are ten blinds.
                    colors: <Color>[Color(0xffE53147), Color(0xffFB9C26)],
                    // red to yellow
                    tileMode: TileMode
                        .repeated, // repeats the gradient over the canvas
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Container(
                constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
                child: const Icon(Icons.add),
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(2)),
        text: 'Zur Homepage zurückkehren?',
    );
  }

  getTasks(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    return snapshot.data!.docs
        .map((doc) => Card(
            child: ListTile(
                title: new Text(doc['title']),
                subtitle: new Text(doc['description']),
                trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(width: 2, color: Color(0xffFB9C26))),
                        child: Icon(Icons.keyboard_arrow_right_outlined,
                            color: Color(0xffFB9C26)),
                      )
                    ]),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetail(
                          title: doc['title'],
                          description: doc['description'],
                          subTasks: doc['subtasks'],
                          xp: doc['xp'],
                          time: doc['time'],
                          id: doc.id,
                          accepted: doc['accepted'],
                          finished: doc['finished'],
                          userId: doc['user'],
                        ),
                      ));
                })))
        .toList();
  }

  getFiltered(int value) {
    var tasks = FirebaseFirestore.instance.collection('tasks');
    if (value == 1) {
      setSnapshots(tasks.snapshots());
    } else if (value == 2) {
      setSnapshots(tasks
          .where('accepted', isEqualTo: false)
          .where('finished', isEqualTo: false)
          .snapshots());
    } else if (value == 3) {
      setSnapshots(tasks
          .where('accepted', isEqualTo: true)
          .where('user', isEqualTo: getUid())
          .where('finished', isEqualTo: false)
          .snapshots());
    } else if (value == 4) {
      setSnapshots(tasks
          .where('finished', isEqualTo: true)
          .where('user', isEqualTo: getUid())
          .snapshots());
    }
  }

  setSnapshots(var value) {
    setState(() {
      snapshots = value;
    });
  }
}
