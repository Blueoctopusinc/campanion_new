import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'auth.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location_permissions/location_permissions.dart';

class mapScreen extends StatefulWidget {
  @override
  mapScreenState createState() => mapScreenState();
}

class mapScreenState extends State<mapScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return MaterialApp(
        home: Scaffold(
            floatingActionButton: FloatingActionButton(
                onPressed: null,
                child: Icon(Icons.add_location),
                backgroundColor: Color(0xFF1E9F60)),
            appBar: AppBar(
              title: Text('           Campanion Map',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Color(0xFF1E9F60),
            ),
            drawer: new Drawer(
                child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/logo.png"),
                            fit: BoxFit.cover)),
                    child: ListView(children: <Widget>[
                      ListTile(
                        title: Text(
                          'Account Details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Color(0xFF1a8450)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: UserProfile()),
                              ButtonTheme(
                                  minWidth: 280,
                                  height: 60,
                                  child: Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: RaisedButton(
                                        onPressed: () {},
                                        color: Color(0xFFDD4E40),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        child: Text("Sign Out",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ))),
                              Container(
                                  constraints: BoxConstraints(minHeight: 300),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                        onPressed: null,
                                        icon: Icon(Icons.settings),
                                        tooltip: 'App Settings',
                                        iconSize: 70,
                                      ),
                                      Text("Settings",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18))
                                    ],
                                  ))
                            ]),
                      )
                    ]))),
            body: Center(
                child: Column(
              children: <Widget>[
                Expanded(
                  child: myMap(
                    myCameraPosition: CameraPosition(
                        target: LatLng(37.42796133580664, -122.085749655962),
                        zoom: 14.4746),
                  ),
                ),
              ],
            )),
            bottomNavigationBar: new Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Color(0xFF1E9F60),
                primaryColor: Color(0xFF034f25),
                textTheme: Theme.of(context)
                    .textTheme
                    .copyWith(caption: new TextStyle(color: Color(0xFFEAEAEA))),
              ),
              child: BottomNavigationBar(items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.map), title: Text('Map')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.my_location), title: Text('Locations')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), title: Text('Settings'))
              ]),
            )));
  }
}

class myMap extends StatefulWidget {
  final CameraPosition myCameraPosition;
  myMap({Key key, this.myCameraPosition}) : super(key: key);

  @override
  State<myMap> createState() => new myMapState();
}

class myMapState extends State<myMap> {
  //Permissission handlling, Async returns a Future
  Future<PermissionStatus> permission =
      LocationPermissions().requestPermissions();


  Completer<GoogleMapController> mapController = Completer();
  CameraPosition stateCam;

  @override
  void initState() {
    super.initState();
    stateCam = widget.myCameraPosition;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: stateCam,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          mapController.complete(controller);
        },
      ),
    );
  }
}

class UserProfile extends StatefulWidget {
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
          color: Color(0xFF1E9F60),
          border: new Border.all(
              color: Color(0xFF13663d), width: 10.0, style: BorderStyle.solid),
          borderRadius: new BorderRadius.circular(20.0)),
      accountName: Text(authService.displayName),
      accountEmail: Text(
        authService.eMail,
        textAlign: TextAlign.center,
      ),
      currentAccountPicture: CircleAvatar(
        backgroundImage: NetworkImage(authService.profilePhoto),
      ),
    );
  }
}
