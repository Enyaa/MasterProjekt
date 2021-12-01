import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:master_projekt/level/methods.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new ProfilState();
}

String getUid() {
  return FirebaseAuth.instance.currentUser!.uid.toString();
}

class ProfilState extends State<Profil> with TickerProviderStateMixin {
  var snapshots = FirebaseFirestore.instance.collection('user').snapshots();
  var taskSnapshots = FirebaseFirestore.instance
      .collection('tasks')
      .where('user', isEqualTo: getUid())
      .snapshots();
  var challengeSnapshots =
      FirebaseFirestore.instance.collection('challenges').snapshots();
  var achievementSnapshots =
      FirebaseFirestore.instance.collection('achievements').snapshots();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        drawer: MyDrawer(),
        body: SafeArea(
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('lib/Graphics/profil-background.jpg'),
                      fit: BoxFit.cover)),
              child: Container(
                width: double.infinity,
                height: 200,
                child: Container(
                  alignment: Alignment(0.0, 2.5),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: AssetImage('lib/Graphics/rettich.png'),
                    radius: 60.0,
                  ),
                ),
              ),
            ),
            Container(
                child: Column(children: [
              StreamBuilder<QuerySnapshot>(
                  stream: snapshots,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
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
                              )));
                    } else {
                      return (Container(
                          margin: EdgeInsets.all(10),
                          child: new Text(
                            snapshot.data!.docs.firstWhere(
                                (user) => user['uid'] == getUid())['name'],
                            style: TextStyle(
                                fontSize: 25.0,
                                color: Colors.black,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w400),
                          )));
                    }
                  }),
            ])),
            Container(
                child: Row(
              children: [
                Text('   Level: '),
                Methods(mode: 'level.s'),
              ],
            )),
            Container(
                child: StreamBuilder<QuerySnapshot>(
                    stream: snapshots,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshotuid) {
                      if (!snapshotuid.hasData) {
                        return Container(
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
                                )));
                      } else {
                        return new Column(children: [
                          Container(
                              child: LinearProgressIndicator(
                            value: snapshotuid.data!.docs.firstWhere(
                                    (user) => user['uid'] == getUid())['xp'] /
                                snapshotuid.data!.docs.firstWhere((user) =>
                                    user['uid'] == getUid())['pointsNeeded'],
                            valueColor:
                                AlwaysStoppedAnimation(Colors.deepOrange),
                            backgroundColor: Colors.grey,
                          )),
                          Container(
                              child: Column(children: [
                            Methods(mode: 'currentXp.s'),
                            Methods(mode: 'pointsNeeded.s')
                          ]))
                        ]);
                      }
                    })),
            TabBar(controller: _tabController, tabs: [
              Tab(
                  child: Text('Aufgaben',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black))),
              Tab(
                  child: Text('Heraus-\nforderungen',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black))),
              Tab(
                  child: Text('Erfolge',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black))),
            ]),
            Expanded(
                child:
                    TabBarView(controller: _tabController, children: <Widget>[
              StreamBuilder(
                stream: taskSnapshots,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  return ListView(children: getList('tasks', snapshot, context));
                },
              ),
              StreamBuilder(
                stream: challengeSnapshots,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  return ListView(children: getList('challenges', snapshot, context));
                },
              ),
              StreamBuilder(
                stream: achievementSnapshots,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  return ListView(children: getList('achievements', snapshot, context));
                },
              ),
            ]))
          ]),
        ),
        bottomNavigationBar: NavigationBar(0));
  }

  getList(String mode, AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    if (!snapshot.hasData) {
      return [Center(child: CircularProgressIndicator())];
    } else if (mode == 'tasks') {
      return snapshot.data!.docs
          .map<Widget>((doc) => Card(
                  child: ListTile(
                title: new Text(doc['title']),
                subtitle: new Text(doc['description']),
                trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(child: new Text(doc['xp'].toString() + ' XP')),
                      Container(child: new Text(doc['time'].toString())),
                    ]),
              )))
          .toList();
    } else if (mode == 'challenges') {
      return snapshot.data!.docs
          .map<Widget>((doc) => Card(
                  child: ListTile(
                title: new Text(doc['title']),
                subtitle: new Text(doc['description']),
                trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(child: new Text(doc['xp'].toString() + ' XP')),
                    ]),
              )))
          .toList();
    } else if (mode == 'achievements') {
      return snapshot.data!.docs
          .map<Widget>((doc) => Card(
                  child: ListTile(
                title: new Text(doc['title']),
                subtitle: new Text(doc['description']),
                trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center, children: []),
              )))
          .toList();
    }
  }
}
