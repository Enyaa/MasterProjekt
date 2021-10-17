import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

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
        body: SingleChildScrollView(
          child: Form(
            key: _key,
            child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset('lib/Graphics/rettich.png', height: 350, width: 350,),
                      TextFormField(
                        decoration: const InputDecoration(
                            icon: Icon(Icons.email),
                            labelText: 'Email *'
                        ),
                        controller: emailController,
                        validator: validateEmail,
                      ),
                      TextFormField( decoration: const InputDecoration(
                          icon: Icon(Icons.password),
                          labelText: 'Passwort *'
                      ),
                        obscureText: true,
                        controller: passwordController,
                        validator: validatePassword,
                      ),
                      new Container(
                        margin: EdgeInsets.only(top: 20.0),
                        child: ElevatedButton(onPressed: () async {
                          if (_key.currentState!.validate()) {
                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text);
                            Navigator.pushReplacementNamed(context, '/homepage');
                          }}, child: Text("Login")),
                      ),
                      TextButton(onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      }, child: Text("Ich habe noch kein Konto"),),
                      TextButton(onPressed: () {
                        Navigator.pushReplacementNamed(context, '/password');
                      }, child: Text("Passwort vergessen?"),)
                    ],
                  ),
                )
            ),
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

