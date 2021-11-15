import 'package:flutter/material.dart';

class NavigationBar extends StatelessWidget {
  int activeIndex = 0;

  NavigationBar(int activeIndex) {
    if (activeIndex >= 6 || activeIndex <= 0) {
      activeIndex = 0;
    }

    this.activeIndex = activeIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black54,
              blurRadius: 15.0,
              offset: Offset(0.0, 0.75)
          )
        ],
      ),
        child: BottomAppBar(
            child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.home,
                color: activeIndex == 1 ? Colors.deepOrange : Colors.grey),
            onPressed: () {
              if (activeIndex != 1) {
                Navigator.pushReplacementNamed(context, '/homepage');
                activeIndex = 2;
              }
            }),
        IconButton(
            icon: Icon(Icons.note_alt,
                color: activeIndex == 2 ? Colors.deepOrange : Colors.grey),
            onPressed: () {
              if (activeIndex != 2) {
                Navigator.pushReplacementNamed(context, '/tasks');
                activeIndex = 3;
              }
            }),
        IconButton(
            icon: Icon(Icons.add_box, color: Colors.amber[800]),
            onPressed: () {
              activeIndex = 0;
              Navigator.pushReplacementNamed(context, '/task-create');
            }),
        IconButton(
            icon: Icon(Icons.emoji_events,
                color: activeIndex == 3 ? Colors.deepOrange : Colors.grey),
            onPressed: () {
              if (activeIndex != 3) {
                Navigator.pushReplacementNamed(context, '/challenges');
                activeIndex = 4;
              }
            }),
        IconButton(
            icon: Icon(Icons.leaderboard,
                color: activeIndex == 4 ? Colors.deepOrange : Colors.grey),
            onPressed: () {
              if (activeIndex != 4) {
                Navigator.pushReplacementNamed(context, '/leaderboards');
                activeIndex = 5;
              }
            }),
      ],
    )));
  }
}
