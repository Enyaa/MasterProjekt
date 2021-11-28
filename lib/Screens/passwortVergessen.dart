import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:master_projekt/navigation/willpopscope.dart';


class Password extends StatelessWidget {
  const Password({Key? key}) : super(key: key);


  @override
  Widget build (BuildContext context) {
    final emailController = TextEditingController();
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.all(10)),
                      IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed:() =>  Navigator.pushReplacementNamed(context, '/'),
                          alignment: Alignment.topRight
                      ),
                      Image.asset('lib/Graphics/rettich.png', height: 350, width: 350,),
                      Text("Wenn du dein Passwort vergessen hast, kannst du hier ein neues Passwort beantragen indem du deine Mailadresse angibst!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),),
                      Padding(padding: EdgeInsets.all(20)),
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
                            icon: Icon(Icons.email, color: Colors.white),
                            labelText: 'Email *'
                        ),
                        controller: emailController,
                        validator: validateEmail,
                      ),
                      Padding(padding: EdgeInsets.all(20)),
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
                            onPressed: () {
                          if (_key.currentState!.validate()){
                            passwordReset(emailController.text);
                            Navigator.pushReplacementNamed(context, '/login');
                          }}, child: Text("Passwort beantragen")),
                      )
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

Future<void> passwordReset(String formEmail) async {
  await FirebaseAuth.instance.sendPasswordResetEmail(email: formEmail);
}

