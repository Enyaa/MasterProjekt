import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/globalMethods/methods.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  Color lightOrange = Color(0xffFB9C26);
  var placeholder =
      "https://firebasestorage.googleapis.com/v0/b/teamrad-41db5.appspot.com/o/rettich.png?alt=media&token=8c7277fe-f352-4757-8038-70b008b55d77";
  final users = FirebaseFirestore.instance.collection('user').snapshots();

  // get user id of current logged in user
  String getUid() {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: Column(
        children: [
          // user image that leads to profile
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/profil');
              },
              child: DrawerHeader(
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      StreamBuilder(
                          stream: users,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            // show image if user has one
                            if (snapshot.hasData &&
                                snapshot.data!.docs.firstWhere((user) =>
                                        user['uid'] == getUid())['imgUrl'] !=
                                    '') {
                              String imgUrl = snapshot.data!.docs.firstWhere(
                                  (user) => user['uid'] == getUid())['imgUrl'];
                              return Padding(
                                  padding: EdgeInsets.all(3),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black,
                                                blurRadius: 5,
                                                spreadRadius: 0.5)
                                          ],
                                          gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              // 10% of the width, so there are ten blinds.
                                              colors: <Color>[
                                                Color(0xffE53147),
                                                Color(0xffFB9C26)
                                              ],
                                              // red to yellow
                                              tileMode: TileMode.repeated),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Padding(
                                          padding: EdgeInsets.all(3),
                                          child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.network(imgUrl,
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.fill)))));
                            } else { // show placeholder if user has no image
                              return Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 5,
                                        spreadRadius: 0.5)
                                  ],
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
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Padding(
                                    padding: EdgeInsets.all(3),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(50)),
                                        child: Image.network(placeholder,
                                            height: 60,
                                            width: 60,
                                            fit: BoxFit.fitHeight))),
                              );
                            }
                          }),
                      Padding(padding: EdgeInsets.all(3)),
                      // show user name
                      Methods(mode: 'name'),
                      Padding(padding: EdgeInsets.all(2)),
                      // show user identifier
                      Methods(mode: 'identifier'),
                      Padding(padding: EdgeInsets.all(2)),
                      // show user level
                      Row(children: [Text('Level: '), Methods(mode: 'level.s')])
                    ],
                  ),
                ),
              )),
          Expanded(
              child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Go to Homepage
              ListTile(
                leading: Icon(Icons.home_outlined, color: lightOrange),
                title: const Text(
                  'Startseite',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/homepage');
                },
              ),
              // Go to tasks page
              ListTile(
                leading: Icon(Icons.note_alt_outlined, color: lightOrange),
                title: const Text('Aufgaben'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/tasks');
                },
              ),
              // Go to challenges page
              ListTile(
                leading: Icon(Icons.emoji_events_outlined, color: lightOrange),
                title: const Text('Herausforderungen'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/challenges');
                },
              ),
              // Go to leaderboards
              ListTile(
                leading: Icon(Icons.leaderboard_outlined, color: lightOrange),
                title: const Text('Bestenlisten'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/leaderboards');
                },
              ),
              // Go to teams page
              ListTile(
                leading: Icon(Icons.group_outlined, color: lightOrange),
                title: const Text('Teams'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/teams');
                },
              ),
            ],
          )),
          Divider(),
          // Go to settings
          ListTile(
            leading: Icon(Icons.settings_outlined, color: lightOrange),
            title: const Text('Einstellungen'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
          // Go to help page
          ListTile(
            leading: Icon(Icons.help_outline, color: lightOrange),
            title: const Text('Hilfe'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/help');
            },
          ),
          // User logout
          ListTile(
            leading: Icon(Icons.input_outlined, color: lightOrange),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              FirebaseAuth.instance.authStateChanges().listen((User? user) {
                if (user == null) {
                  print('User is currently signed out!');
                } else {
                  print('User is signed in!');
                }
              });
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
    );
  }
}
