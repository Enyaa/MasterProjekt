import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/drawer.dart';

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
            appBar: AppBar(
                title: const Text('Bestenlisten'),
                bottom: const TabBar(tabs: [
                  Tab(
                      icon: Icon(Icons.star),
                      child: Text('Punkte', textAlign: TextAlign.center)),
                  Tab(
                      icon: Icon(Icons.task),
                      child: Text('Aufgaben', textAlign: TextAlign.center)),
                  Tab(
                      icon: Icon(Icons.emoji_events),
                      child: Text('Achievements', textAlign: TextAlign.center))
                ])),
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
          ),
        ));
  }

  getList(String mode, AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    if(mode == 'xp') {
      return snapshot.data!.docs
          .map((doc) => Card(
          child: ListTile(
              title: new Text(doc['name']),
              subtitle: new Text('XP: ' + doc['xp'].toString()),
              onTap: () {})))
          .toList();
    } else if(mode == 'tasks') {
      return snapshot.data!.docs
          .map((doc) => Card(
          child: ListTile(
              title: new Text(doc['name']),
              subtitle: new Text('Abgeschlossene Aufgaben: ' + doc['finishedTaskCount'].toString()),
              onTap: () {})))
          .toList();
    } else if(mode == 'achievements') {
      return snapshot.data!.docs
          .map((doc) => Card(
          child: ListTile(
              title: new Text(doc['name']),
              subtitle: new Text('Abgeschlossene Achievements: ' + doc['finishedChallengesCount'].toString()),
              onTap: () {})))
          .toList();
    }
  }
}
