
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String getUid() {
  return FirebaseAuth.instance.currentUser!.uid.toString();
}

doLevelUp(int level) {
  print('level Up');

  FirebaseFirestore.instance
      .collection('user')
      .doc(getUid())
      .update({'level': FieldValue.increment(1)});

  FirebaseFirestore.instance
      .collection('user')
      .doc(getUid())
      .update({'pointsNeeded': ++level * 1000});
}

startListenerForLevelUp() {
  FirebaseFirestore.instance
      .collection("user")
      .where("uid", isEqualTo: getUid())
      .snapshots()
      .listen((result) {
    result.docs.forEach((user) async {
      var level = user.data()['level'];
      var pointsNeeded = user.data()['pointsNeeded'];
      var currentXp = user.data()['xp'];

      if (currentXp >= pointsNeeded) await doLevelUp(level);
      else return;
    });
  });
}
