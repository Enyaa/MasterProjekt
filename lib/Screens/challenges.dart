import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:master_projekt/Screens/challenge-detail.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';

class Challenges extends StatefulWidget {
  const Challenges({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new ChallengesState();
}

class ChallengesState extends State<Challenges> {
  // Get challenges collection
  var snapshots = FirebaseFirestore.instance.collection('challenges').snapshots();
  // Get Authentication
  final FirebaseAuth auth = FirebaseAuth.instance;

  // init State with filtered snapshot
  void initState() {
    getFiltered(1);
    super.initState();
  }

  // Get uid of current logged in user
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
      text: 'Zur Homepage zurückkehren?',
        child: Scaffold(
          appBar: MyAppbar(title: 'Herausforderungen', actions: true, getFiltered: getFiltered),
          drawer: MyDrawer(),
          body: StreamBuilder<QuerySnapshot>(
            stream: snapshots,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // Show Waiting Spinner if data hasnt loaded
              if (!snapshot.hasData)
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
              // Show list of challenges if they have been loaded
              return new ListView(
                children: getChallenges(snapshot, context),
              );
            },
          ),
          // Floating button to create a challenge
          floatingActionButton: FutureBuilder(
            future: getAdminList(),
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData) {
                return Visibility(
                  // only show if the user is admin/creator
                  visible: (snapshot.requireData.contains(getUid()))
                      ? true
                      : false,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/challenge-create');
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
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                );
              }
              return Text('');
            },
          ),
          bottomNavigationBar: NavigationBar(3),
        ));
  }

  // get list of challenges as cards with info
  getChallenges(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
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
              // on tap open challenge detail page
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

  // Filter challenges
  getFiltered(int value) async{
    // Get active Team
    String activeTeam = '';
    await FirebaseFirestore.instance
        .collection('user')
        .doc(getUid())
        .get()
        .then((value) => activeTeam = value['activeTeam']);

    var challenges = FirebaseFirestore.instance.collection('challenges').where('teamID', isEqualTo: activeTeam);

    // show all
    if(value == 1) {
      setSnapshots(challenges.snapshots());
    } else if (value == 2) { // show only challenges that havent been finished by user
      setSnapshots(challenges.where('notfinished', arrayContains: getUid()).snapshots());
    } else if (value == 4) { // show only challenges that have been finished by user
      setSnapshots(challenges.where('finished', arrayContains: getUid()).snapshots());
    }
  }

  setSnapshots(var value) {
    setState(() {
      snapshots = value;
    });
  }
}
