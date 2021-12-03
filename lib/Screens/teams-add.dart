import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';
import 'package:uuid/uuid.dart';

class addTeam extends StatefulWidget {
  const addTeam({Key? key}) : super(key: key);

  @override
  _addTeamState createState() => _addTeamState();
}

class _addTeamState extends State<addTeam> {
  TextEditingController editingController = TextEditingController();
  List<dynamic> toAddList = [];
  List<dynamic> uidList = [];
  List<dynamic> memberList = [];

  // get UserID
  String getUid() {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    return uid.toString();
  }

  // getter List
  getList(List<dynamic> list) {
    return list;
  }

  // getter QueryList
  getQueryList(List<dynamic> list) {
    list.add(getUid());
    return list;
  }
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // get database snapshot
    var snapshots = FirebaseFirestore.instance
        .collection('user')
        .where('uid', isNotEqualTo: getUid())
        .snapshots();

    CollectionReference teams = FirebaseFirestore.instance.collection('teams');
    var uuid = Uuid().v4();

    // save team data to database with uid as doc key
    // remove creator from userList but keep in queryList
    Future<void> addTeam() async {
      memberList = uidList;
      memberList.remove(getUid());
      return teams.doc(uuid)
          .set({
        'name': nameController.text,
        'member': getList(memberList),
        'creator': getUid(),
        'queryOperator': getQueryList(uidList),
        'admins': <String>[],
        'tasks': <dynamic>[],
        'challenges': <dynamic>[],
        'id': uuid,
      })
          .then((value) => print("Team Added"))
          .catchError((error) => print("Failed to add team"));
    }

    return MyWillPopScope(
        text: 'Zur Teams-Übersicht zurückkehren?',
        destination: '/teams',
        child: Scaffold(
          appBar: MyAppbar(title: 'Team erstellen', leading: true),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              shrinkWrap: true,
              children: [
            Padding(padding: EdgeInsets.all(10)),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextFormField(
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    labelStyle: TextStyle(color: Color(0xffFB9C26)),
                    labelText: 'Name *'),
                controller: nameController,
              ),
            ),
            if(toAddList.isNotEmpty) SizedBox(
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
                      margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                      height: 10,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius:
                          BorderRadius.all(Radius.circular(25)),
                          border:  Border.all(color: Colors.white, width: 0)),
                      child: Center(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(right: 4.0),
                                  child: Icon(
                                    Icons.remove_circle_outline,
                                    size: 17,
                                  ),
                                ),
                                Text(toAddList[index]),
                              ],
                            )),
                      )),
                ),
              ),
            ),
            Text(
              'User hinzufügen',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  leadingDistribution: TextLeadingDistribution.even,
                  height: 2.5),
            ),
            TextField(
              onChanged: (value) {
                setState(() {});
              },
              controller: editingController,
              decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 0.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 0.0),
                  ),
                  labelText: "Suche",
                  labelStyle: TextStyle(color: Color(0xffFB9C26)),
                  hintText: "Username",
                  prefixIcon: Icon(Icons.search, color: Color(0xffFB9C26))),
            ),
            Padding(padding: EdgeInsets.all(5)),
            StreamBuilder(
                stream: snapshots,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return Container(
                        alignment: Alignment.center,
                        child: GradientCircularProgressIndicator(
                            value: null,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: <Color>[
                                Color(0xffE53147),
                                Color(0xffFB9C26)
                              ],
                              // red to yellow
                              tileMode: TileMode
                                  .repeated, // repeats the gradient over the canvas
                            )));
                  return new ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: getUsers(snapshot, context),
                  );
                }),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            Container(
                width: 300,
                height: 50,
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
                child: ElevatedButton(
                    onPressed: () {
                      addTeam();
                      Navigator.pushReplacementNamed(context, '/teams');
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                        shadowColor:
                            MaterialStateProperty.all(Colors.transparent)),
                    child: Text('Team erstellen')))
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(0),
        ));
  }

  // iterate through database snapshot
  // return users as Card-ListTiles with logic to move between lists (with setState)
  getUsers(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    return snapshot.data!.docs
        .map((doc) => Visibility(
          visible: !(uidList.contains(doc['uid']) || !doc['name'].toString().contains(editingController.text)),
          child: Card(
                  child: ListTile(
                leading: Ink(
                    height: 40,
                    width: 40,
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.all(Radius.circular(50)),
                        border: Border.all(
                            width: 0.5, color: Colors.white)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          (doc['imgUrl'] == "") ? 'https://firebasestorage.googleapis.com/v0/b/teamrad-41db5.appspot.com/o/profilePictures%2Frettichplaceholder.png?alt=media&token=f4fdc841-5c28-486a-848d-fde5fb64c21e' : doc['imgUrl'],
                          fit: BoxFit.fill,
                        )),
                  ),
                title: new Text(
                  doc['name'],
                  style: TextStyle(fontSize: 17),
                ),
                subtitle: new Text('Level ' + doc['level'].toString()),
                trailing: Icon(Icons.add, color: Color(0xffFB9C26)),
                dense: true,
                onTap: () {
                  setState(() {
                    if (toAddList.contains(doc['name'])) {
                      toAddList.remove(doc['name']);
                      uidList.remove(doc['uid']);
                    } else {
                      toAddList.add(doc['name']);
                      uidList.add(doc['uid']);
                    }
                  });
                },
              )),
        ))
        .toList();
  }
}
