import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';


class TeamsDetail extends StatefulWidget {

  const TeamsDetail({Key? key, required this.teamID, required this.admins, required this.member,
    required this.creator, required this.teamName}) : super(key: key);

  final String teamID;
  final List<dynamic> admins;
  final List<dynamic> member;
  final String creator;
  final String teamName;

  @override
  _TeamsDetailState createState() => _TeamsDetailState();
}

class _TeamsDetailState extends State<TeamsDetail> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  List<dynamic> changeList = [];
  bool changed = false;

  String getUid() {
    final User? user = auth.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  @override
  Widget build(BuildContext context) {
    var snapshots = FirebaseFirestore.instance.collection('user').snapshots();
    List<String> creatorList = [];
    creatorList.add(widget.creator);

    Future<void> updateAdmins() async {
      return FirebaseFirestore.instance
          .collection('teams')
          .doc(widget.teamID)
          .update({'admins': widget.admins})
          .then((value) => print("Admins updated"))
          .catchError((error) => print("Failed to update admins: $error"));
    }

    Future<void> updateMember() async {
      return FirebaseFirestore.instance
          .collection('teams')
          .doc(widget.teamID)
          .update({'member': widget.member})
          .then((value) => print("Member updated"))
          .catchError((error) => print("Failed to update member: $error"));
    }

    return MyWillPopScope(
        text: 'Zur Teams-Übersicht zurückkehren?',
        destination: '/teams',
        child: Scaffold(
      appBar: AppBar(title: const Text('Team verwalten')
          , leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/teams');
          })),
      body: SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.teamName, style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Creator", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                StreamBuilder(
                    stream: snapshots,
                    builder:
                        (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      return new ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: getUsers(snapshot, context, creatorList),
                      );
                    }
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Admins", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                StreamBuilder(
                    stream: snapshots,
                    builder:
                        (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (widget.admins.isEmpty)
                        return Container(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text("Es gibt in diesem Team keine Admins", textAlign: TextAlign.center, style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic
                            ),),
                          ),
                        );
                      return new ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: getUsers(snapshot, context, widget.admins),
                      );
                    }
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Member", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                StreamBuilder(
                    stream: snapshots,
                    builder:
                        (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (widget.member.isEmpty)
                        return Container(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text("Es gibt in diesem Team keine Member", textAlign: TextAlign.center, style: TextStyle(
                                color: Colors.grey, fontStyle: FontStyle.italic
                            ),),
                          ),
                        );
                      return new ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: getUsers(snapshot, context, widget.member),
                      );
                    }
                ),
                    new Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: Visibility(
                        visible: changed,
                        child: Container(
                          width: 370,
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                  shadowColor: MaterialStateProperty.all(
                                      Colors.transparent)),
                              onPressed: () {
                                updateAdmins();
                                updateMember();
                                setState(() {
                                  changed = false;
                                  changeList.clear();
                                });
                                final snackBar =
                                    SnackBar(content: Text('Team angepasst.'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                              child: Text("Speichern")),
                        ),
                      ),
                    )
                  ],
                )),
          ),
          bottomNavigationBar: NavigationBar(0),
        ));
  }

  getUsers(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context, List list) {
    return snapshot.data!.docs.where((DocumentSnapshot documentSnapshot) => list.contains(documentSnapshot['uid']))
        .map((doc) => Card(
        child: ListTile(
          leading: Icon(Icons.account_circle_outlined, size: 45,color: Color(0xffFB9C26)),
          title: new Text(doc['name'], style: TextStyle(fontSize: 17)),
          subtitle: new Text('Level ' + doc['level'].toString()),
          trailing: Icon((doc['uid'] == widget.creator) ? Icons.star : (widget.admins.contains(doc['uid'])) ? Icons.star_half_rounded : Icons.star_border, color: Color(0xffFB9C26)),
          dense: true,
          onTap: () {
            setState(() {
              if (doc['uid'] != widget.creator) {
                if (!widget.admins.contains(doc['uid'])
                ){
                  widget.admins.add(doc['uid']);
                  widget.member.remove(doc['uid']);
                } else {
                  widget.member.add(doc['uid']);
                  widget.admins.remove(doc['uid']);
                }

                if (changeList.contains(doc['uid']))
                  changeList.remove(doc['uid']);
                else
                  changeList.add(doc['uid']);

                if (changeList.isEmpty)
                  changed = false;
                else
                  changed = true;
              }
            });
          },
        )))
        .toList();
  }
}