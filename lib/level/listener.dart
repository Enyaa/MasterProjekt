import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//Todo Listenerfile

String getUid() {
  return FirebaseAuth.instance.currentUser!.uid.toString();
}

startListenerForLevelUp() {

  FirebaseFirestore.instance
      .collection("user")
      .where("uid", isEqualTo: getUid())
      .snapshots()
      .listen((result) async {
         result.docs.forEach((user) async {

      var currentXp = await user.data()['xp'];
      var pointsNeeded = await user.data()['pointsNeeded'];
      var level = await user.data()['level'];

      print(user.data()['level'].toString() +
          ' ' +
          user.data()['xp'].toString() +
          ' ' +
          user.data()['pointsNeeded'].toString());

      if (currentXp >= pointsNeeded) await doLevelUp(level);

      return;
    });
  });
}

doLevelUp(int level) async {
  print('level Up');

   FirebaseFirestore.instance
      .collection('user')
      .doc(getUid())
      .update({'level': FieldValue.increment(1)});

   FirebaseFirestore.instance
      .collection('user')
      .doc(getUid())
      .update({'pointsNeeded': ++level * 1000});

  return;
}
