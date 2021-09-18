import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

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
        appBar: AppBar(title: const Text('Provisorischer Login')),
        body: Center(
            child: Column(
          children: [
            TextField(controller: emailController,),
            TextField(obscureText: true, controller: passwordController,),
            ElevatedButton(onPressed: () {
              Navigator.pushReplacementNamed(context, '/register');
            }, child: Text("Registrieren")),
            ElevatedButton(onPressed: () async {
              await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
              Navigator.pushReplacementNamed(context, '/homepage');
            }, child: Text("Login"))
    ],
    )
    )));
  }
}