import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';



class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return MyWillPopScope(child: Scaffold(
      appBar: MyAppbar(title: 'Home', actions: false, bottom: false, leading: false),
      drawer: MyDrawer(),
      body: Center(child: new Text('Homepage')),
      bottomNavigationBar: NavigationBar(1),
    ),
      text: "App schließen?",
      close: true,
    );
  }
}