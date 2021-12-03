import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:master_projekt/navigation/willpopscope.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final GlobalKey<FormState> _key = GlobalKey<FormState>();

    return MyWillPopScope(
        text: 'App verlassen?',
        close: true,
        child: Scaffold(
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
                      Image.asset('lib/Graphics/rettich.png', height: 350, width: 350),
                    Padding(padding: EdgeInsets.all(10)),
                      TextFormField(
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                            icon: Icon(Icons.email, color: Colors.white),
                            labelText: 'Email *',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white, width: 0.0),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white, width: 0.0),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        controller: emailController,
                        validator: validateEmail,
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      TextFormField(
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            labelStyle: TextStyle(color: Colors.white),
                          icon: Icon(Icons.password, color: Colors.white,),
                          labelText: 'Passwort *'
                      ),
                        obscureText: true,
                        controller: passwordController,
                        validator: validatePassword,
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      Container(
                        width: 370,
                        height: 50,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              // 10% of the width, so there are ten blinds.
                              colors: <Color>[
                                Color(0xffE53147),
                                Color(0xffFB9C26)
                              ],
                              // red to yellow
                              tileMode: TileMode
                                  .repeated, // repeats the gradient over the canvas
                            ),
                            borderRadius:
                            BorderRadius.all(Radius.circular(50))),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.transparent)),
                            onPressed: () async {
                          if (_key.currentState!.validate()) {
                            // check input values and signIn
                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text);
                            Navigator.pushReplacementNamed(context, '/homepage');
                          }}, child: Text("Login")),
                      ),
                      TextButton(onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      }, child: Text("Ich habe noch kein Konto", style: TextStyle(color: Colors.white),),),
                      TextButton(onPressed: () {
                        Navigator.pushReplacementNamed(context, '/password');
                      }, child: Text("Passwort vergessen?", style: TextStyle(color: Colors.white)),)
                    ],
                  ),
                )
            ),
          ),
        )));
  }
}

// check e-mail form
String? validateEmail(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty)
    return 'Bitte gib eine E-Mail an.';

  String pattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail)) return 'Keine gültige Mailadresse!';

  return null;
}

// check password form
String? validatePassword(String? formPassword) {
  if (formPassword == null || formPassword.isEmpty)
    return 'Bitte gib ein Passwort an.';

  if (formPassword.length < 6)
    return 'Das Passwort muss mind. 6 Zeichen haben';

  return null;
}

