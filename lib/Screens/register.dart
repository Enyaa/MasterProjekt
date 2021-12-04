import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:master_projekt/navigation/willpopscope.dart';
import 'package:uuid/uuid.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    int xp = 0;
    int level = 1;
    // if you change init pointsNeeded you may also want to change it in calculateLevel.dart
    int pointsNeeded = 1500;
    int pointsNeededBevor = 0;
    int finishedTaskCount = 0;
    int finishedChallengesCount = 0;
    List<dynamic> finishedChallenges = [];

    CollectionReference users = FirebaseFirestore.instance.collection('user');

    // get UserID
    Future<void> addUser() async {
      var uuid = Uuid();
      String identifier = nameController.text + '#' + uuid.v4().substring(0, 4);

      // save user data in database with uid as doc key
      return users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
            'email': emailController.text,
            'name': nameController.text,
            'identifier': identifier,
            'xp': xp,
            'pointsNeeded': pointsNeeded,
            'pointsNeededBevor': pointsNeededBevor,
            'level': level,
            'finishedTasksCount': finishedTaskCount,
            'finishedChallengesCount': finishedChallengesCount,
            'finishedChallenges': finishedChallenges,
            'uid': FirebaseAuth.instance.currentUser!.uid,
            'imgUrl': '',
            'activeTeam': ''
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user"));
    }

    return MyWillPopScope(
        text: 'App verlassen?',
        close: true,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    // 10% of the width, so there are ten blinds.
                    colors: <Color>[Color(0xffE53147), Color(0xffFB9C26)],
                    // red to yellow
                    tileMode:
                        TileMode.repeated, // repeats the gradient over the canvas
                  ),
                ),
                child: Form(
                  key: _key,
                  child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/Graphics/rettichShadow.png',
                      height: 350,
                      width: 350,
                    ),
                    TextFormField(
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        icon: Icon(Icons.email, color: Colors.white),
                        hintText: 'Email *',
                        fillColor: Color(0xff393939),
                        filled: true,
                        border: InputBorder.none,
                      ),
                      controller: emailController,
                      validator: validateEmail,
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    TextFormField(
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        icon: Icon(Icons.password, color: Colors.white),
                        hintText: 'Passwort *',
                        fillColor: Color(0xff393939),
                        filled: true,
                        border: InputBorder.none,
                      ),
                      obscureText: true,
                      controller: passwordController,
                      validator: validatePassword,
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    TextFormField(
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        icon: Icon(Icons.person, color: Colors.white),
                        hintText: 'Anzeigename *',
                        fillColor: Color(0xff393939),
                        filled: true,
                        border: InputBorder.none,
                      ),
                      controller: nameController,
                      validator: validateName,
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    Container(
                      height: 50,
                      width: 300,
                      child: OutlinedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.transparent),
                              shadowColor: MaterialStateProperty.all(
                                  Colors.transparent)),
                          onPressed: () async {
                            if (_key.currentState!.validate()) {
                              // try creating user with e-mail and password
                              try {
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                        email: emailController.text,
                                        password: passwordController.text);
                              } catch (signUpError) {
                                if (signUpError is PlatformException) {
                                  if (signUpError.code ==
                                      'ERROR_EMAIL_ALREADY_IN_USE') {
                                    final snackBar = SnackBar(
                                        content: Text(
                                            'Es existiert bereits ein Account mit dieser Adresse.'));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                }
                              }
                              print(FirebaseAuth.instance.currentUser!.uid);
                              addUser();
                              //set first Achievemebnt ->Welcome to TeamRad
                              setFirstAchievement( FirebaseAuth.instance.currentUser!.uid);
                              // send email verification
                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null && !user.emailVerified) {
                                await user.sendEmailVerification();
                              }
                              Navigator.pushReplacementNamed(
                                  context, '/homepage');
                            }
                          },
                          child: Text("Registrieren")),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          "Ich habe bereits ein Konto",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                )),
                  ),
                ),
              ),
            ));
  }


}

void setFirstAchievement(String uid) {
var achievements = FirebaseFirestore.instance.collection('achievements');
  achievements.doc('level01').update({
    'userFinished': FieldValue.arrayUnion([uid])
  });
}
// check email form
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

  if (formPassword.length < 6) return 'Das Passwort muss mind. 6 Zeichen haben';

  return null;
}

// check name form
String? validateName(String? formName) {
  if (formName == null || formName.isEmpty) return 'Bitte gib einen Namen ein.';

  if (formName.length < 2) return 'Das Name muss mind. 2 Zeichen haben';

  return null;
}
