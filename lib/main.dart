import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/Screens/challenges.dart';
import 'package:master_projekt/Screens/help.dart';
import 'package:master_projekt/Screens/homepage.dart';
import 'package:master_projekt/Screens/leaderboards.dart';
import 'package:master_projekt/Screens/settingsscreen.dart';
import 'package:master_projekt/Screens/task-create.dart';
import 'package:master_projekt/Screens/tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamRad',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Homepage(),
        '/tasks': (context) => const Tasks(),
        '/challenges': (context) => const Challenges(),
        '/leaderboards': (context) => const Leaderboards(),
        '/settings': (context) => const SettingsScreen(),
        '/help': (context) => const Help(),
        '/task-create': (context) => const TaskCreate()
      },
    );
  }
}