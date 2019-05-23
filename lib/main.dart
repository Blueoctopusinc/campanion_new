import 'package:flutter/material.dart';
import 'auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    home: new authButtons());
  }
}

class authButtons extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(theme: ThemeData(fontFamily: 'Roboto'),

      title: 'Campanion',
      home: Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: LinearGradient(
              // Where the linear gradient begins and ends
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              // Add one stop for each color. Stops should increase from 0 to 1
              stops: [0.1, 0.3, 0.7, 0.9],
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Colors.green[800],
                Colors.lightGreen[700],
                Colors.indigo[600],
                Colors.indigo[400 ],
              ],
            ),),
            child: Center(
                child: SizedBox(width: 250,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Campanion", style: TextStyle(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold),),
                        Container(constraints: BoxConstraints(maxHeight: 400), child: Image(image: AssetImage('assets/images/drawing.png'),)),
                        MaterialButton(

                            onPressed: () {
                              authService.googleSignIn(context);

                            } ,
                            color: Colors.green,
                            textColor: Colors.white,
                            child: Container(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children:<Widget>[ Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Image(image: AssetImage('assets/images/btn_goog.png')),
                            ),Text('Login with Google'),] ))),
                      ]),
                )),
          )),
    );
  }
}