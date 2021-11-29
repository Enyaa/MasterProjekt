import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:master_projekt/Screens/task-detail.dart';
import 'package:master_projekt/navigation/myappbar.dart';
import 'package:master_projekt/navigation/mydrawer.dart';
import 'package:master_projekt/navigation/navigationbar.dart';
import 'package:master_projekt/navigation/willpopscope.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new HomepageState();
}

class HomepageState extends State<Homepage> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  String getUid() {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;

    return uid.toString();
  }

  getActiveTeam() async {
    var activeTeamID = '';
    var activeTeamName = '';
    var activeTeamMembers = [];
    await FirebaseFirestore.instance
        .collection('user')
        .doc(getUid())
        .get()
        .then((value) => activeTeamID = value.get('activeTeam'));
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(activeTeamID)
        .get()
        .then((value) => activeTeamName = value.get('name'));
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(activeTeamID)
        .get()
        .then((value) => activeTeamMembers = value.get('queryOperator'));
    var activeTeam = [];
    activeTeam.add(activeTeamID);
    activeTeam.add(activeTeamName);
    activeTeam.add(activeTeamMembers);
    return activeTeam;
  }

  @override
  Widget build(BuildContext context) {
    getList(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
      return snapshot.data!.docs
          .map((doc) => Card(
              child: ListTile(
                  horizontalTitleGap: 0,
                  contentPadding: EdgeInsets.zero,
                  title: Transform.translate(
                      offset: Offset(0, -4),
                      child: Container(
                          height: 50,
                          child: Container(
                              child: Text(doc['title'],
                                  style: TextStyle(fontSize: 16)),
                              alignment: Alignment.center),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5)),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: <Color>[
                                  Color(0xffE53147),
                                  Color(0xffFB9C26)
                                ], // red to yellow
                                tileMode: TileMode
                                    .repeated, // repeats the gradient over the canvas
                              )))),
                  subtitle: new Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(doc['description'])),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetail(
                            title: doc['title'],
                            description: doc['description'],
                            subTasks: doc['subtasks'],
                            xp: doc['xp'],
                            time: doc['time'],
                            id: doc.id,
                            accepted: doc['accepted'],
                            finished: doc['finished'],
                            userId: doc['user'],
                          ),
                        ));
                  })))
          .toList();
    }

    sort(List<MyUser> users) {
      users.sort((a, b) => a.xp.compareTo(b.xp));
      users = users.reversed.toList();
      users = users.sublist(0, 3);
      return users;
    }

    getTop3(AsyncSnapshot<QuerySnapshot> snapshot) {
      List<MyUser> _users = new List.empty(growable: true);
      snapshot.data!.docs.forEach((doc) {
        String name = doc['name'];
        int xp = doc['xp'];
        int finishedTasks = doc['finishedTasksCount'];
        int finishedChallenges = doc['finishedChallengesCount'];
        String image = doc['imgUrl'];

        if (image == '') {
          image =
              'https://firebasestorage.googleapis.com/v0/b/teamrad-41db5.appspot.com/o/profilePictures%2Frettichplaceholder.png?alt=media&token=f4fdc841-5c28-486a-848d-fde5fb64c21e';
        }

        MyUser _user = new MyUser(
            name: name,
            xp: xp,
            tasks: finishedTasks,
            challenges: finishedChallenges,
            image: image);
        _users.add(_user);
      });
      return sort(_users)
          .map<Widget>((user) => Row(children: [
                SizedBox(
                    height: 80,
                    width: 330,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                topLeft: Radius.circular(50))),
                        child: ListTile(
                            title: new Text(user.name),
                            leading: Ink(
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  border: Border.all(
                                      width: 0.5, color: Colors.white)),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    user.image,
                                    fit: BoxFit.fill,
                                  )),
                            ),
                            subtitle: new Text('XP: ' + user.xp.toString()),
                            onTap: () {})))
              ]))
          .toList();
    }

    return MyWillPopScope(
        text: "App schließen?",
        close: true,
        child: Scaffold(
            appBar: MyAppbar(
                title: 'Home', actions: false, bottom: false, leading: false),
            drawer: MyDrawer(),
            bottomNavigationBar: NavigationBar(2),
            body: Center(
              child: SingleChildScrollView(
                  child: Column(children: [
                SizedBox(height: 20),
                FutureBuilder(
                    future: getActiveTeam(),
                    builder: (context, snapshot) {
                      var activeTeam;
                      if (snapshot.hasData) {
                        activeTeam = snapshot.data;
                      }
                      return snapshot.hasData
                          ? StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('tasks')
                                  .where('accepted', isEqualTo: true)
                                  .where('user', isEqualTo: getUid())
                                  .where('finished', isEqualTo: false)
                                  .where('teamID', isEqualTo: activeTeam[0])
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData) {
                                  var taskList = getList(snapshot, context);
                                  return Column(children: [
                                    Container(
                                        width: 230,
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                bottom: 10),
                                            child: Row(children: [
                                              Text('Todo für Team ',
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              ShaderMask(
                                                shaderCallback: (Rect bounds) {
                                                  return LinearGradient(
                                                      colors: <Color>[
                                                        Color(0xffE53147),
                                                        Color(0xffFB9C26)
                                                      ]).createShader(
                                                      Offset.zero &
                                                          bounds.size);
                                                },
                                                child: Text(activeTeam[1],
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 24)),
                                              ),
                                            ])),
                                        alignment: Alignment.center),
                                    if(taskList.isEmpty) Text('Es gibt nichts zu tun.'),
                                    if(taskList.isNotEmpty) CarouselSlider(
                                      items: taskList,
                                      carouselController: _controller,
                                      options: CarouselOptions(
                                          onPageChanged: (index, reason) {
                                        setState(() {
                                          _current = index;
                                        });
                                      }),
                                    ),
                                    if(taskList.isNotEmpty) Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: getList(snapshot, context)
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        return GestureDetector(
                                          onTap: () => _controller
                                              .animateToPage(entry.key),
                                          child: Container(
                                            width: 12.0,
                                            height: 12.0,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 8.0, horizontal: 4.0),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xffFB9C26)
                                                    .withOpacity(
                                                        _current == entry.key
                                                            ? 0.9
                                                            : 0.4)),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20, top: 20),
                                            child: Text('Top 3',
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        alignment: Alignment.center),
                                    StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('user')
                                            .where('uid',
                                                whereIn: activeTeam[2])
                                            .snapshots(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                userSnapshot) {
                                          if (userSnapshot.hasData) {
                                            return Container(
                                                height: 280,
                                                width: 350,
                                                child: ListView(
                                                    children:
                                                        getTop3(userSnapshot),
                                                    padding:
                                                        EdgeInsets.all(10)));
                                          } else {
                                            return Container(
                                                alignment: Alignment.center,
                                                child:
                                                    GradientCircularProgressIndicator(
                                                        value: null,
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                          colors: <Color>[
                                                            Color(0xffE53147),
                                                            Color(0xffFB9C26)
                                                          ],
                                                          // red to yellow
                                                          tileMode: TileMode
                                                              .repeated, // repeats the gradient over the canvas
                                                        )));
                                          }
                                        }),
                                  ]);
                                } else
                                  return Container(
                                      alignment: Alignment.center,
                                      child: GradientCircularProgressIndicator(
                                          value: null,
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: <Color>[
                                              Color(0xffE53147),
                                              Color(0xffFB9C26)
                                            ],
                                            // red to yellow
                                            tileMode: TileMode
                                                .repeated, // repeats the gradient over the canvas
                                          )));
                              })
                          : Text('no data');
                    }),
              ])),
            )));
  }
}

class MyUser {
  MyUser(
      {required this.name,
      required this.xp,
      required this.tasks,
      required this.challenges,
      required this.image});

  String name;
  int xp;
  int tasks;
  int challenges;
  String image;
}
