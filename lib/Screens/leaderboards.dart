import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';

class Leaderboards extends StatelessWidget {
  const Leaderboards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get collection of users
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
                // if no data loaded show waiting spinner
                if (!snapshot.hasData) {
                  return TabBarView(children: [
                    Container(
                        alignment: Alignment.center,
                        child: GradientCircularProgressIndicator(
                            value: null,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: <Color>[
                                Color(0xffE53147),
                                Color(0xffFB9C26)
                              ],
                              // red to yellow
                              tileMode: TileMode
                                  .repeated, // repeats the gradient over the canvas
                            ))),
                    Container(
                        alignment: Alignment.center,
                        child: GradientCircularProgressIndicator(
                            value: null,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: <Color>[
                                Color(0xffE53147),
                                Color(0xffFB9C26)
                              ],
                              // red to yellow
                              tileMode: TileMode
                                  .repeated, // repeats the gradient over the canvas
                            ))),
                    Container(
                        alignment: Alignment.center,
                        child: GradientCircularProgressIndicator(
                            value: null,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: <Color>[
                                Color(0xffE53147),
                                Color(0xffFB9C26)
                              ],
                              // red to yellow
                              tileMode: TileMode
                                  .repeated, // repeats the gradient over the canvas
                            )))
                  ]);
                } else {
                  // if data has been loaded show tabbarview with Lists
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

  // get list of users sorted by xp, finished tasks or finished challenges
  getList(String mode, AsyncSnapshot<QuerySnapshot> snapshot,
      BuildContext context) {
    List<MyUser> _users = new List.empty(growable: true);
    snapshot.data!.docs.forEach((doc) {
      String name = doc['name'];
      int xp = doc['xp'];
      int finishedTasks = doc['finishedTasksCount'];
      int finishedChallenges = doc['finishedChallengesCount'];
      String image = doc['imgUrl'];

      // if no image provided use placeholder
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

    // List sorted by XP
    if (mode == 'xp') {
      return sort(_users, 0)
          .map<Widget>((user) => Row(children: [
                Expanded(
                  flex: 2,
                    child: Text((sort(_users, 0).indexOf(user) + 1).toString() + '.',
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center)),
                Expanded(
                  flex: 8,
                    child: SizedBox(
                    height: 80,
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
                            subtitle: new Text('Punkte: ' + user.xp.toString()),
                            onTap: () {})))
                )]))
          .toList();
    } else if (mode == 'tasks') {
      // list sorted by tasks
      return sort(_users, 1)
          .map<Widget>((user) => Row(children: [
                Expanded(
                  flex: 2,
                    child: Text((sort(_users, 1).indexOf(user) + 1).toString() + '.',
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center)),
                Expanded(
                  flex: 8,
                    child: SizedBox(
                    height: 80,
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
                            subtitle:
                                new Text('Aufgaben: ' + user.tasks.toString()),
                            onTap: () {})))
                )]))
          .toList();
    } else if (mode == 'achievements') {
      // list sorted by challenges
      return sort(_users, 2)
          .map<Widget>((user) => Row(children: [
                Expanded(
                  flex: 2,
                    child: Text((sort(_users, 2).indexOf(user) + 1).toString() + '.',
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center)),
                Expanded(
                  flex: 8,
                    child: SizedBox(
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
                            subtitle: new Text('Herausforderungen: ' +
                                user.challenges.toString()),
                            onTap: () {})))
                )]))
          .toList();
    }
  }

  // sort users
  sort(List<MyUser> users, int mode) {
    List<MyUser> sorted;
    if (mode == 0) // by xp
      users.sort((a, b) => a.xp.compareTo(b.xp));
    else if (mode == 1) // by tasks
      users.sort((a, b) => a.tasks.compareTo(b.tasks));
    else // by challenges
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
