import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/mytabbar.dart';

class Leaderboards extends StatelessWidget {
  const Leaderboards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var snapshots = FirebaseFirestore.instance.collection('user').snapshots();

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
        },
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: MyAppbar(
                title: 'Bestenlisten',
                bottom: true,
            ),
            drawer: MyDrawer(),
            body: StreamBuilder<QuerySnapshot>(
              stream: snapshots,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const TabBarView(children: [
                    Text('Keine User'),
                    Text('Keine User'),
                    Text('Keine User')
                  ]);
                } else {
                  return TabBarView(children: [
                    ListView(children: getList('xp', snapshot, context)),
                    ListView(children: getList('tasks', snapshot, context)),
                    ListView(
                        children: getList('achievements', snapshot, context)),
                  ]);
                }
              },
            ),
            bottomNavigationBar: NavigationBar(4),
          ),
        ));
  }

  getList(String mode, AsyncSnapshot<QuerySnapshot> snapshot,
      BuildContext context) {
    List<MyUser> _users = new List.empty(growable: true);
    snapshot.data!.docs.forEach((doc) {
      String name = doc['name'];
      int xp = doc['xp'];
      int finishedTasks = doc['finishedTasksCount'];
      int finishedChallenges = doc['finishedChallengesCount'];

      MyUser _user = new MyUser(
          name: name,
          xp: xp,
          tasks: finishedTasks,
          challenges: finishedChallenges);
      _users.add(_user);
    });

    if (mode == 'xp') {
      return sort(_users, 0)
          .map<Widget>((user) => Card(
              child: ListTile(
                  title: new Text(user.name),
                  leading: new Text(
                      (sort(_users, 0).indexOf(user) + 1).toString() + '.',
                      style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.center),
                  subtitle: new Text('XP: ' + user.xp.toString()),
                  onTap: () {})))
          .toList();
    } else if (mode == 'tasks') {
      return sort(_users, 1)
          .map<Widget>((user) => Card(
              child: ListTile(
                  title: new Text(user.name),
                  leading: new Text(
                      (sort(_users, 1).indexOf(user) + 1).toString() + '.',
                      style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.center),
                  subtitle: new Text(
                      'Abgeschlossene Aufgaben: ' + user.tasks.toString()),
                  onTap: () {})))
          .toList();
    } else if (mode == 'achievements') {
      return sort(_users, 2)
          .map<Widget>((user) => Card(
              child: ListTile(
                  title: new Text(user.name),
                  leading: new Text(
                      (sort(_users, 2).indexOf(user) + 1).toString() + '.',
                      style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.center),
                  subtitle: new Text('Abgeschlossene Achievements: ' +
                      user.challenges.toString()),
                  onTap: () {})))
          .toList();
    }
  }

  sort(List<MyUser> users, int mode) {
    List<MyUser> sorted;
    if (mode == 0)
      users.sort((a, b) => a.xp.compareTo(b.xp));
    else if (mode == 1)
      users.sort((a, b) => a.tasks.compareTo(b.tasks));
    else
      users.sort((a, b) => a.challenges.compareTo(b.challenges));

    sorted = users.reversed.toList();
    return sorted;
  }
}

class MyUser {
  MyUser(
      {required this.name,
      required this.xp,
      required this.tasks,
      required this.challenges});

  String name;
  int xp;
  int tasks;
  int challenges;
}
