import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

checkLevel() async{
  FirebaseFirestore.instance
      .collection("user")
      .where("uid", isEqualTo: getUid())
      .snapshots()
      .listen((result) {
    result.docs.forEach((user)async {
      print('called 2');

      if (await called(await user.data()['xp'], await user.data()['pointsNeeded'])) {
        await updateLevel();
        await setPointsNeeded(user.data()['level']);
      }
    });
  });
}

called(int xp, int pointsNeeded) {
  if (xp >= pointsNeeded)
    return true;
  else
    return false;
}

setPointsNeeded(int level) async {
  await FirebaseFirestore.instance
      .collection('user')
      .doc(getUid())
      .update({'pointsNeeded': level * 1000});
}

updateLevel() async {
 await FirebaseFirestore.instance
      .collection('user')
      .doc(getUid())
      .update({'level': FieldValue.increment(1)});
}

String getUid() {
  return FirebaseAuth.instance.currentUser!.uid.toString();
}
