import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/mytabbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';

class Leaderboards extends StatelessWidget {
  const Leaderboards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var snapshots = FirebaseFirestore.instance.collection('user').snapshots();

    return MyWillPopScope(
        text: 'Zur Homepage zurückkehren?',
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
                    ListView(
                        children: getList('xp', snapshot, context),
                        padding: EdgeInsets.all(10)),
                    ListView(
                        children: getList('tasks', snapshot, context),
                        padding: EdgeInsets.all(10)),
                    ListView(
                        children: getList('achievements', snapshot, context),
                        padding: EdgeInsets.all(10)),
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
      String image = doc['imgUrl'];

      if (image == '') {
        image =
            'https://firebasestorage.googleapis.com/v0/b/teamrad-41db5.appspot.com/o/profilePictures%2Frettichplaceholder.png?alt=media&token=f4fdc841-5c28-486a-848d-fde5fb64c21e';
      }

      MyUser _user = new MyUser(
          name: name,
          xp: xp,
          tasks: finishedTasks,
          challenges: finishedChallenges,
          image: image);
      _users.add(_user);
    });

    if (mode == 'xp') {
      return sort(_users, 0)
          .map<Widget>((user) => Row(children: [
                new Text((sort(_users, 0).indexOf(user) + 1).toString() + '.',
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center),
                SizedBox(
                    height: 80,
                    width: 310,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                topLeft: Radius.circular(50))),
                        child: ListTile(
                            title: new Text(user.name),
                            leading: Ink(
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  border: Border.all(
                                      width: 0.5, color: Colors.white)),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    user.image,
                                    fit: BoxFit.fill,
                                  )),
                            ),
                            subtitle: new Text('XP: ' + user.xp.toString()),
                            onTap: () {})))
              ]))
          .toList();
    } else if (mode == 'tasks') {
      return sort(_users, 1)
          .map<Widget>((user) => Row(children: [
                new Text((sort(_users, 1).indexOf(user) + 1).toString() + '.',
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center),
                SizedBox(
                    height: 80,
                    width: 310,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                topLeft: Radius.circular(50))),
                        child: ListTile(
                            title: new Text(user.name),
                            leading: Ink(
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  border: Border.all(
                                      width: 0.5, color: Colors.white)),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    user.image,
                                    fit: BoxFit.fill,
                                  )),
                            ),
                            subtitle: new Text('Abgeschlossene Aufgaben: ' +
                                user.tasks.toString()),
                            onTap: () {})))
              ]))
          .toList();
    } else if (mode == 'achievements') {
      return sort(_users, 2)
          .map<Widget>((user) => Row(children: [
                new Text((sort(_users, 2).indexOf(user) + 1).toString() + '.',
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center),
                SizedBox(
                    height: 80,
                    width: 310,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                topLeft: Radius.circular(50))),
                        child: ListTile(
                            title: new Text(user.name),
                            leading: Ink(
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  border: Border.all(
                                      width: 0.5, color: Colors.white)),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    user.image,
                                    fit: BoxFit.fill,
                                  )),
                            ),
                            subtitle: new Text('Abgeschlossene Achievements: ' +
                                user.challenges.toString()),
                            onTap: () {})))
              ]))
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
      required this.challenges,
      required this.image});

  String name;
  int xp;
  int tasks;
  int challenges;
  String image;
}
