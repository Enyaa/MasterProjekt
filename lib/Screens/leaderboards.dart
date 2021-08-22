import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/drawer.dart';

class Leaderboards extends StatelessWidget {
  const Leaderboards({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Bestenlisten')),
        drawer: MyDrawer(),
        body: Center(child: const Text('Bestenlisten'))
    );
  }
}