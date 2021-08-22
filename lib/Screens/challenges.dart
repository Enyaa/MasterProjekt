import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/drawer.dart';

class Challenges extends StatelessWidget {
  const Challenges({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Herausforderungen')),
        drawer: MyDrawer(),
        body: Center(child: const Text('Herausforderungen'))
    );
  }
}