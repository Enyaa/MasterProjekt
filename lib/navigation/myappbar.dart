import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAppbar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppbar({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyAppbarState createState() => _MyAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _MyAppbarState extends State<MyAppbar> {
  @override
  Widget build(BuildContext context) {
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

