import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:master_projekt/globalMethods/methods.dart';
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

class ProfilState extends State<Profil> {
  var snapshots = FirebaseFirestore.instance.collection('user').snapshots();
  var achievements =
      FirebaseFirestore.instance.collection('achievements').snapshots();

  var taskSnapshots = FirebaseFirestore.instance
      .collection('tasks')
      .where('user', isEqualTo: getUid())
      .snapshots();

  var challengeSnapshots = FirebaseFirestore.instance
      .collection('challenges')
      .where('finished', arrayContains: getUid())
      .snapshots();

  var achievementSnapshots = FirebaseFirestore.instance
      .collection('achievements')
      .where('userFinished', arrayContains: getUid())
      .snapshots();

  var placeholder =
      "https://firebasestorage.googleapis.com/v0/b/teamrad-41db5.appspot.com/o/profilePictures%2Frettichplaceholder.png?alt=media&token=f4fdc841-5c28-486a-848d-fde5fb64c21e";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(title: const Text('Profil')),
            drawer: MyDrawer(),
            body: SafeArea(
              child: Column(children: [
                Stack(
                  clipBehavior: Clip.none,
                    children: [
                      StreamBuilder(
                          stream: snapshots,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data!.docs.firstWhere((user) =>
                                        user['uid'] == getUid())['imgUrl'] !=
                                    '') {
                              String imgUrl = snapshot.data!.docs.firstWhere(
                                  (user) => user['uid'] == getUid())['imgUrl'];
                              return Padding(
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 5,
                                              spreadRadius: 0.5)
                                        ],
                                        gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            // 10% of the width, so there are ten blinds.
                                            colors: <Color>[
                                              Color(0xffE53147),
                                              Color(0xffFB9C26)
                                            ],
                                            // red to yellow
                                            tileMode: TileMode.repeated),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Padding(
                                          padding: EdgeInsets.all(3),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: Image.network(imgUrl,
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.fill)))));
                            } else {
                              return Padding(
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 5,
                                              spreadRadius: 0.5)
                                        ],
                                        gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            // 10% of the width, so there are ten blinds.
                                            colors: <Color>[
                                              Color(0xffE53147),
                                              Color(0xffFB9C26)
                                            ],
                                            // red to yellow
                                            tileMode: TileMode.repeated),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Padding(
                                          padding: EdgeInsets.all(3),
                                          child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(50),
                                              child: Image.network(placeholder,
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.fill)))));
                            }
                          }),
                new Positioned(
                    left:30,
                    top: 110,
                    child:Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        width: 50,
                        height: 25,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: <Color>[
                                Color(0xffE53147),
                                Color(0xffFB9C26)
                              ], // red to yellow
                              tileMode: TileMode
                                  .repeated, // repeats the gradient over the canvas
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Methods(mode: 'level.s'),
                      )),
                    ]),
                Container(
                    child: Column(
                        children: [
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
                            margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                              child: new Text(
                            snapshot.data!.docs.firstWhere(
                                (user) => user['uid'] == getUid())['name'],
                            style: TextStyle(
                                fontSize: 25.0,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w400),
                          )));
                        }
                      }),
                ])),
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
                                  height: 7,
                                  padding: EdgeInsets.all(0.8),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      color: Colors.white),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 50.0, vertical: 10),
                                  child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      child: GradientProgressIndicator(
                                        value: (snapshotuid.data!.docs.firstWhere((user) => user['uid'] == getUid())['xp'] -
                                                snapshotuid.data!.docs
                                                        .firstWhere((user) => user['uid'] == getUid())[
                                                    'pointsNeededBevor']) /
                                            (snapshotuid.data!.docs.firstWhere((user) =>
                                                    user['uid'] ==
                                                    getUid())['pointsNeeded'] -
                                                snapshotuid.data!.docs
                                                    .firstWhere((user) =>
                                                        user['uid'] ==
                                                        getUid())['pointsNeededBevor']),
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: <Color>[
                                            Color(0xffE53147),
                                            Color(0xffFB9C26)
                                          ], // red to yellow
                                          tileMode: TileMode
                                              .repeated, // repeats the gradient over the canvas
                                        ),
                                        //valueColor: AlwaysStoppedAnimation(
                                        //    Colors.deepOrange),
                                        //backgroundColor: Colors.grey,
                                      ))),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          (snapshotuid.data!.docs.firstWhere(
                                                          (user) =>
                                                              user['uid'] ==
                                                              getUid())[
                                                      'pointsNeeded'] -
                                                  snapshotuid.data!.docs
                                                      .firstWhere((user) =>
                                                          user['uid'] ==
                                                          getUid())['xp'])
                                              .toString(),
                                          style: TextStyle(
                                              color: Color(0xffFB9C26)),
                                        ),
                                        Text(' XP BIS LEVEL ' +
                                            (snapshotuid.data!.docs.firstWhere(
                                                        (user) =>
                                                            user['uid'] ==
                                                            getUid())['level'] +
                                                    1)
                                                .toString())
                                      ]))
                            ]);
                          }
                        })),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TabBar(tabs: [
                    Tab(
                        child: Text(
                      'Aufgaben',
                      textAlign: TextAlign.center,
                    )),
                    Tab(
                        child: Text(
                      'Heraus-\nforderungen',
                      textAlign: TextAlign.center,
                    )),
                    Tab(
                        child: Text(
                      'Erfolge',
                      textAlign: TextAlign.center,
                    )),
                  ]),
                ),
                Expanded(
                    child: TabBarView(children: <Widget>[
                  StreamBuilder(
                    stream: taskSnapshots,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      return ListView(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          children: getList('tasks', snapshot, context));
                    },
                  ),
                  StreamBuilder(
                    stream: challengeSnapshots,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      return ListView(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          children: getList('challenges', snapshot, context));
                    },
                  ),
                  StreamBuilder(
                    stream: achievementSnapshots,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      return ListView(
                          children: getList('achievements', snapshot, context));
                    },
                  ),
                ]))
              ]),
            ),
            bottomNavigationBar: NavigationBar(0)));
  }

  //builds Card für Tabbar
  getList(String mode, AsyncSnapshot<QuerySnapshot> snapshot,
      BuildContext context) {
    // Cards for Tasks
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
      //Cards for Challenges
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
      // Cards for Achievements
    } else if (mode == 'achievements') {
      return snapshot.data!.docs
          .map<Widget>((doc) => Card(
                  child: ListTile(
                title: new Text(doc['title']),
                subtitle: new Text(doc['description']),
                trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center, children: [
                ]),
              )))
          .toList();
    }
  }
}
