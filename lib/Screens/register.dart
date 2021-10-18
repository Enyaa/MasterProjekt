import 'package:cloud_firestore/cloud_firestore.dart';
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
    final nameController = TextEditingController();
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    int xp = 0;
    int level = 1;
    int finishedTaskCount = 0;

    CollectionReference users = FirebaseFirestore.instance.collection('user');

    Future<void> addUser() async {
      return users.doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'email': emailController.text,
        'name': nameController.text,
        'xp': xp,
        'level': level,
        'finishedTaskCount': finishedTaskCount,
        'uid': FirebaseAuth.instance.currentUser!.uid,
      })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user"));
    }

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
                      key: _key,
                      child: Text('No'))
                ],
              ));
          return willLeave;
        },child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _key,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: 'Anzeigename *',
                        ),
                        controller: nameController,
                        validator: validateName,
                      ),
                      Text('Hier noch Bild upload hin?', textAlign: TextAlign.center),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: ElevatedButton(onPressed: () async {
                          if (_key.currentState!.validate()){
                            await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
                            print(FirebaseAuth.instance.currentUser!.uid);
                            addUser();
                            User? user = FirebaseAuth.instance.currentUser;
                            if (user != null && !user.emailVerified) {
                              await user.sendEmailVerification();
                            }
                            Navigator.pushReplacementNamed(context, '/homepage');
                          }
                        }, child: Text("Registrieren")),
                      ),
                      TextButton( onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      }, child: Text("Ich habe bereits ein Konto"))
                    ],
                  )
              ),
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


String? validateName(String? formName) {
  if (formName == null || formName.isEmpty)
    return 'Bitte gib einen Namen ein.';

  if (formName.length < 2)
    return 'Das Name muss mind. 2 Zeichen haben';

  return null;
}