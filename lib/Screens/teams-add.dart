
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/navigationbar.dart';


class addTeam extends StatefulWidget {
  const addTeam({Key? key}) : super(key: key);

  @override
  _addTeamState createState() => _addTeamState();
}

class _addTeamState extends State<addTeam> {


  TextEditingController editingController = TextEditingController();
  List<dynamic> toAddList = [];
  List<dynamic> uidList = [];

  String getUid() {
      final User? user = FirebaseAuth.instance.currentUser;
      final uid = user!.uid;
    return uid.toString();
  }

  getList(List<dynamic> list){
    return list;
  }

  getQueryList(List<dynamic> list){
    list.add(getUid());
    return list;
  }

  @override
  Widget build (BuildContext context) {
    var snapshots = FirebaseFirestore.instance.collection('user').where('uid', isNotEqualTo: getUid()).snapshots();
    final nameController = TextEditingController();

    CollectionReference teams = FirebaseFirestore.instance.collection('teams');

    Future<void> addTeam() async {
      return teams
          .add({
        'name': nameController.text,
        'member': getList(uidList),
        'creator': getUid(),
        'queryOperator': getQueryList(uidList),
        'admins': <String>[],
        'mods': <String>[],
        'tasks': <dynamic>[],
        'challenges': <dynamic>[]
      })
          .then((value) => print("Team Added"))
          .catchError((error) => print("Failed to add team"));
    }

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
      appBar: MyAppbar(title: 'Team erstellen', leading: true),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Name *'),
                  controller: nameController,
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: toAddList.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        toAddList.remove(toAddList[index]);
                        uidList.remove(uidList[index]);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(7.0),
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0.5,
                            blurRadius: 0.5,
                            offset: Offset(1,1)
                          )]),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Icon(Icons.remove_circle_outline, size: 17,),
                                  ),
                                  Text(toAddList[index]),
                                ],
                              )
                        ),
                      )
                    ),
                  ),
                ),
              ),
              Text('User hinzufügen',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    leadingDistribution: TextLeadingDistribution.even, height: 2.5),
              ),
              TextField(
                onChanged: (value) {

                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Suche",
                    hintText: "Username",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
              StreamBuilder(
                stream: snapshots,
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return new Text("Du kennst leider keine User");
                  return new ListView(
                    shrinkWrap: true,
                    children: getUsers(snapshot, context),
                  );
                }
              ),
          Padding(padding: EdgeInsets.all(10),),
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
            child: ElevatedButton(onPressed: () {
                  addTeam();
                  Navigator.pushReplacementNamed(context, '/teams');
                }, style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(
                    Colors.transparent),
                shadowColor:
                MaterialStateProperty.all(
                    Colors.transparent)),
                child: Text('Team erstellen')))
            ],
          )
        ),
      ),
      bottomNavigationBar: NavigationBar(0),
    ));
  }

  getUsers(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    return snapshot.data!.docs
        .map((doc) => Card(
        child: ListTile(
          leading: Icon(Icons.account_circle_outlined, size: 45,),
          title: new Text(doc['name'], style: TextStyle(fontSize: 17),),
          subtitle: new Text('Level ' + doc['level'].toString()),
          trailing: Icon(Icons.add),
          dense: true,
          onTap: () {
            setState(() {
              if (toAddList.contains(doc['name'])){
                toAddList.remove(doc['name']);
                uidList.remove(doc['uid']);
              } else {
                toAddList.add(doc['name']);
                uidList.add(doc['uid']);
              }
            });
          },
        )))
        .toList();
  }
}

String? validateName(String? formName) {
  CollectionReference teams = FirebaseFirestore.instance.collection('teams');
  if (formName == null || formName.isEmpty)
    return 'Bitte gib einen Namen ein.';

  if (formName.length < 2)
    return 'Das Name muss mind. 2 Zeichen haben';

  return null;
}



