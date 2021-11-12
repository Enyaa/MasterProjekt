import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/Screens/challenge-detail.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';

class Challenges extends StatefulWidget {
  const Challenges({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new ChallengesState();
}
class ChallengesState extends State<Challenges> {
  var snapshots = FirebaseFirestore.instance.collection('challenges').snapshots();
  final FirebaseAuth auth = FirebaseAuth.instance;

  String getUid() {
    final User? user = auth.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  @override
  Widget build(BuildContext context) {

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
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Herausforderungen'),
            actions: <Widget>[
              PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text('Alle'), value: 1),
                    PopupMenuItem(child: Text('Offen'), value: 2),
                    PopupMenuItem(child: Text('Abgeschlossen'), value: 3)
                  ],
                  onSelected: getFiltered
              )
            ],
          ),
          drawer: MyDrawer(),
          body: StreamBuilder<QuerySnapshot>(
            stream: snapshots,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return new Text("Es gibt aktuell keine Herausforderungen.");
              return new ListView(
                children: getTasks(snapshot, context),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/challenge-create');
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
          bottomNavigationBar: NavigationBar(3),
        ));
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
                    builder: (context) => ChallengeDetail(
                      title: doc['title'],
                      description: doc['description'],
                      xp: doc['xp'],
                      id: doc['id'],
                      userId: getUid(),
                      imgUrl: doc['imgUrl'],
                      finished: doc['finished']
                    ),
                  ));
            })))
        .toList();
  }

  getFiltered(int value) async{
    var challenges = FirebaseFirestore.instance.collection('challenges');
    var user = await FirebaseFirestore.instance.collection('user').where('uid', isEqualTo: getUid()).get();
    var finishedChallenges = user.docs[0].data()['finishedChallenges'];

    if(value == 1) {
      setSnapshots(challenges.snapshots());
    } else if (value == 2) {
      if(finishedChallenges.isNotEmpty) setSnapshots(challenges.where('id', whereNotIn: finishedChallenges).snapshots());
      else setSnapshots(challenges.snapshots());
    } else if (value == 3) {
      setSnapshots(challenges.where('finished', arrayContains: getUid()).snapshots());
    }
  }

  setSnapshots(var value) {
    setState(() {
      snapshots = value;
    });
  }
}
