import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/Screens/login.dart';
import 'package:master_projekt/Screens/challenges.dart';
import 'package:master_projekt/Screens/help.dart';
import 'package:master_projekt/Screens/homepage.dart';
import 'package:master_projekt/Screens/leaderboards.dart';
import 'package:master_projekt/Screens/settingsscreen.dart';
import 'package:master_projekt/Screens/tasks.dart';
import 'package:master_projekt/Screens/welcomeScreen.dart';
import 'package:master_projekt/Screens/register.dart';
import 'package:master_projekt/Screens/passwortVergessen.dart';
import 'package:master_projekt/Screens/teams.dart';
import 'package:master_projekt/Screens/addTeam.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late StreamSubscription<User?> user;
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
        print(FirebaseAuth.instance.currentUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamRad',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute:
      FirebaseAuth.instance.currentUser == null ? '/' : '/homepage',
      routes: {
        '/': (context) => const Welcome(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/password': (context) => const Password(),
        '/homepage': (context) => const Homepage(),
        '/teams': (context) => const Teams(),
        '/addTeam': (context) => const addTeam(),
        '/tasks': (context) => const Tasks(),
        '/challenges': (context) => const Challenges(),
        '/leaderboards': (context) => const Leaderboards(),
        '/settings': (context) => const SettingsScreen(),
        '/help': (context) => const Help(),
      },
    );
  }
}