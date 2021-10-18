import 'package:flutter/material.dart';
import 'tabspage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
         // DrawerHeader(
         //   child:
         //   new CircleAvatar(
         //     backgroundColor: Colors.grey,
         //     child: new Image.asset(
         //       'lib/Graphics/rettich.png',
         //     ), //For Image Asset

         //   ),
         // ),

          ListTile(
            leading: Icon(Icons.home),
            title: Text('Startseite'),
            onTap: () => {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TabsPage(selectedIndex: 0)),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.note_alt),
            title: Text('Aufgaben'),
            onTap: () => {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TabsPage(selectedIndex: 1)),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.emoji_events),
            title: Text('Herausforderungen'),
            onTap: () => {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TabsPage(selectedIndex: 2)),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.leaderboard),
            title: Text('Bestenliste'),
            onTap: () => {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TabsPage(selectedIndex: 2)),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Teams'),
            onTap: () => {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TabsPage(selectedIndex: 2)),
              ),
            },
          ),
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
