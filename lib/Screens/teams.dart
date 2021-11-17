import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        appBar: AppBar(title: const Text('Teams')),
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
          Navigator.pushReplacementNamed(context, '/addTeam');
        },
        child: const Icon(Icons.add_circle),
        backgroundColor: Colors.deepOrange,
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
        leading: Icon(Icons.theater_comedy, size: 40,),
        trailing: Icon(Icons.arrow_forward),
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