import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/level/methods.dart';



class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super (key: key);


  @override
  _MyDrawerState createState() => _MyDrawerState();

}
class _MyDrawerState extends State<MyDrawer>{

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
              child: Column(
                children: <Widget>[
                  Methods(mode:'level.s'),
                ],
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/Graphics/rettich.png'),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
          Expanded(
              child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.home),
                title: const Text('Startseite'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/homepage');
                },
              ),
              ListTile(
                leading: Icon(Icons.note_alt),
                title: const Text('Aufgaben'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/tasks');
                },
              ),
              ListTile(
                leading: Icon(Icons.emoji_events),
                title: const Text('Herausforderungen'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/challenges');
                },
              ),
              ListTile(
                leading: Icon(Icons.leaderboard),
                title: const Text('Bestenlisten'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/leaderboards');
                },
              ),
              ListTile(
                leading: Icon(Icons.group),
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
            leading: Icon(Icons.settings),
            title: const Text('Einstellungen'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: const Text('Hilfe'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/help');
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
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


