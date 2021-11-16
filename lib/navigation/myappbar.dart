import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAppbar extends StatefulWidget implements PreferredSizeWidget {
  MyAppbar(
      {Key? key,
      required this.title,
      required this.bottom,
      required this.actions,
      required this.leading,
      this.getFiltered})
      : super(key: key);
  final String title;
  final bool bottom;
  final bool actions;
  final bool leading;
  var getFiltered;

  @override
  _MyAppbarState createState() => _MyAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _MyAppbarState extends State<MyAppbar> {
  @override
  Widget build(BuildContext context) {
    if (widget.bottom) {
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
              bottom: const TabBar(tabs: [
                Tab(
                    icon: Icon(Icons.star),
                    child: Text('Punkte', textAlign: TextAlign.center)),
                Tab(
                    icon: Icon(Icons.task),
                    child: Text('Aufgaben', textAlign: TextAlign.center)),
                Tab(
                    icon: Icon(Icons.emoji_events),
                    child: Text('Achievements', textAlign: TextAlign.center))
              ])));
    } else if(widget.actions) {
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
            title: const Text('Aufgaben'),
            actions: <Widget>[
              PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text('Alle'), value: 1),
                    PopupMenuItem(child: Text('Offen'), value: 2),
                    PopupMenuItem(child: Text('Angenommen'), value: 3),
                    PopupMenuItem(child: Text('Abgeschlossen'), value: 4)
                  ],
                  onSelected: widget.getFiltered)
            ],
          ),);
    } else if(widget.leading) {
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
