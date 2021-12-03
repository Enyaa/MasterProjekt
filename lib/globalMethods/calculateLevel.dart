import 'package:cloud_firestore/cloud_firestore.dart';

class CalculateLevel {
  //check if user has a level up and update if needed
  levelUp(DocumentReference user) async {
    var points;
    var pointsNeeded;
    var level;

    // get xp, pointsNeeded and level of user
    await user.get().then((value) => {
      points = value['xp'],
      pointsNeeded = value['pointsNeeded'],
      level = value['level']
    });

    // check if user has more points than needed
    // update points and level
    if (points >= pointsNeeded) {
      level += 1;
      pointsNeeded += level * 1500;

      user.update({'level': level, 'pointsNeeded': pointsNeeded});
    }
  }
}
