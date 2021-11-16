import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/Screens/teams-detail.dart';


class Teams extends StatelessWidget {
  const Teams({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {

    String getUid() {
      final User? user = FirebaseAuth.instance.currentUser;
      final uid = user!.uid;
      return uid.toString();
    }

    var snapshots = FirebaseFirestore.instance.collection('teams').where('queryOperator', arrayContains: getUid()).snapshots();

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
        },child: Scaffold(
        appBar: MyAppbar(title: 'Teams', leading: false, actions: false, bottom: false,),
        drawer: MyDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: snapshots,
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return new Text("Du bist im moment in keinem Team.");
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
            child: const Icon(Icons.add),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(0),
    ));
  }

  getTeams(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    return snapshot.data!.docs
        .map((doc) => Card(
      child: ListTile(
        title: new Text(doc['name']),
        subtitle: new Text((doc['member'].length + doc['admins'].length + 1).toString() + ' Mitglieder'),
        leading: Icon(Icons.theater_comedy, size: 40, color: Color(0xffFB9C26)),
        trailing: Icon(Icons.arrow_forward, color: Color(0xffFB9C26)),
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
              )));
        },
      ),
    )).toList();
  }
}