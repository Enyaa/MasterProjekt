import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:master_projekt/drawer.dart';
import 'package:uuid/uuid.dart';

class ChallengeCreate extends StatefulWidget {
  const ChallengeCreate({Key? key}) : super(key: key);

  @override
  _ChallengeCreateState createState() => _ChallengeCreateState();
}

class _ChallengeCreateState extends State<ChallengeCreate> {
  String? imgUrl;
  String? filename;
  var uid = Uuid().v4();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference challenges = firestore.collection('challenges');

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final xpController = TextEditingController();

    Future<void> addChallenge(title, description, xp, imgUrl) {
      initializeDateFormatting('de', null);
      return challenges
          .add({
            'title': title,
            'id': uid,
            'description': description,
            'xp': int.parse(xp),
            'finished': <String>[],
            'imgUrl': imgUrl
          })
          .then((value) => print("Challenge added"))
          .catchError((error) => print("Failed to add challenge: $error"));
    }

    _imgFromGallery() async {
      final storage = FirebaseStorage.instance;
      final picker = ImagePicker();
      var image;

      image = await picker.pickImage(source: ImageSource.gallery);
      var file = File(image.path);
      
      var snapshot = storage.ref().child(uid + '.jpg').putFile(file);
      var downloadUrl = await (await snapshot).ref.getDownloadURL();

      setState(() {
        imgUrl = downloadUrl;
      });
    }

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
            appBar: AppBar(title: const Text('Herausfoderungen')),
            drawer: MyDrawer(),
            body: Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: titleController,
                        maxLength: 20,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Titel',
                            labelText: 'Titel'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte geben Sie einen Titel an.';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 5,
                        maxLength: 200,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Beschreibung',
                            labelText: 'Beschreibung'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte geben Sie eine Beschreibung an.';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
                      TextFormField(
                        controller: xpController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Punkte',
                            labelText: 'Punkte'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte geben Sie eine Punktzahl an.';
                          }
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
                      ElevatedButton.icon(
                          onPressed: _imgFromGallery,
                          icon: Icon(Icons.image),
                          label: Text('Bild hochladen')
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
                      (imgUrl != null)
                        ? Image.network(imgUrl!)
                        : Placeholder(fallbackHeight: 200, fallbackWidth: double.infinity,),
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              addChallenge(
                                  titleController.text,
                                  descriptionController.text,
                                  xpController.text,
                                  imgUrl);
                              Navigator.pushReplacementNamed(
                                  context, '/challenges');
                            }
                          },
                          child: Text('Speichern'))
                    ],
                  ),
                ))));
  }
}
