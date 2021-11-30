import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';
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
  var progress = 0.0;
  bool finished = false;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final xpController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference challenges = firestore.collection('challenges');

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Future<void> addChallenge(title, description, xp, imgUrl) {
      initializeDateFormatting('de', null);
      return challenges
          .doc(uid)
          .set({
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

      if (image != null) {
        var file = File(image.path);
        UploadTask task =
            storage.ref().child('challenges/' + uid).putFile(file);

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
        setState(() {
          imgUrl = downloadUrl;
        });
      }
    }

    return MyWillPopScope(
      text: 'Zur Herausforderungen-Übersicht zurückkehren?',
        destination: '/challenges',
        child: Scaffold(
          appBar: MyAppbar(
            title: 'Herausfoderungen',
            leading: true,
          ),
          drawer: MyDrawer(),
          body: Form(
              key: _formKey,
              child: Container(
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20, right:20),
                        child: TextFormField(
                          cursorColor: Colors.white,
                          controller: titleController,
                          maxLength: 20,
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
                              labelStyle: TextStyle(color: Color(0xffFB9C26)),
                              labelText: 'Titel'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte geben Sie einen Titel an.';
                            }
                            return null;
                          },
                        )),
                    Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20, right:20),
                        child: TextFormField(
                          cursorColor: Colors.white,
                          controller: descriptionController,
                          maxLines: 10,
                          maxLength: 500,
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
                              labelStyle: TextStyle(color: Color(0xffFB9C26)),
                              labelText: 'Beschreibung'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte geben Sie eine Beschreibung an.';
                            }
                            return null;
                          },
                        )),
                    Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20, right:20),
                        child: TextFormField(
                          cursorColor: Colors.white,
                          controller: xpController,
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
                              labelStyle: TextStyle(color: Color(0xffFB9C26)),
                              labelText: 'Punkte'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte geben Sie eine Punktzahl an.';
                            }
                          },
                        )),
                    Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    if(progress != 0 && progress != 100) Container(margin: EdgeInsets.only(bottom: 20), child: GradientProgressIndicator(
                      value: progress/100,
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
                    )),
                    Container(
                        margin: EdgeInsets.only(left: 20, right:20),
                        height: 50,
                        width: 300,
                        child: OutlinedButton.icon(
                            label: Text('Bild hochladen'),
                            icon: Icon(Icons.image),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.transparent)),
                            onPressed: _imgFromGallery)),
                    if(progress == 100) Container(margin: EdgeInsets.only(top: 10), child: Text('Upload abgeschlossen!'), alignment: Alignment.center,),
                    Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20, right:20),
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
                                BorderRadius.all(Radius.circular(50))),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.transparent)),
                            onPressed: finished
                                ? () {
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
                                  }
                                : null,
                            child: Text('Speichern')))
                  ],
                ),
              )),
          bottomNavigationBar: NavigationBar(0),
        ));
  }
}
