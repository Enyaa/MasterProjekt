import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/navigation/navigationbar.dart';

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
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  })),
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
                                Text(widget.title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24)),
                              ],
                            ),
                            Padding(padding: EdgeInsets.all(10)),
                            Text(widget.description,
                                style: TextStyle(fontSize: 18)),
                            Padding(padding: EdgeInsets.all(10)),
                            Text('XP: ' + widget.xp.toString()),
                            Padding(padding: EdgeInsets.all(10)),
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
                                      child: Text('Abschließen'))),
                          ],
                        ))
                  ])),
          bottomNavigationBar: NavigationBar(0),
        ));
  }

  void finishChallenge(String id, String userId) async {
    var challenge = await FirebaseFirestore.instance
        .collection('challenges')
        .where('id', isEqualTo: id)
        .get();
    var finishedArr = challenge.docs[0].data()['finished'];
    var challengeXp = challenge.docs[0].data()['xp'];
    finishedArr.add(userId);
    FirebaseFirestore.instance
        .collection('challenges')
        .doc(id)
        .update({'finished': finishedArr});
    FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .update({'finishedChallengesCount': FieldValue.increment(1)});
    FirebaseFirestore.instance.collection('user').doc(userId).update({
      'finishedChallenges': FieldValue.arrayUnion([id])
    });
    FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .update({'xp': FieldValue.increment(challengeXp)});
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, 'challenges');
  }
}
