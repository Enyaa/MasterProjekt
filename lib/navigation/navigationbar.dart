import 'package:flutter/material.dart';

import '../GradientIcon.dart';

class NavigationBar extends StatelessWidget {
  int activeIndex = 0;
  Color lightOrange = Color(0xffFB9C26);

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
                    icon: activeIndex == 1
                        ? GradientIcon(Icons.group, 25, LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      // 10% of the width, so there are ten blinds.
                      colors: <Color>[
                        Color(0xffE53147),
                        Color(0xffFB9C26)
                      ],
                      // red to yellow
                      tileMode: TileMode
                          .repeated, // repeats the gradient over the canvas
                    ))
                    : Icon(Icons.group_outlined, color: lightOrange,)
                    ,
                    onPressed: () {
                      if (activeIndex != 1) {
                        Navigator.pushReplacementNamed(context, '/teams');
                        activeIndex = 2;
                      }
                    }),
                IconButton(
                    icon: activeIndex == 2
                        ? GradientIcon(Icons.note_alt, 25, LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      // 10% of the width, so there are ten blinds.
                      colors: <Color>[
                        Color(0xffE53147),
                        Color(0xffFB9C26)
                      ],
                      // red to yellow
                      tileMode: TileMode
                          .repeated, // repeats the gradient over the canvas
                    )): Icon(Icons.note_alt_outlined,
                        color: lightOrange),
                    onPressed: () {
                      if (activeIndex != 2) {
                        Navigator.pushReplacementNamed(context, '/tasks');
                        activeIndex = 3;
                      }
                    }),
                IconButton(
                    icon: GradientIcon(Icons.home, 30, LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      // 10% of the width, so there are ten blinds.
                      colors: <Color>[
                        Color(0xffE53147),
                        Color(0xffFB9C26)
                      ],
                      // red to yellow
                      tileMode: TileMode
                          .repeated, // repeats the gradient over the canvas
                    ),),
                    onPressed: () {
                      activeIndex = 0;
                      Navigator.pushReplacementNamed(context, '/homepage');
                    }),
                IconButton(
                    icon: activeIndex == 3
                        ? GradientIcon(Icons.emoji_events, 25, LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      // 10% of the width, so there are ten blinds.
                      colors: <Color>[
                        Color(0xffE53147),
                        Color(0xffFB9C26)
                      ],
                      // red to yellow
                      tileMode: TileMode
                          .repeated, // repeats the gradient over the canvas
                    ))
                        : Icon(Icons.emoji_events_outlined, color: lightOrange),
                    onPressed: () {
                      if (activeIndex != 3) {
                        Navigator.pushReplacementNamed(context, '/challenges');
                        activeIndex = 4;
                      }
                    }),
                IconButton(
                    icon: activeIndex == 4
                        ? GradientIcon(Icons.leaderboard, 25, LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      // 10% of the width, so there are ten blinds.
                      colors: <Color>[
                        Color(0xffE53147),
                        Color(0xffFB9C26)
                      ],
                      // red to yellow
                      tileMode: TileMode
                          .repeated, // repeats the gradient over the canvas
                    ))
                        : Icon(Icons.leaderboard_outlined,
                        color: lightOrange),
                    onPressed: () {
                      if (activeIndex != 4) {
                        Navigator.pushReplacementNamed(
                            context, '/leaderboards');
                        activeIndex = 5;
                      }
                    }),
              ],
            )));
  }
}
