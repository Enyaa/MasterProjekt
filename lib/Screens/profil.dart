import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/level/methods.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';

class Profil extends StatelessWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var snapshots = FirebaseFirestore.instance.collection('user').snapshots();

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(title: const Text('Profil')),
            drawer: MyDrawer(),
            body: SafeArea(
              child: SingleChildScrollView(
                  child: Column(children: [
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image:
                              AssetImage('lib/Graphics/profil-background.jpg'),
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
                SizedBox(
                  height: 70,
                ),
                Container(
                    child: Column(children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: snapshots,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return new Text('Kein Namen gefunden ');
                        } else {
                          return (new Text(
                            snapshot.data!.docs.firstWhere(
                                (user) => user['uid'] == getUid())['name'],
                            style: TextStyle(
                                fontSize: 25.0,
                                color: Colors.black,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w400),
                          ));
                        }
                      }),
                  Text('   Level: '),
                  Methods(mode: 'level.s'),
                ])),

                SizedBox(
                    height: 50,
                    width: 300,
                    child: Container(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: snapshots,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshotuid) {
                              if (!snapshotuid.hasData) {
                                return new Text('Loading...');
                              } else {
                                return new Column(children: [
                                  new Container(
                                      child: LinearProgressIndicator(
                                    value: snapshotuid.data!.docs.firstWhere(
                                            (user) =>
                                                user['uid'] == getUid())['xp'] /
                                        snapshotuid.data!.docs.firstWhere(
                                            (user) =>
                                                user['uid'] ==
                                                getUid())['pointsNeeded'],
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.deepOrange),
                                    backgroundColor: Colors.grey,
                                  )),
                                  new Container(
                                      child: Column(children: [
                                    Methods(mode: 'currentXp.s'),
                                    Methods(mode: 'pointsNeeded.s'),
                                    Methods(mode: 'checkLevel')
                                  ]))
                                ]);
                              }
                            }))),
                SizedBox(
                  height: 20,
                ),
                TabBar(tabs: [
                  Tab(
                      icon: Icon(Icons.star),
                      child: Text('Punkte',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black))),
                  Tab(
                      icon: Icon(Icons.task),
                      child: Text('Aufgaben',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black))),
                ]),
                SizedBox(
                  height: 20,
                  //child: StreamBuilder<QuerySnapshot>(
                  //    stream: snapshots,
                  //    builder: (BuildContext context,
                  //        AsyncSnapshot<QuerySnapshot> snapshot) {
                  //      if (!snapshot.hasData) {
                  //        return TabBarView(
                  //          children: [
                  //            ListView(
                  //                children: [Text('Keine Daten gefunden!')]),
                  //            ListView(
                  //              children: [Text('Keine Daten gefunden!')],
                  //            )
                  //          ],
                  //        );
                  //      } else {
                  //        return TabBarView(children: [
                  //          ListView(children: []),
                  //          ListView(children: [])
                  //        ]);
                  //     }
                  //}
                )
                //)
              ])),
            ),
            bottomNavigationBar: NavigationBar(0)));
  }

  String getUid() {
    return FirebaseAuth.instance.currentUser!.uid.toString();
  }
}
