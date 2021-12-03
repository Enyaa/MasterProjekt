import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'dart:io';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:master_projekt/navigation/willpopscope.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  // get user collection ant Authentication instance
  final users = FirebaseFirestore.instance.collection('user').snapshots();
  final FirebaseAuth auth = FirebaseAuth.instance;

  // profile picture variables
  String? imgUrl = '';
  var progress = 0.0;
  bool finished = false;

  // controllers for all form fields
  late TextEditingController nameController;
  late TextEditingController oldPasswordController;
  late TextEditingController passwordController;
  late TextEditingController passwordCheckController;
  late TextEditingController emailController;
  late TextEditingController emailPasswordController;

  // get user id of current logged in user
  String getUid() {
    final User? user = auth.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  // save img url in database
  Future<void> saveImg(imgUrl) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(getUid())
        .update({'imgUrl': imgUrl})
        .then((value) => print("Image added"))
        .catchError((error) => print("Failed to add image: $error"));
  }

  // get current img url from database
  getCurrentUrl() {
    var document = FirebaseFirestore.instance.collection('user').doc(getUid());
    String imgUrl = '';
    document.get().then((value) => imgUrl = value['imgUrl']);
    return imgUrl;
  }

  // image from gallery
  _imgFromGallery() async {
    final storage = FirebaseStorage.instance;
    final picker = ImagePicker();
    var image;

    // open image picker
    image = await picker.pickImage(source: ImageSource.gallery);

    // upload image to storage
    if (image != null) {
      var file = File(image.path);
      UploadTask task =
          storage.ref().child('profilePictures/' + getUid()).putFile(file);

      // listen to upload progress
      task.snapshotEvents.listen((event) {
        setState(() {
          progress = ((event.bytesTransferred.toDouble() /
                      event.totalBytes.toDouble()) *
                  100)
              .roundToDouble();
        });
        if (event.bytesTransferred == event.totalBytes) {
          setState(() {
            finished = true;
          });
        }
      });
      // save download url when upload is finished
      var downloadUrl = await (await task).ref.getDownloadURL();
      saveImg(downloadUrl);
      setState(() {
        imgUrl = getCurrentUrl();
      });
    }
  }

  // save new name to database
  Future<void> _saveName(String name) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(getUid())
        .update({'name': name})
        .then((value) => print("Name changed."))
        .catchError((error) => print("Failed change name: $error"));
  }

  // show snackbar that name has changed and save name
  _nameChanged(String name) {
    _saveName(name);
    final snackBar = SnackBar(content: Text('Name wurde geändert!'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // save new password to authentication
  _savePassword(
      String oldPassword, String newPassword, String newPasswordCheck) {
    if (newPassword == newPasswordCheck) {
      // check if credentials match
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
          email: user!.email.toString(), password: oldPassword);

      user.reauthenticateWithCredential(cred).then((value) {
        user.updatePassword(newPassword).then((_) {
          // success clear all form fields and show snackbar
          print('password changed!');
          final snackBar = SnackBar(content: Text('Passwort wurde geändert!'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          oldPasswordController.clear();
          passwordController.clear();
          passwordCheckController.clear();
        }).catchError((error) {
          // error  show snackbar
          print('Password could not be changed 1.');
          final snackBar =
              SnackBar(content: Text('Passwort konnte nicht geändert werden.'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      }).catchError((error) {
        // error show snackbar
        print('Current password was not correct.');
        final snackBar =
            SnackBar(content: Text('Das aktuelle Passwort ist nicht korrekt.'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else { // error passwords dont match, show snackbar
      final snackBar =
          SnackBar(content: Text('Die Passwörter stimmen nicht überein.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // save new email to database
  Future<void> saveEmail(String email) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(getUid())
        .update({'email': email})
        .then((value) => print("Email updated"))
        .catchError((error) => print("Failed to update email: $error"));
  }

  // call when email is changed
  _changeEmail(String newEmail, String password) {
    final user = FirebaseAuth.instance.currentUser;
    // check if credentials match
    final cred = EmailAuthProvider.credential(
        email: user!.email.toString(), password: password);

    user.reauthenticateWithCredential(cred).then((value) {
      user.updateEmail(newEmail).then((_) {
        // success clear form fields, save and show snackbar
        print('email changed!');
        final snackBar = SnackBar(content: Text('Email wurde geändert!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        saveEmail(newEmail);
        emailController.clear();
        emailPasswordController.clear();
      }).catchError((error) {
        // error show snackbar
        print('Email could not be changed.');
        final snackBar =
            SnackBar(content: Text('Email konnte nicht geändert werden.'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }).catchError((error) {
      // error show snackbar
      print('Current password was not correct.');
      final snackBar =
          SnackBar(content: Text('Das Passwort ist nicht korrekt.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUrl();
    return MyWillPopScope(
        text: 'Zur Homepage zurückkehren?',
        child: Scaffold(
          appBar: MyAppbar(
              title: 'Einstellungen',
              actions: false,
              bottom: false,
              leading: false),
          drawer: MyDrawer(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: users,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) // show waiting spinner while data is loading
                      return Container(
                          alignment: Alignment.center,
                          child: GradientCircularProgressIndicator(
                              value: null,
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: <Color>[
                                  Color(0xffE53147),
                                  Color(0xffFB9C26)
                                ],
                                // red to yellow
                                tileMode: TileMode
                                    .repeated, // repeats the gradient over the canvas
                              )));
                    else { // set controllers
                      nameController = TextEditingController(
                          text: snapshot.data!.docs.firstWhere(
                              (user) => user['uid'] == getUid())['name']);
                      oldPasswordController = TextEditingController();
                      passwordController = TextEditingController();
                      passwordCheckController = TextEditingController();
                      emailController = TextEditingController(
                          text: snapshot.data!.docs.firstWhere(
                              (user) => user['uid'] == getUid())['email']);
                      emailPasswordController = TextEditingController();

                      // get img url and placeholder
                      imgUrl = snapshot.data!.docs.firstWhere(
                          (user) => user['uid'] == getUid())['imgUrl'];
                      var placeholder =
                          'https://firebasestorage.googleapis.com/v0/b/teamrad-41db5.appspot.com/o/profilePictures%2Frettichplaceholder.png?alt=media&token=f4fdc841-5c28-486a-848d-fde5fb64c21e';
                      return new Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          if (imgUrl != '') // show image
                            Container(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(imgUrl!,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.fill)),
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 5,
                                      spreadRadius: 0.5)
                                ], borderRadius: BorderRadius.circular(50)))
                          else
                            Container(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(placeholder,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.fill)),
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 5,
                                      spreadRadius: 0.5)
                                ], borderRadius: BorderRadius.circular(50))),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          Container( // upload image button
                              height: 50,
                              width: 300,
                              child: OutlinedButton.icon(
                                  label: Text('Bild hochladen'),
                                  icon: Icon(Icons.image),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.transparent),
                                      shadowColor: MaterialStateProperty.all(
                                          Colors.transparent)),
                                  onPressed: _imgFromGallery)),
                          Padding(padding: EdgeInsets.all(5)),
                          // while uploading show progress indicator
                          if(progress != 0) GradientProgressIndicator(
                            value: progress / 100,
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
                          ),
                          if(progress != 0 && progress != 100) Padding(padding: EdgeInsets.all(5)),
                          // when finished show upload finished hint
                          if (progress == 100) Text('Upload abgeschlossen!'),
                          // change name form field and save button
                          Container(
                              margin: EdgeInsets.all(10),
                              child: Column(children: [
                                ExpansionTile(
                                  title: Text('Name ändern',
                                      style: TextStyle(color: Colors.white)),
                                  iconColor: Colors.white,
                                  collapsedIconColor: Colors.white,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Column(children: [
                                          Padding(padding: EdgeInsets.all(5)),
                                          TextFormField(
                                            controller: nameController,
                                            decoration: const InputDecoration(
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Color(0xffFB9C26)),
                                              hintText: 'Name ändern',
                                              labelText: 'Name *',
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.all(5)),
                                          Container(
                                              width: 300,
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
                                                      BorderRadius.all(
                                                          Radius.circular(50))),
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all(
                                                              Colors
                                                                  .transparent),
                                                      shadowColor:
                                                          MaterialStateProperty
                                                              .all(Colors
                                                                  .transparent)),
                                                  child: Text('Speichern'),
                                                  onPressed: () => _nameChanged(
                                                      nameController.text)))
                                        ])),
                                  ],
                                ),
                                // Change Email form fields and save button
                                ExpansionTile(
                                  title: Text(
                                    'Email ändern',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  iconColor: Colors.white,
                                  collapsedIconColor: Colors.white,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Column(children: [
                                          Padding(padding: EdgeInsets.all(5)),
                                          TextFormField(
                                            controller: emailController,
                                            decoration: const InputDecoration(
                                              enabledBorder:
                                              const OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              focusedBorder:
                                              const OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Color(0xffFB9C26)),
                                              hintText: 'Email ändern',
                                              labelText: 'Email *',
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.all(5)),
                                          TextFormField(
                                            controller: emailPasswordController,
                                            decoration: const InputDecoration(
                                              enabledBorder:
                                              const OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              focusedBorder:
                                              const OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Color(0xffFB9C26)),
                                              hintText:
                                                  'Aktuelles Passwort eingeben',
                                              labelText: 'Passwort *',
                                            ),
                                            obscureText: true,
                                          ),
                                          Padding(padding: EdgeInsets.all(5)),
                                          Container(
                                              width: 300,
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
                                                      BorderRadius.all(
                                                          Radius.circular(50))),
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all(
                                                              Colors
                                                                  .transparent),
                                                      shadowColor:
                                                          MaterialStateProperty.all(
                                                              Colors
                                                                  .transparent)),
                                                  child: Text('Speichern'),
                                                  onPressed: () => _changeEmail(
                                                      emailController.text,
                                                      emailPasswordController
                                                          .text)))
                                        ])),
                                  ],
                                ),
                                // change password form fields and save button
                                ExpansionTile(
                                    title: Text(
                                      'Passwort ändern',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    iconColor: Colors.white,
                                    collapsedIconColor: Colors.white,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Column(children: [
                                            TextFormField(
                                              controller: oldPasswordController,
                                              decoration: const InputDecoration(
                                                enabledBorder:
                                                const OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.white,
                                                      width: 0.0),
                                                ),
                                                focusedBorder:
                                                const OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.white,
                                                      width: 0.0),
                                                ),
                                                labelStyle: TextStyle(
                                                    color: Color(0xffFB9C26)),
                                                hintText:
                                                    'Aktuelles Passwort eingeben',
                                                labelText: 'Aktuelles Passwort',
                                              ),
                                              obscureText: true,
                                            ),
                                            Padding(
                                                padding: EdgeInsets.all(10)),
                                            TextFormField(
                                              controller: passwordController,
                                              decoration: const InputDecoration(
                                                enabledBorder:
                                                const OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.white,
                                                      width: 0.0),
                                                ),
                                                focusedBorder:
                                                const OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.white,
                                                      width: 0.0),
                                                ),
                                                labelStyle: TextStyle(
                                                    color: Color(0xffFB9C26)),
                                                hintText:
                                                    'Neues Passwort eingeben',
                                                labelText: 'Neues Passwort',
                                              ),
                                              obscureText: true,
                                            ),
                                            Padding(
                                                padding: EdgeInsets.all(10)),
                                            TextFormField(
                                              controller:
                                                  passwordCheckController,
                                              decoration: const InputDecoration(
                                                enabledBorder:
                                                const OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.white,
                                                      width: 0.0),
                                                ),
                                                focusedBorder:
                                                const OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.white,
                                                      width: 0.0),
                                                ),
                                                labelStyle: TextStyle(
                                                    color: Color(0xffFB9C26)),
                                                hintText:
                                                    'Passwort wiederholen',
                                                labelText:
                                                    'Passwort wiederholen',
                                              ),
                                              obscureText: true,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(5),
                                            ),
                                            Container(
                                              width: 300,
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
                                                      BorderRadius.all(
                                                          Radius.circular(50))),
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Colors
                                                                  .transparent),
                                                      shadowColor:
                                                          MaterialStateProperty
                                                              .all(Colors
                                                                  .transparent)),
                                                  child: Text('Speichern'),
                                                  onPressed: () => _savePassword(
                                                      oldPasswordController
                                                          .text,
                                                      passwordController.text,
                                                      passwordCheckController
                                                          .text)),
                                            )
                                          ])),
                                    ]),
                              ])),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(0),
        ));
  }
}
