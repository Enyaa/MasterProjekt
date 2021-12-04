import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementHub {
  var achievements = FirebaseFirestore.instance.collection('achievements');
  var creationDate = FirebaseAuth.instance.currentUser!.metadata.creationTime;

  final dateNow = DateTime.now();
  final createDate = FirebaseAuth.instance.currentUser!.metadata.creationTime;

  // UID as String
  String getUid() {
    return FirebaseAuth.instance.currentUser!.uid.toString();
  }

  // sets Achievements and updates Firestore
  checkAchievement(DocumentReference user) async {
    var level;
    var finishedTasksCount;
    final daysSinceCreation = dateNow.difference(createDate!).inDays;

    await user.get().then((value) => {
          level = value['level'],
          finishedTasksCount = value['finishedTasksCount'],
        });
    //for Level
    if (level >= 10) {
      switch (level) {
        case 10:
          achievements.doc('level10').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 20:
          achievements.doc('level20').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
        case 30:
          achievements.doc('level30').update({
            'userFinished': FieldValue.arrayUnion([getUid()])
          });
          break;
      }
    }
    // for Time.
    if (daysSinceCreation >= 365) {
      achievements.doc('useTime1J').update({
        'userFinished': FieldValue.arrayUnion([getUid()])
      });
    } else if (daysSinceCreation >= 182) {
      achievements.doc('useTime6M').update({
        'userFinished': FieldValue.arrayUnion([getUid()])
      });
    } else if (daysSinceCreation >= 90) {
      achievements.doc('useTime3M').update({
        'userFinished': FieldValue.arrayUnion([getUid()])
      });
    } else if (daysSinceCreation >= 31) {
      achievements.doc('useTime1M').update({
        'userFinished': FieldValue.arrayUnion([getUid()])
      });
    }

    //for finished Tasks
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
