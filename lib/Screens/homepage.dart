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

  @override
  Widget build(BuildContext context) {
    var tasks = FirebaseFirestore.instance
        .collection('tasks')
        .where('accepted', isEqualTo: true)
        .where('user', isEqualTo: getUid())
        .where('finished', isEqualTo: false)
        .snapshots();

    getList(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
      return snapshot.data!.docs
          .map((doc) => Card(
              child: ListTile(
                horizontalTitleGap: 0,
                contentPadding: EdgeInsets.zero,
                  title: Transform.translate(offset: Offset(0, -4), child: Container(
                      height: 50,
                      child: Container(child: Text(doc['title'], style: TextStyle(fontSize: 16)), alignment: Alignment.center),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                          gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[Color(0xffE53147), Color(0xffFB9C26)], // red to yellow
                        tileMode: TileMode
                            .repeated, // repeats the gradient over the canvas
                      )))),
                  subtitle: new Padding(padding: EdgeInsets.all(10), child: Text(doc['description'])),
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

    return MyWillPopScope(
        text: "App schließen?",
        close: true,
        child: Scaffold(
            appBar: MyAppbar(
                title: 'Home', actions: false, bottom: false, leading: false),
            drawer: MyDrawer(),
            bottomNavigationBar: NavigationBar(1),
            body: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Todo:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                    StreamBuilder(
                        stream: tasks,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            return Column(children: [
                              CarouselSlider(
                                items: getList(snapshot, context),
                                carouselController: _controller,
                                options: CarouselOptions(
                                    onPageChanged: (index, reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                }),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: getList(snapshot, context)
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return GestureDetector(
                                    onTap: () =>
                                        _controller.animateToPage(entry.key),
                                    child: Container(
                                      width: 12.0,
                                      height: 12.0,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 4.0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xffFB9C26).withOpacity(
                                              _current == entry.key
                                                  ? 0.9
                                                  : 0.4)),
                                    ),
                                  );
                                }).toList(),
                              ),
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
                        }),
                  ]),
            )));
  }
}
