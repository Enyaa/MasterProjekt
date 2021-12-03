import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
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
  // get tasks collection and authentication
  var snapshots = FirebaseFirestore.instance.collection('tasks').snapshots();
  final FirebaseAuth auth = FirebaseAuth.instance;

  // get id of current logged in user
  String getUid() {
    final User? user = auth.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  // get list of admins + creator
  Future<List> getAdminList() async {
    String activeTeam = '';
    await FirebaseFirestore.instance
        .collection('user')
        .doc(getUid())
        .get()
        .then((value) => activeTeam = value['activeTeam']);
    List adminList = [];
    String creator = '';
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(activeTeam)
        .get()
        .then((value) => creator = value['creator']);
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(activeTeam)
        .get()
        .then((value) => adminList = value['admins']);
    adminList.add(creator);
    print(adminList);
    return adminList;
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
                // if no data loaded show waiting spinner
                return Container(
                    alignment: Alignment.center,
                    child: GradientCircularProgressIndicator(
                        value: null,
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[Color(0xffE53147), Color(0xffFB9C26)],
                          // red to yellow
                          tileMode: TileMode
                              .repeated, // repeats the gradient over the canvas
                        )));
              // if data is loaded show list of tasks
              return new ListView(
                padding: EdgeInsets.all(10),
                children: getTasks(snapshot, context),
              );
            },
          ),
          // floating button to add a task
          floatingActionButton: FutureBuilder(
            future: getAdminList(),
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData) {
                return Visibility(
                  // only show if user is admin/creator
                  visible: (snapshot.requireData.contains(getUid()))
                      ? true
                      : false,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/task-create');
                    },
                    shape:
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    child: Ink(
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
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: Container(
                        constraints: const BoxConstraints(
                            minWidth: 60, minHeight: 60),
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ),
                );
              }
              return Text('');
            },
          ),
          bottomNavigationBar: NavigationBar(2)),
        text: 'Zur Homepage zurückkehren?',
    );
  }

  // get list of tasks as cards
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

  // filter tasks
  getFiltered(int value) async {
    // Get active Team
    String activeTeam = '';
    await FirebaseFirestore.instance
        .collection('user')
        .doc(getUid())
        .get()
        .then((value) => activeTeam = value['activeTeam']);

    //Get Tasklists depending on context
    var tasks = FirebaseFirestore.instance.collection('tasks');
    if (value == 1) { // all tasks
      setSnapshots(tasks.snapshots());
    } else if (value == 2) { // not accepted or finished
      setSnapshots(tasks
          .where('accepted', isEqualTo: false)
          .where('finished', isEqualTo: false)
          .snapshots());
    } else if (value == 3) { // only accepted by user but not finished
      setSnapshots(tasks
          .where('accepted', isEqualTo: true)
          .where('user', isEqualTo: getUid())
          .where('finished', isEqualTo: false)
          .snapshots());
    } else if (value == 4) { // only finished by user
      setSnapshots(tasks
          .where('finished', isEqualTo: true)
          .where('user', isEqualTo: getUid())
          .snapshots());
    } else if (value == 5) { // only tasks of active team
      setSnapshots(tasks
      .where('teamID', isEqualTo: activeTeam)
      .snapshots());
    }
  }

  //Update Widgets with new SnapshotFilter
  setSnapshots(var value) {
    setState(() {
      snapshots = value;
    });
  }
}
