import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/level/methods.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}



class _MyDrawerState extends State<MyDrawer> {
  Color lightOrange = Color(0xffFB9C26);
  var placeholder =
      "https://firebasestorage.googleapis.com/v0/b/teamrad-41db5.appspot.com/o/rettich.png?alt=media&token=8c7277fe-f352-4757-8038-70b008b55d77";

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: Column(
        children: [
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
                      Container(
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
                      ),
                      Padding(padding: EdgeInsets.all(3)),
                      Methods(mode: 'name'),
                      Padding(padding: EdgeInsets.all(2)),
                      Methods(mode: 'identifier'),
                      Padding(padding: EdgeInsets.all(2)),
                      Row(children: [Text('Level: '), Methods(mode: 'level.s')])
                    ],
                  ),
                ),
              )),
          Expanded(
              child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
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
              ListTile(
                leading: Icon(Icons.note_alt_outlined, color: lightOrange),
                title: const Text('Aufgaben'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/tasks');
                },
              ),
              ListTile(
                leading: Icon(Icons.emoji_events_outlined, color: lightOrange),
                title: const Text('Herausforderungen'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/challenges');
                },
              ),
              ListTile(
                leading: Icon(Icons.leaderboard_outlined, color: lightOrange),
                title: const Text('Bestenlisten'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/leaderboards');
                },
              ),
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
          ListTile(
            leading: Icon(Icons.settings_outlined, color: lightOrange),
            title: const Text('Einstellungen'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: lightOrange),
            title: const Text('Hilfe'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/help');
            },
          ),
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
