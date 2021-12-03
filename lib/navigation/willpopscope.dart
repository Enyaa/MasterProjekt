import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyWillPopScope extends StatefulWidget {
  const MyWillPopScope({Key? key, required this.child, required this.text, this.destination = '/homepage', this.close = false})
      : super(key: key);

  final Widget child;
  final String text;
  final String destination;
  final bool close;

  @override
  _MyWillPopScopeState createState() => _MyWillPopScopeState();
}

// Custom WillPopScope
class _MyWillPopScopeState extends State<MyWillPopScope> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool willLeave = false;
        // show the confirm dialog
        await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Color(0xff353535),
                  // Set title
                  title: Text(widget.text),
                  actions: [
                    Container(
                        width: 100,
                        height: 50,
                        decoration: const BoxDecoration( // Button with gradient
                            gradient: LinearGradient(
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
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        child: ElevatedButton(
                            style: ButtonStyle( // White outline button
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.transparent)),
                            onPressed: () {
                              willLeave = false;
                              if(widget.close) SystemNavigator.pop();
                              else {
                                Navigator.of(context).pop();
                                Navigator.pushReplacementNamed(context, widget.destination);
                              }// might not work with iOS
                            },
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
                  ],
                ));
        return willLeave;
      },
      child: widget.child,
    );
  }
}
