import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:master_projekt/Screens/teams-addUser.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';

class TeamsDetail extends StatefulWidget {
  const TeamsDetail(
      {Key? key,
      required this.teamID,
      required this.admins,
      required this.member,
      required this.creator,
      required this.teamName,
        required this.challenges,
        required this.tasks,
      required this.queryOperator})
      : super(key: key);

  final String teamID;
  final List<dynamic> admins;
  final List<dynamic> member;
  final String creator;
  final String teamName;
  final List<dynamic> tasks;
  final List<dynamic> challenges;
  final List<dynamic> queryOperator;

  @override
  _TeamsDetailState createState() => _TeamsDetailState();
}

// get userID
String getUid() {
  final User? user = FirebaseAuth.instance.currentUser;
  final uid = user!.uid;
  return uid.toString();
}

class _TeamsDetailState extends State<TeamsDetail> {
  // define gradient for buttons etc.
  final gradient =
      LinearGradient(colors: <Color>[Color(0xffE53147), Color(0xffFB9C26)]);
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<dynamic> changeList = [];
  bool changed = false;

  @override
  Widget build(BuildContext context) {
    var snapshots = FirebaseFirestore.instance.collection('user').snapshots();
    List<String> creatorList = [];
    creatorList.add(widget.creator);

    // update list of admins in database with new changes
    Future<void> updateAdmins() async {
      return FirebaseFirestore.instance
          .collection('teams')
          .doc(widget.teamID)
          .update({'admins': widget.admins})
          .then((value) => print("Admins updated"))
          .catchError((error) => print("Failed to update admins: $error"));
    }

    // update list of members in database with new changes
    Future<void> updateMember() async {
      return FirebaseFirestore.instance
          .collection('teams')
          .doc(widget.teamID)
          .update({'member': widget.member})
          .then((value) => print("Member updated"))
          .catchError((error) => print("Failed to update member: $error"));
    }

    // set current team as activeTeam in user profile
    Future<void> setTeamActive() async {
      return FirebaseFirestore.instance
          .collection('user')
          .doc(getUid())
          .update({'activeTeam': widget.teamID})
          .then((value) => print("Active Team updated"))
          .catchError((error) => print("Failed to update active Team: $error"));
    }

    // get current active team of the user
    Future<String> getActiveTeam() async {
      String activeTeam = '';
      await FirebaseFirestore.instance
          .collection('user')
          .doc(getUid())
          .get()
          .then((value) => activeTeam = value['activeTeam']);
      return activeTeam;
    }

    return MyWillPopScope(
        text: 'Zur Teams-Übersicht zurückkehren?',
        destination: '/teams',
        child: Scaffold(
          appBar: MyAppbar(title: 'Team verwalten', leading: true, admin: true, mode: 'team', doDelete: deleteTeam),
          body: SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return gradient
                                      .createShader(Offset.zero & bounds.size);
                                },
                                child: Text(widget.teamName,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24)),
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              FutureBuilder(
                                  future: getActiveTeam(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) {
                                    if (snapshot.hasData) {
                                      return Visibility(
                                        visible: (snapshot.requireData ==
                                                widget.teamID)
                                            ? false
                                            : true,
                                        child: Container(
                                          width: 100,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.orange),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.transparent),
                                                shadowColor:
                                                    MaterialStateProperty.all(
                                                        Colors.transparent),
                                              ),
                                              onPressed: () {
                                                setTeamActive();
                                                setState(() {});
                                                final snackBar = SnackBar(
                                                    content: Text("\"" +
                                                        widget.teamName +
                                                        "\"" +
                                                        ' als aktives Team eingestellt.'));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              },
                                              child: ShaderMask(
                                                  shaderCallback:
                                                      (Rect bounds) {
                                                    return gradient
                                                        .createShader(
                                                            Offset.zero &
                                                                bounds.size);
                                                  },
                                                  child: Text('Aktivieren'))),
                                        ),
                                      );
                                    }
                                    return Text('No data');
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Creator",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    StreamBuilder(
                        stream: snapshots,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          return new ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: getUsers(snapshot, context, creatorList),
                          );
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Admins",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    StreamBuilder(
                        stream: snapshots,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (widget.admins.isEmpty)
                            return Container(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: new Text(
                                  "Es gibt in diesem Team keine Admins",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            );
                          return new ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children:
                                getUsers(snapshot, context, widget.admins),
                          );
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Member",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    StreamBuilder(
                        stream: snapshots,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            if (widget.member.isEmpty)
                              return Container(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Text(
                                    "Es gibt in diesem Team keine Member",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              );
                            return new ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children:
                                  getUsers(snapshot, context, widget.member),
                            );
                          } else {
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
                          }
                        }),
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
                                // check if user is admin or creator before
                                if (widget.admins.contains(getUid()) ||
                                    widget.creator == getUid()) {
                                  updateAdmins();
                                  updateMember();
                                  setState(() {
                                    changed = false;
                                    changeList.clear();
                                  });
                                  // is admin/creator
                                  final snackBar = SnackBar(
                                      content: Text('Team angepasst.'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                } else {
                                  // is member
                                  final snackBar2 = SnackBar(
                                      content: Text(
                                          'Keine Admin rechte zur Rollenvergebung. Kontaktiere einen Admin oder Creator.'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar2);
                                }
                              },
                              child: Text("Speichern")),
                        ),
                      ),
                    )
                  ],
                )),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTeamUser(
                          teamID: widget.teamID,
                          member: widget.queryOperator
                      )));
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
          bottomNavigationBar: NavigationBar(0),
        ));
  }

  // if user is creator:
  // delete team from database with all tasks and challenges linked to the team
  // iterate through list of tasks/challenges and delete with id
  Future<void> deleteTeam() async {
    if (widget.creator == getUid()){
      for (var i = 0; i < widget.tasks.length; i++) {
        print(widget.tasks);
        FirebaseFirestore.instance
            .collection('tasks')
            .doc(widget.tasks[i])
            .delete();
      }
      for (var i = 0; i < widget.challenges.length; i++) {
        FirebaseFirestore.instance
            .collection('challenges')
            .doc(widget.challenges[i])
            .delete();
      }
      FirebaseFirestore.instance
          .collection('teams')
          .doc(widget.teamID)
          .delete();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      final snackBar = SnackBar(
          content: Text('Nur der Creator kann das Team löschen.'));
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  // return active team from snapshot
  getActiveTeam(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs.map((doc) => doc['activeTeam']);
  }

  // iterate through snapshot and create list of users (depending on input list) of the team with the fitting icon
  // functionality to assign user roles if the user is admin/creator
  getUsers(
      AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context, List list) {
    if (snapshot.data == null) {
      var waitingList = List<Widget>.generate(
          1,
          (index) => Container(
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
                  ))));
      return waitingList;
    } else {
      return snapshot.data!.docs
          .where((DocumentSnapshot documentSnapshot) =>
              list.contains(documentSnapshot['uid']))
          .map((doc) => Card(
                  child: ListTile(
                leading: Ink(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      border: Border.all(width: 0.5, color: Colors.white)),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        (doc['imgUrl'] == "")
                            ? 'https://firebasestorage.googleapis.com/v0/b/teamrad-41db5.appspot.com/o/profilePictures%2Frettichplaceholder.png?alt=media&token=f4fdc841-5c28-486a-848d-fde5fb64c21e'
                            : doc['imgUrl'],
                        fit: BoxFit.fill,
                      )),
                ),
                title: new Text(doc['name'], style: TextStyle(fontSize: 17)),
                subtitle: new Text('Level ' + doc['level'].toString()),
                trailing: Icon(
                    (doc['uid'] == widget.creator)
                        ? Icons.star
                        : (widget.admins.contains(doc['uid']))
                            ? Icons.star_half_rounded
                            : Icons.star_border,
                    color: Color(0xffFB9C26)),
                dense: true,
                onTap: () {
                  setState(() {
                    if (doc['uid'] == getUid()){
                      _showGetOut();
                    } else {
                      if (doc['uid'] != widget.creator) {
                        if (!widget.admins.contains(doc['uid'])) {
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
                    }
                  });
                },
              )))
          .toList();
    }
  }

  // leave team popup (for Admin/Member only)
  _showGetOut() {
    String question = 'Wollen sie das Team verlassen?';
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Color(0xff353535),
              title: new Text(question),
              actions: [
                Container(
                    width: 100,
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
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                            shadowColor:
                            MaterialStateProperty.all(Colors.transparent)),
                        onPressed: (){
                          if (widget.creator == getUid()) {
                            final snackBar = SnackBar(
                                content: Text('Der Creator kann das Team nicht verlassen, nur löschen.'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Navigator.of(context).pop();
                          }
                          if (widget.member.contains(getUid())) {
                            widget.member.remove(getUid());
                            final snackBar2 = SnackBar(
                                content: Text('Sie haben das Team verlassen.'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar2);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                          if (widget.admins.contains(getUid())) {
                            final snackBar3 = SnackBar(
                                content: Text('Sie haben das Team verlassen.'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar3);
                            widget.admins.remove(getUid());
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                        },
                        // might not work with iOS
                        child: Text('Ja'))),
                Container(
                    height: 50,
                    width: 100,
                    child: OutlinedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.transparent),
                            shadowColor: MaterialStateProperty.all(
                                Colors.transparent)),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Nein')))
              ]);
        });
  }
}
