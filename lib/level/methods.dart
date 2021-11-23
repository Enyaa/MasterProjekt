import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Methods extends StatefulWidget {
  const Methods({Key? key, required this.mode}) : super(key: key);
  final String mode;

  @override
  _MethodsState createState() => _MethodsState();
}

class _MethodsState extends State<Methods> {
  String getUid() {
    return FirebaseAuth.instance.currentUser!.uid.toString();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text('Error, keine Daten von User gefunden!');
          } else {
            var level = snapshot.data!.docs
                .firstWhere((user) => user['uid'] == getUid())['level'];
            var currentXp = snapshot.data!.docs
                .firstWhere((user) => user['uid'] == getUid())['xp'];
            var pointsNeeded = snapshot.data!.docs
                .firstWhere((user) => user['uid'] == getUid())['pointsNeeded'];
            //level als String
            if (widget.mode == 'level.s') {
              return Text(level.toString());
            }
            //CurrentXP als String
            else if (widget.mode == 'currentXp.s') {
              return Text(currentXp.toString());
            }
            //pointsNeeded als String
            else if (widget.mode == 'pointsNeeded.s') {
              return Text(pointsNeeded.toString());
            }
            else {
              return Text('Keine Daten gefunden!');
            }
          }
        });
  }
}
