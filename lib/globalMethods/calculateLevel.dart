import 'package:cloud_firestore/cloud_firestore.dart';

class CalculateLevel {

  levelUp(DocumentReference user) async {
    var points;
    var pointsNeeded;
    var level;

    await user.get().then((value) => {
      points = value['xp'],
      pointsNeeded = value['pointsNeeded'],
      level = value['level']
    });

    if (points >= pointsNeeded) {
      level += 1;
      pointsNeeded += level * 1500;

      user.update({'level': level, 'pointsNeeded': pointsNeeded});
    }
  }
}
