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
    return new MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Login'),
            backgroundColor: Colors.lime,
          ),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    MaterialButton(
                        onPressed: () {
                          authService.googleSignIn(context);

                        } ,
                        color: Colors.white,
                        textColor: Colors.black,
                        child: Text('Login with Google')),
                    MaterialButton(
                        onPressed: () => authService.signOut(context),
                        color: Colors.white,
                        textColor: Colors.black,
                        child: Text('Logout')),
                  ]))),
    );
  }
}