import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Password extends StatelessWidget {
  const Password({Key? key}) : super(key: key);


  @override
  Widget build (BuildContext context) {
    final emailController = TextEditingController();


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
        appBar: AppBar(title: const Text('Passwort vergessen')),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Wenn du dein Passwort vergessen hast, kannst du hier ein neues Passwort beantragen indem du deine Mailadresse angibst!"),
                TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Email *'
                  ),
                  controller: emailController,
                  validator: validateEmail,
                ),
                ElevatedButton(onPressed: () {
                  passwordReset(emailController.text);
                  Navigator.pushReplacementNamed(context, '/login');
                }, child: Text("Passwort beantragen"))
              ],
            )
        )));
  }
}

String? validateEmail(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty)
    return 'Bitte gib eine E-Mail an.';

  String pattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail)) return 'Keine gültige Mailadresse!';

  return null;
}

Future<void> passwordReset(String formEmail) async {
  await FirebaseAuth.instance.sendPasswordResetEmail(email: formEmail);
      }

