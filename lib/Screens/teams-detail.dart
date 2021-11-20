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

    return MyWillPopScope(
        text: 'Zur Teams-Übersicht zurückkehren?',
        destination: '/teams',
        child: Scaffold(
      appBar: AppBar(title: const Text('Team verwalten')
          , leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/teams');
          })),
      body: Container(
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
                    if (!snapshot.hasData)
                      return new Text("Du kennst leider keine User");
                    return new ListView(
                      shrinkWrap: true,
                      children: getUsers(snapshot, context, widget.member),
                    );
                  }
              ),
            ],
          )
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
              }
            );
          },
        )))
        .toList();
  }

  promoteUser(){

  }
}