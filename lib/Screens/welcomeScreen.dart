import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    final gradient = LinearGradient(colors: <Color>[Color(0xffE53147), Color(0xffFB9C26)]);

    return WillPopScope(
        onWillPop: () async {
          bool willLeave = false;
          // show the confirm dialog
          await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Are you sure want to leave?'),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        willLeave = false;
                        SystemNavigator.pop(); // might not work with iOS
                      },
                      child: Text('Yes')),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('No'))
                ],
              ));
          return willLeave;
        },child: Scaffold(
        body: Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('lib/Graphics/rettich.png', height: 350, width: 350,),
                  ShaderMask(
                    shaderCallback: (Rect bounds){
                      return gradient.createShader(Offset.zero & bounds.size);
                    },
                    child: Center(
                      child: Text("TeamRad", style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          height: 2)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Container(
                      width: 370,
                      height: 50,
                      decoration: const BoxDecoration(
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
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.transparent),
                              shadowColor: MaterialStateProperty.all(
                                  Colors.transparent)),
                          onPressed: () {
                              Navigator.pushReplacementNamed(context, '/register');
                          },
                          child: Text("Registrieren")),
                    ),
                  ),
                  Container(
                    width: 370,
                    height: 50,
                    decoration: const BoxDecoration(
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
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.transparent),
                            shadowColor: MaterialStateProperty.all(
                                Colors.transparent)),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text("Login")),
                  ),
                ],
              ),
            )
        )));
  }
}