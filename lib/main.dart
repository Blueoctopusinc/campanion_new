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
    Color gradientStart = Colors.green; //Change start gradient color here
  Color gradientEnd = Colors.red; //Change end gradient color here

    // TODO: implement build
    return new MaterialApp(theme: ThemeData(fontFamily: 'Roboto'),

      title: 'Campanion',
      home: Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient:
              LinearGradient(colors: [gradientStart, gradientEnd],
                begin: const FractionalOffset(0.3, 0.0),
                end: const FractionalOffset(0.0, 0.7),
                stops: [0.0,1.0],
                tileMode: TileMode.clamp
              
            ),),
            child: Center(
                child: SizedBox(width: 250,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text("Campanion", style: TextStyle(fontSize: 45 , color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Helvetica'),),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Container(constraints: BoxConstraints(maxHeight: 400), child: Image(image: AssetImage('assets/images/drawing.png'),)),
                        ),
                        RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0),),
                          

                            onPressed: () {
                              authService.googleSignIn(context);

                            } ,
                            color: Colors.blue.withOpacity(0),
                            textColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children:<Widget>[ Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image(image: AssetImage('assets/images/bright_google.png')),
                              ),Text('Login with Google'),] )),
                            )),
                      ]),
                )),
          )),
    );
  }
}