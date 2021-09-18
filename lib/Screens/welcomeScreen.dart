import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {

    return WillPopScope(
        onWillPop: () async {
          bool willLeave = false;
          // show the confirm dialog
          await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Are you sure want to leave?'),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        willLeave = false;
                        SystemNavigator.pop(); // might not work with iOS
                      },
                      child: Text('Yes')),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('No'))
                ],
              ));
          return willLeave;
        },child: Scaffold(
        appBar: AppBar(title: const Text('Welcome')),
        body: Center(
            child: Column(
              children: [
                ElevatedButton(onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                }, child: Text("Registrieren")),
                ElevatedButton(onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                }, child: Text("Login"))
              ],
            )
        )));
  }
}