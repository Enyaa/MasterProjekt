import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/level/methods.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:async/async.dart';


class Profil extends StatefulWidget {
const Profil({Key? key}) : super(key: key);
@override
State<StatefulWidget> createState() => new ProfilState();
}
class ProfilState extends State<Profil>{
    var snapshots = FirebaseFirestore.instance.collection('user').snapshots();
    var challenges = FirebaseFirestore.instance.collection('challenges');


  String getUid() {
    return FirebaseAuth.instance.currentUser!.uid.toString();
  }



  @override
  Widget build(BuildContext context) {


    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(title: const Text('Profil')),
            drawer: MyDrawer(),
            body: SafeArea(
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
                            return new Text('Loading...');
                          } else {
                            return new Column(children: [
                              Container(
                                  child: LinearProgressIndicator(
                                value: snapshotuid.data!.docs.firstWhere(
                                        (user) =>
                                            user['uid'] == getUid())['xp'] /
                                    snapshotuid.data!.docs.firstWhere((user) =>
                                        user['uid'] ==
                                        getUid())['pointsNeeded'],
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
                TabBar(tabs: [
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
                    child: StreamBuilder<QuerySnapshot>(
                        stream: snapshots,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return TabBarView(
                              children: [
                                ListView(
                                    children: [Text('Keine Daten gefunden!')]),
                                ListView(
                                    children: [Text('Keine Daten gefunden!')]),
                                ListView(
                                    children: [Text('Keine Daten gefunden!')])
                              ],
                            );
                          } else {
                            return TabBarView(children: [
                              ListView(padding: EdgeInsets.all(10),
                                  //children:getTasks(snapshot, context),
                              ),
                              ListView(
                                children:getChallenge(snapshot, context),
                                  ),
                              ListView(children: [])
                            ]);
                          }
                        }))
              ]),
            ),
            bottomNavigationBar: NavigationBar(0)));
  }



  getTasks(AsyncSnapshot<QuerySnapshot> snapshotTask, BuildContext context) {
    return snapshotTask.data!.docs
        .map<Widget>((doc) => Card(
                child: ListTile(
              title: new Text(doc['title']),
              subtitle: new Text(doc['description']),
              trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(child:
                        new Text(doc['xp'].toString()+' XP')
                    ),
                    Container(child:
                    new Text(doc['time'].toString())
                    ),
                  ]),
            )))
        .toList();
  }
  getChallenge(AsyncSnapshot<QuerySnapshot> snapshotChallenge, BuildContext context) {
    setSnapshots(challenges.where('finished', arrayContains: getUid()).snapshots());

    return snapshotChallenge.data!.docs
        .map<Widget>((doc) => Card(
        child: ListTile(
          title: new Text(doc['title']),
          subtitle: new Text(doc['description']),
          trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(child:
                new Text(doc['xp'].toString()+' XP')
                ),
                Container(child:
                new Text(doc['time'].toString())
                ),
              ]),
        )))
        .toList();
  }
  getAchievments(AsyncSnapshot<QuerySnapshot> snapshotChallenge, BuildContext context) {
    return snapshotChallenge.data!.docs
        .map<Widget>((doc) => Card(
        child: ListTile(
          title: new Text(doc['title']),
          subtitle: new Text(doc['description']),
          trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(child:
                new Text(doc['xp'].toString()+' XP')
                ),
                Container(child:
                new Text(doc['time'].toString())
                ),
              ]),
        )))
        .toList();
  }

  getFiltered(int value) async{


    var user =  await FirebaseFirestore.instance.collection('user').where('uid', isEqualTo: getUid()).get();
    var finishedChallenges = user.docs[0].data()['finishedChallenges'];

    if(value == 1) {
      setSnapshots(challenges.snapshots());
    } else if (value == 2) {
      if(finishedChallenges.isNotEmpty) setSnapshots(challenges.where('id', whereNotIn: finishedChallenges).snapshots());
      else setSnapshots(challenges.snapshots());
    } else if (value == 4) {

    }
  }

  setSnapshots(var value) {
    setState(() {
      snapshots = value;
    });
  }
}

