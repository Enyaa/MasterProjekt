import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/Screens/teams-detail.dart';
import 'package:master_projekt/navigation/willpopscope.dart';


class Teams extends StatelessWidget {
  const Teams({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {

    // get UserID
    String getUid() {
      final User? user = FirebaseAuth.instance.currentUser;
      final uid = user!.uid;
      return uid.toString();
    }

    // define database snapshot
    var snapshots = FirebaseFirestore.instance.collection('teams').where('queryOperator', arrayContains: getUid()).snapshots();

    return MyWillPopScope(
        text: 'Zur Homepage zurückkehren?',
        child: Scaffold(
        appBar: MyAppbar(title: 'Teams', leading: false, actions: false, bottom: false,),
        drawer: MyDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: snapshots,
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          return new ListView(
            children: getTeams(snapshot, context),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTeam');
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
      bottomNavigationBar: NavigationBar(1),
    ));
  }

  // iterate through database snapshot
  // return Teams as Card-ListTiles with link to detail
  getTeams(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    return snapshot.data!.docs
        .map((doc) => Card(
      child: ListTile(
        title: new Text(doc['name']),
        subtitle: new Text((doc['member'].length + doc['admins'].length + 1).toString() + ' Mitglieder'),
        leading: Icon(Icons.theater_comedy, size: 40, color: Color(0xffFB9C26)),
        trailing: Icon(Icons.keyboard_arrow_right_outlined, color: Color(0xffFB9C26)),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamsDetail(
                    teamID: doc['id'],
                    member: doc['member'],
                    admins: doc['admins'],
                    creator: doc['creator'],
                    teamName: doc['name'],
                    tasks: doc['tasks'],
                    challenges: doc['challenges'],
                    queryOperator: doc['queryOperator']
              )));
        },
      ),
    )).toList();
  }
}