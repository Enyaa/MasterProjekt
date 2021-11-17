import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTabbar extends StatefulWidget implements PreferredSizeWidget {
  MyTabbar({Key? key}) : super(key: key);

  @override
  _MyTabbarState createState() => _MyTabbarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _MyTabbarState extends State<MyTabbar> {
  @override
  Widget build(BuildContext context) {
    return Container(child: const TabBar(
      tabs: [
        Tab(
            icon: Icon(Icons.star),
            child: Text('Punkte', textAlign: TextAlign.center)),
        Tab(
            icon: Icon(Icons.task),
            child: Text('Aufgaben', textAlign: TextAlign.center)),
        Tab(
            icon: Icon(Icons.emoji_events),
            child: Text('Achievements', textAlign: TextAlign.center))
      ],
      unselectedLabelColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(),
    ), decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        // 10% of the width, so there are ten blinds.
        colors: <Color>[Color(0xffE53147), Color(0xffFB9C26)],
        // red to yellow
        tileMode: TileMode.repeated, // repeats the gradient over the canvas
      ),
    ),
    );
  }
}
