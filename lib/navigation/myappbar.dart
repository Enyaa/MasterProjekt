import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'mytabbar.dart';

class MyAppbar extends StatefulWidget implements PreferredSizeWidget {
  MyAppbar(
      {Key? key,
      required this.title,
      this.bottom = false,
      this.actions = false,
      this.accepted = false,
      this.leading = false,
      this.leaderboards = false,
      this.getFiltered})
      : super(key: key);
  final String title;
  final bool bottom;
  final bool actions;
  bool accepted;
  final bool leading;
  var getFiltered;
  final bool leaderboards;

  @override
  _MyAppbarState createState() => _MyAppbarState();

  @override
  Size get preferredSize => bottom ? Size.fromHeight(120): Size.fromHeight(50);
}

class _MyAppbarState extends State<MyAppbar> {
  @override
  Widget build(BuildContext context) {
    if (widget.bottom) {
      return new Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              // 10% of the width, so there are ten blinds.
              colors: <Color>[Color(0xffE53147), Color(0xffFB9C26)],
              // red to yellow
              tileMode: TileMode.repeated, // repeats the gradient over the canvas
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              title: Text(widget.title),
              bottom: MyTabbar()
      ));
    } else if (widget.actions) {
      return new Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black54,
                blurRadius: 15.0,
                offset: Offset(0.0, 0.75))
          ],
        ),
        child: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem(child: Text('Alle'), value: 1),
                      PopupMenuItem(child: Text('Offen'), value: 2),
                      if (widget.accepted)
                        PopupMenuItem(child: Text('Angenommen'), value: 3),
                      PopupMenuItem(child: Text('Abgeschlossen'), value: 4)
                    ],
                onSelected: widget.getFiltered)
          ],
        ),
      );
    } else if (widget.leading) {
      return new Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black54,
                  blurRadius: 15.0,
                  offset: Offset(0.0, 0.75))
            ],
          ),
          child: AppBar(
              title: Text(widget.title),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  })));
    } else {
      return new Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black54,
                  blurRadius: 15.0,
                  offset: Offset(0.0, 0.75))
            ],
          ),
          child: AppBar(title: Text(widget.title)));
    }
  }
}
