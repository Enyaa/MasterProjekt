import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
   return new Drawer(
      child: Column (
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const DrawerHeader(child: Text('Header')),
          Expanded(child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: const Text('Startseite'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              ListTile(
                title: const Text('Aufgaben'),
                onTap:  () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/tasks');
                },
              ),
              ListTile(
                title: const Text('Herausforderungen'),
                onTap:  () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/challenges');
                },
              ),
              ListTile(
                title: const Text('Bestenlisten'),
                onTap:  () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/leaderboards');
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
            onTap: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      );
  }
}