import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build (BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final GlobalKey<FormState> _key = GlobalKey<FormState>();

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
        appBar: AppBar(title: const Text('Provisorischer Register')),
        body: Form(
          key: _key,
          child: Center(
              child: Column(
                children: [
                  TextFormField(controller: emailController, validator: validateEmail,),
                  TextFormField(obscureText: true, controller: passwordController, validator: validatePassword,),
                  ElevatedButton(onPressed: () async {
                    if (_key.currentState!.validate()) {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
                    Navigator.pushReplacementNamed(context, '/homepage');
                    }
                  }, child: Text("Registrieren")),
                  ElevatedButton(onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  }, child: Text("Login"))
                ],
              )
          ),
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

String? validatePassword(String? formPassword) {
  if (formPassword == null || formPassword.isEmpty)
    return 'Bitte gib ein Passwort an.';

  if (formPassword.length < 6)
    return 'Das Passwort muss mind. 6 Zeichen haben';

  return null;
}