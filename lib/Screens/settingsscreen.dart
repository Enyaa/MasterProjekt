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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final users = FirebaseFirestore.instance.collection('user').snapshots();
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Profilbild
  String? imgUrl = '';
  var progress = 0.0;
  bool finished = false;

  //Controller
  late TextEditingController nameController;
  late TextEditingController oldPasswordController;
  late TextEditingController passwordController;
  late TextEditingController passwordCheckController;
  late TextEditingController emailController;
  late TextEditingController emailPasswordController;

  List<bool> _isExpanded = List.generate(3, (index) => false);

  String getUid() {
    final User? user = auth.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  Future<void> saveImg(imgUrl) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(getUid())
        .update({'imgUrl': imgUrl})
        .then((value) => print("Image added"))
        .catchError((error) => print("Failed to add image: $error"));
  }

  getCurrentUrl() {
    var document = FirebaseFirestore.instance.collection('user').doc(getUid());
    String imgUrl = '';
    document.get().then((value) => imgUrl = value['imgUrl']);
    print(imgUrl);
    return imgUrl;
  }

  getCurrentName() {
    var document = FirebaseFirestore.instance.collection('user').doc(getUid());
    String imgUrl = '';
    document.get().then((value) => imgUrl = value['imgUrl']);
    return imgUrl;
  }

  _imgFromGallery() async {
    final storage = FirebaseStorage.instance;
    final picker = ImagePicker();
    var image;

    image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      var file = File(image.path);
      UploadTask task =
      storage.ref().child('profilePictures/' + getUid()).putFile(file);

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
      var downloadUrl = await (await task).ref.getDownloadURL();
      saveImg(downloadUrl);
      setState(() {
        imgUrl = getCurrentUrl();
      });
    }
  }

  Future<void> _saveName(String name) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(getUid())
        .update({'name': name})
        .then((value) => print("Name changed."))
        .catchError((error) => print("Failed change name: $error"));
  }

  _nameChanged(String name) {
    _saveName(name);
    final snackBar = SnackBar(content: Text('Name wurde geändert!'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _savePassword(String oldPassword, String newPassword,
      String newPasswordCheck) {
    if (newPassword == newPasswordCheck) {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
          email: user!.email.toString(), password: oldPassword);

      user.reauthenticateWithCredential(cred).then((value) {
        user.updatePassword(newPassword).then((_) {
          // success do something
          print('password changed!');
          final snackBar = SnackBar(content: Text('Passwort wurde geändert!'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          oldPasswordController.clear();
          passwordController.clear();
          passwordCheckController.clear();
        }).catchError((error) {
          // error show something
          print('Password could not be changed 1.');
          final snackBar =
          SnackBar(content: Text('Passwort konnte nicht geändert werden.'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      }).catchError((error) {
        // error do something
        print('Current password was not correct.');
        final snackBar =
        SnackBar(content: Text('Das aktuelle Passwort ist nicht korrekt.'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      final snackBar =
      SnackBar(content: Text('Die Passwörter stimmen nicht überein.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> saveEmail(String email) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(getUid())
        .update({'email': email})
        .then((value) => print("Email updated"))
        .catchError((error) => print("Failed to update email: $error"));
  }

  _changeEmail(String newEmail, String password) {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
        email: user!.email.toString(), password: password);

    user.reauthenticateWithCredential(cred).then((value) {
      user.updateEmail(newEmail).then((_) {
        // success do something
        print('email changed!');
        final snackBar = SnackBar(content: Text('Email wurde geändert!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        saveEmail(newEmail);
        emailController.clear();
        emailPasswordController.clear();
      }).catchError((error) {
        // error show something
        print('Email could not be changed.');
        final snackBar =
        SnackBar(content: Text('Email konnte nicht geändert werden.'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }).catchError((error) {
      // error do something
      print('Current password was not correct.');
      final snackBar =
      SnackBar(content: Text('Das Passwort ist nicht korrekt.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
}

@override
Widget build(BuildContext context) {
  getCurrentUrl();
  return WillPopScope(
      onWillPop: () async {
        bool willLeave = false;
        // show the confirm dialog
        await showDialog(
            context: context,
            builder: (_) =>
                AlertDialog(
                  title: Text('Go back to Homepage?'),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          willLeave = false;
                          Navigator.of(context).pop();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: Text('Yes')),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('No'))
                  ],
                ));
        return willLeave;
      },
      child: Scaffold(
        appBar: MyAppbar(title: 'Einstellungen'),
        drawer: MyDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: users,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return new Text("Keine Nutzerdaten gefunden.");
                  else {
                    nameController = TextEditingController(
                        text: snapshot.data!.docs.firstWhere(
                                (user) => user['uid'] == getUid())['name']);
                    oldPasswordController = TextEditingController();
                    passwordController = TextEditingController();
                    passwordCheckController = TextEditingController();
                    emailController = TextEditingController(
                        text: snapshot.data!.docs.firstWhere(
                                (user) => user['uid'] == getUid())['email']
                    );
                    emailPasswordController = TextEditingController();

                    imgUrl = snapshot.data!.docs.firstWhere(
                            (user) => user['uid'] == getUid())['imgUrl'];
                    var placeholder =
                        'https://firebasestorage.googleapis.com/v0/b/teamrad-41db5.appspot.com/o/profilePictures%2Frettichplaceholder.png?alt=media&token=f4fdc841-5c28-486a-848d-fde5fb64c21e';
                    return new Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                        ),
                        if (imgUrl != '')
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
                        ElevatedButton.icon(
                          // style: ,
                            onPressed: _imgFromGallery,
                            icon: Icon(Icons.image),
                            label: Text('Bild hochladen')),
                        LinearProgressIndicator(
                          value: progress / 100,
                          valueColor:
                          AlwaysStoppedAnimation(Colors.deepOrange),
                          backgroundColor: Colors.white,
                        ),
                        if (progress == 100) Text('Upload abgeschlossen!'),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: ExpansionPanelList(
                            expansionCallback: (int index, bool isExpanded) {
                              setState(() {
                                _isExpanded[index] = !isExpanded;
                              });
                            },
                            animationDuration: Duration(milliseconds: 1000),
                            children: [
                              ExpansionPanel(
                                headerBuilder: (context, isExpanded) {
                                  return ListTile(
                                    title: Text(
                                      'Name ändern',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                },
                                body: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(children: [
                                      Padding(padding: EdgeInsets.all(5)),
                                      TextFormField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Name ändern',
                                          labelText: 'Name *',
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.all(5)),
                                      ElevatedButton(
                                          child: Text('Speichern'),
                                          onPressed: () =>
                                              _nameChanged(
                                                  nameController.text))
                                    ])),
                                isExpanded: _isExpanded[0],
                                canTapOnHeader: true,
                              ),
                              ExpansionPanel(
                                headerBuilder: (context, isExpanded) {
                                  return ListTile(
                                    title: Text(
                                      'Email ändern',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                },
                                body: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(children: [
                                      Padding(padding: EdgeInsets.all(5)),
                                      TextFormField(
                                        controller: emailController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Email ändern',
                                          labelText: 'Email *',
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.all(5)),
                                      TextFormField(
                                        controller: emailPasswordController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Aktuelles Passwort eingeben',
                                          labelText: 'Passwort *',
                                        ),
                                        obscureText: true,
                                      ),
                                      ElevatedButton(
                                          child: Text('Speichern'),
                                          onPressed: () =>
                                              _changeEmail(emailController.text, emailPasswordController.text))
                                    ])),
                                isExpanded: _isExpanded[1],
                                canTapOnHeader: true,
                              ),
                              ExpansionPanel(
                                headerBuilder: (context, isExpanded) {
                                  return ListTile(
                                    title: Text(
                                      'Passwort ändern',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                },
                                body: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(children: [
                                      TextFormField(
                                        controller: oldPasswordController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText:
                                          'Aktuelles Passwort eingeben',
                                          labelText: 'Aktuelles Passwort',
                                        ),
                                        obscureText: true,
                                      ),
                                      Padding(padding: EdgeInsets.all(10)),
                                      TextFormField(
                                        controller: passwordController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Neues Passwort eingeben',
                                          labelText: 'Neues Passwort',
                                        ),
                                        obscureText: true,
                                      ),
                                      Padding(padding: EdgeInsets.all(10)),
                                      TextFormField(
                                        controller: passwordCheckController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Passwort wiederholen',
                                          labelText: 'Passwort wiederholen',
                                        ),
                                        obscureText: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                      ),
                                      ElevatedButton(
                                          child: Text('Speichern'),
                                          onPressed: () =>
                                              _savePassword(
                                                  oldPasswordController.text,
                                                  passwordController.text,
                                                  passwordCheckController
                                                      .text)),
                                    ])),
                                isExpanded: _isExpanded[2],
                                canTapOnHeader: true,
                              ),
                            ],
                            dividerColor: Colors.grey,
                          ),
                        ),
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
}}
