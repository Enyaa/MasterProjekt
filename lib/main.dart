import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/Screens/challenge-create.dart';
import 'package:master_projekt/Screens/login.dart';
import 'package:master_projekt/Screens/challenges.dart';
import 'package:master_projekt/Screens/help.dart';
import 'package:master_projekt/Screens/teams-detail.dart';
import 'package:master_projekt/Screens/leaderboards.dart';
import 'package:master_projekt/Screens/settingsscreen.dart';
import 'package:master_projekt/Screens/task-create.dart';
import 'package:master_projekt/Screens/tasks.dart';
import 'package:master_projekt/Screens/welcomeScreen.dart';
import 'package:master_projekt/Screens/register.dart';
import 'package:master_projekt/Screens/passwortVergessen.dart';
import 'package:master_projekt/Screens/teams.dart';
import 'package:master_projekt/Screens/addTeam.dart';
import 'Screens/homepage.dart';


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
        primarySwatch: Colors.deepOrange,
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/' : '/homepage',
      routes: {
        '/': (context) => const Welcome(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/password': (context) => const Password(),
        '/homepage': (context) => const Homepage(),
        '/teams': (context) => const Teams(),
        '/addTeam': (context) => const addTeam(),
        '/teamDetail': (context) => const TeamsDetail(teamID: '', admins: [], member: [], creator: '', teamName: '',),
        '/tasks': (context) => const Tasks(),
        '/challenges': (context) => const Challenges(),
        '/leaderboards': (context) => const Leaderboards(),
        '/settings': (context) => const SettingsScreen(),
        '/help': (context) => const Help(),
        '/task-create': (context) => const TaskCreate(),
        '/challenge-create': (context) => const ChallengeCreate()
      },
    );
  }
}