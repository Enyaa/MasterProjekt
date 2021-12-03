import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'mytabbar.dart';

class MyAppbar extends StatefulWidget implements PreferredSizeWidget {
  MyAppbar({
    Key? key,
    required this.title,
    this.bottom = false,
    this.actions = false,
    this.accepted = false,
    this.leading = false,
    this.leaderboards = false,
    this.getFiltered,
    this.doDelete,
    this.admin = false,
    this.mode = '',
  }) : super(key: key);
  final String title;
  final bool bottom;
  final bool actions;
  final bool accepted;
  final bool leading;
  final getFiltered;
  final bool leaderboards;
  final doDelete;
  final bool admin;
  final String mode;

  @override
  _MyAppbarState createState() => _MyAppbarState();

  @override
  Size get preferredSize => bottom ? Size.fromHeight(120) : Size.fromHeight(50);
}

// Custom Appbar
class _MyAppbarState extends State<MyAppbar> {
  // show delete button
  _showDelete() {
    String question = '';
    if(widget.mode == 'task') {
      question = 'Sind Sie sicher, dass Sie die Aufgabe löschen wollen?';
    } else if(widget.mode == 'challenge') {
      question = 'Sind Sie sicher, dass Sie die Herausforderung löschen wollen?';
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xff353535),
              title: new Text(question),
              actions: [
                Container(
                    width: 100,
                    height: 50,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          // 10% of the width, so there are ten blinds.
                          colors: <Color>[Color(0xffE53147), Color(0xffFB9C26)],
                          // red to yellow
                          tileMode: TileMode
                              .repeated, // repeats the gradient over the canvas
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.transparent),
                            shadowColor:
                                MaterialStateProperty.all(Colors.transparent)),
                        onPressed: widget.doDelete,
                        // might not work with iOS
                        child: Text('Ja'))),
                Container(
                    height: 50,
                    width: 100,
                    child: OutlinedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.transparent),
                            shadowColor: MaterialStateProperty.all(
                                Colors.transparent)),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Nein')))
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    // bottom Tabbar
    if (widget.bottom) {
      return new Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              // 10% of the width, so there are ten blinds.
              colors: <Color>[Color(0xffE53147), Color(0xffFB9C26)],
              // red to yellow
              tileMode:
                  TileMode.repeated, // repeats the gradient over the canvas
            ),
          ),
          child: AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              title: Text(widget.title),
              bottom: MyTabbar()));
    } else if (widget.actions) { // Filter for tasks and challenges
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
                      PopupMenuItem(child: Text('Abgeschlossen'), value: 4),
                      PopupMenuItem(child: Text('Aktives Team'), value: 5)
                    ],
                onSelected: widget.getFiltered)
          ],
        ),
      );
    } else if (widget.leading && widget.admin) { // show back and delete button
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
                }),
            actions: [
              Container(
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _showDelete,
                ),
              )
            ],
          ));
    } else if (widget.leading) { // show only back button
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
    } else { // simple appbar with only title
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
