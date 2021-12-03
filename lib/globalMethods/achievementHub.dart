import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementHub {
  var achievements = FirebaseFirestore.instance.collection('achievements');
  var creationDate = FirebaseAuth.instance.currentUser!.metadata.creationTime;

  final dateNow = DateTime.now();
  final createDate = FirebaseAuth.instance.currentUser!.metadata.creationTime;

  String getUid() {
    return FirebaseAuth.instance.currentUser!.uid.toString();
  }

  checkAchievement(DocumentReference user) async {
    var level;
    var finishedTasksCount;
    final daysSinceCreation = dateNow.difference(createDate!).inDays;

    await user.get().then((value) => {
          level = value['level'],
          finishedTasksCount = value['finishedTasksCount'],
        });

    if (level >= 5) {
      switch (level) {
        case 5:
          achievements.doc('level05').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 15:
          achievements.doc('level10').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 15:
          achievements.doc('level15').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 20:
          achievements.doc('level20').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 25:
          achievements.doc('level25').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
      }
    }
    if (daysSinceCreation >= 31) {
      switch (daysSinceCreation) {
        case 31:
          achievements.doc('useTime1M').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 90:
          achievements.doc('useTime3M').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 182:
          achievements.doc('useTime6M').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 365:
          achievements.doc('useTime1J').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
      }
    }
    if (finishedTasksCount >= 1) {
      switch (finishedTasksCount) {
        case 1:
          achievements.doc('createTask1').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 25:
          achievements.doc('createTask25').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 50:
          achievements.doc('createTask50').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 100:
          achievements.doc('createTask100').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
      }
    }
  }
}
