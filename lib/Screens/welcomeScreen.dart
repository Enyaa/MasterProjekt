import 'package:flutter/material.dart';
import 'package:master_projekt/navigation/willpopscope.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    final gradient = LinearGradient(colors: <Color>[Color(0xffE53147), Color(0xffFB9C26)]);

    return MyWillPopScope(
        text: 'App verlassen?',
        close: true,
        child: Scaffold(
        body: Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(padding: EdgeInsets.all(20)),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      height: 50,
                      width: 300,
                      child: OutlinedButton(
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
                  TextButton(onPressed: () {
                    Navigator.pushReplacementNamed(context, '/password');
                  }, child: Text("Passwort vergessen?", style: TextStyle(color: Colors.white)),)
                ],
              ),
            )
        )));
  }
}