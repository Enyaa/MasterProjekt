import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  String getUid() {
    final User? user = auth.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  Future<void> saveImg(imgUrl) {
    return FirebaseFirestore.instance.collection('user')
        .doc(getUid())
        .update({
      'imgUrl': imgUrl
    })
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
      UploadTask task = storage.ref().child('profilePictures/' + getUid()).putFile(file);

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

  @override
  Widget build(BuildContext context) {
    getCurrentUrl();
    return WillPopScope(
        onWillPop: () async {
          bool willLeave = false;
          // show the confirm dialog
          await showDialog(
              context: context,
              builder: (_) => AlertDialog(
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
          appBar: AppBar(title: const Text('Einstellungen')),
          drawer: MyDrawer(),
          body: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: users,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return new Text("Keine Nutzerdaten gefunden.");
                  else {
                    final nameController = TextEditingController(
                        text: snapshot.data!.docs.firstWhere((user) => user['uid'] == getUid())['name']
                    );
                    final oldPasswordController = TextEditingController();
                    final passwordController = TextEditingController();
                    final passwordCheckController = TextEditingController();
                    imgUrl = snapshot.data!.docs.firstWhere((user) => user['uid'] == getUid())['imgUrl'];
                    return new Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                        ),
                        if(imgUrl != '') ClipRRect(borderRadius: BorderRadius.circular(50),child: Image.network(imgUrl!, height: 100, width: 100, fit: BoxFit.fill))
                        else Text('keine url'),
                        // Image.network(''),
                        Padding(
                          padding: EdgeInsets.all(10),
                        ),
                        ElevatedButton.icon(
                            onPressed: _imgFromGallery,
                            icon: Icon(Icons.image),
                            label: Text('Bild hochladen')),
                        LinearProgressIndicator(
                          value: progress / 100,
                          valueColor: AlwaysStoppedAnimation(Colors.deepOrange),
                          backgroundColor: Colors.white,
                        ),
                        if (progress == 100) Text('Upload finished!'),
                        Padding(padding: EdgeInsets.all(10)),
                        Text('Name ändern: '),
                        Padding(padding: EdgeInsets.all(10)),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Name ändern',
                            labelText: 'Name *',
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(10)),
                        Text('Passwort ändern: '),
                        Padding(padding: EdgeInsets.all(10)),
                        TextFormField(
                          controller: oldPasswordController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Aktuelles Passwort eingeben',
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
                      ],
                    );
                  }
                },
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(0),
        ));
  }
}
