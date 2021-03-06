import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/globalMethods/achievementHub.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';
import 'package:master_projekt/globalMethods/calculateLevel.dart';

class ChallengeDetail extends StatefulWidget {
  const ChallengeDetail(
      {Key? key,
      required this.title,
      required this.description,
      required this.xp,
      required this.id,
      required this.userId,
      required this.imgUrl,
      required this.finished})
      : super(key: key);

  final String title;
  final String description;
  final int xp;
  final String id;
  final String userId;
  final String imgUrl;
  final List<dynamic> finished;

  @override
  _ChallengeDetailState createState() => _ChallengeDetailState();
}

class _ChallengeDetailState extends State<ChallengeDetail> {
  // Get Firebase instance
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Get current logged in user id
  String getUid() {
    final User? user = auth.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  // get active Team
  Future<String> getActiveTeam() async {
    String activeTeam = '';
    await FirebaseFirestore.instance
        .collection('user')
        .doc(getUid())
        .get()
        .then((value) => activeTeam = value['activeTeam']);
    return activeTeam;
  }

  // get list of admins + creator
  Future<List> getAdminList() async {
    List adminList = [];
    String creator = '';
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(await getActiveTeam())
        .get()
        .then((value) => creator = value['creator']);
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(await getActiveTeam())
        .get()
        .then((value) => adminList = value['admins']);
    adminList.add(creator);
    return adminList;
  }

  // check if user is admin/creator
  Future<bool> checkAdmin() async {
    List adminList = await getAdminList();
    if (adminList.contains(getUid()))
      return true;
    else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    return MyWillPopScope(
        text: 'Zur Herausforderungen-??bersicht zur??ckkehren?',
        destination: '/challenges',
        child: Scaffold(
          appBar: MyAppbar(
              title: 'Herausforderungen',
              leading: true,
              admin: true,
              mode: 'challenge',
              doDelete: deleteChallenge),
          body: Container(
              width: double.infinity,
              margin: EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Challenge image
                                if (widget.imgUrl != '')
                                  Row(children: [
                                    Ink(
                                      height: 24,
                                      width: 24,
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.5, color: Colors.white)),
                                      child: ClipRRect(
                                          child: Image.network(
                                        widget.imgUrl,
                                        fit: BoxFit.fill,
                                      )),
                                    ),
                                    Padding(padding: EdgeInsets.all(10))
                                  ]),
                                // Challenge title
                                Text(widget.title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24)),
                              ],
                            ),
                            Padding(padding: EdgeInsets.all(10)),
                            // Challenge description
                            Text(widget.description,
                                style: TextStyle(fontSize: 18)),
                            Padding(padding: EdgeInsets.all(10)),
                            // Challenge XP
                            Text('XP: ' + widget.xp.toString()),
                            Padding(padding: EdgeInsets.all(10)),
                            // Finish Button if user hasnt finished it yet
                            if (!widget.finished.contains(widget.userId))
                              Container(
                                  width: 300,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        // 10% of the width, so there are ten blinds.
                                        colors: <Color>[
                                          Color(0xffE53147),
                                          Color(0xffFB9C26)
                                        ],
                                        // red to yellow
                                        tileMode: TileMode
                                            .repeated, // repeats the gradient over the canvas
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50))),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent),
                                          shadowColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent)),
                                      onPressed: () => finishChallenge(
                                          widget.id, widget.userId),
                                      child: Text('Abschlie??en'))),
                          ],
                        ))
                  ])),
          bottomNavigationBar: NavigationBar(0),
        ));
  }

  // delete challenges from database if the user is admin/creator
  void deleteChallenge() async {
    FirebaseFirestore.instance.collection('challenges').doc(widget.id).delete();
    FirebaseFirestore.instance.collection('teams').doc(await getActiveTeam()).update(
        {
          'challenges': FieldValue.arrayRemove([widget.id]),
        });
    bool checkAdmins = await checkAdmin();
    if(checkAdmins == true) {
      FirebaseFirestore.instance.collection('user').where('finishedChallenges', arrayContains: widget.id).snapshots().forEach((snapshot) {
        if(snapshot.docs.isNotEmpty) {
          var finished = [];
          finished = snapshot.docs[0]['finishedChallenges'];
          finished.remove(widget.id);
          String user = snapshot.docs[0]['uid'];
          FirebaseFirestore.instance.collection('user').doc(user).update(
              {
                'finishedChallenges': finished
              }
          );
        }
      });

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      final snackBar = SnackBar(
          content: Text('Nur Admins k??nnen Challenges l??schen.'));
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  // Set challenge as finished in database
  void finishChallenge(String id, String userId) async {
    var challenge = await FirebaseFirestore.instance
        .collection('challenges')
        .where('id', isEqualTo: id)
        .get();
    // Get challenge xp and list of users that finished it
    var finishedArr = challenge.docs[0].data()['finished'];
    var notfinishedArr = challenge.docs[0].data()['notfinished'];
    var challengeXp = challenge.docs[0].data()['xp'];

    var user = await FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: userId)
        .get();
    var finishedChallenges = user.docs[0].data()['finishedChallenges'];
    finishedChallenges.add(id);

    var userSnap = FirebaseFirestore.instance.collection('user').doc(userId);
    var challengeSnap = FirebaseFirestore.instance.collection('challenges').doc(id);

    // Update user and challenge data
    finishedArr.add(userId);
    challengeSnap.update({'finished': finishedArr});
    notfinishedArr.remove(userId);
    challengeSnap.update({'notfinished': notfinishedArr});
    userSnap.update({'finishedChallengesCount': FieldValue.increment(1)});
    userSnap.update({
      'finishedChallenges': finishedChallenges
    });
    userSnap.update({'xp': FieldValue.increment(challengeXp)});

    // Check if user has a levelup
    final CalculateLevel logic = new CalculateLevel();
    logic.levelUp(userSnap);


    //check if user gets an achievement
    final AchievementHub logic2 = new AchievementHub();
    logic2.checkAchievement(userSnap);

    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, 'challenges');
  }
}
