import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'auth.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campanion_new/model/map_model.dart';
import 'package:campanion_new/add_location.dart';
import 'add_location_screen.dart';
import 'places.dart';
import 'show_location_screen.dart';
import 'package:page_transition/page_transition.dart';

import 'dart:io' show Platform;

FloatingActionButton myActionButton (mapBlock block, String uid, BuildContext context){
  if(Platform.isAndroid){
    return FloatingActionButton(
        onPressed: () => {
          print("myAction button"),
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft, child: AddLocation(
                    mapbloc: block,
                    uid: uid,
                  )))
        },
        child: Icon(Icons.add_location),
        backgroundColor: Colors.green);
  }
}
class mapScreen extends StatefulWidget {
  @override
  mapScreenState createState() => mapScreenState();
}

class mapScreenState extends State<mapScreen> {
  int _selectedPage = 0;
  final _pageOptions = ['Map', 'Locations', 'Settings'];
  final block = mapBlock();
  bool isMap = true;
  @override

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }
  Widget build(BuildContext context) {
    
    // TODO: implement build
    Geolocator geolocator = Geolocator();
    Future<Position> position =
        geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    position.then((Position position) => {print(position), print("Here")});

    return new WillPopScope(
      onWillPop: _onWillPop,
      


    child: MaterialApp(
        home: Scaffold(
            floatingActionButton: Visibility(
              visible: isMap,
              child: myActionButton(block, authService.uid, context)
            ),
            appBar: AppBar(
              title: Text((_pageOptions[_selectedPage]).toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red
            ),
            drawer: new Drawer(
                child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/background.jpg'),
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
                                        onPressed: () =>
                                            {authService.signOut(context)},
                                        color: Color(0xFFDD4E40),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        child: Text("Sign Out",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ))),
                            ]),
                      )
                    ]))),
            body: [MyBlockMap(block: block,), AllPlaces(authService.uid,block)].elementAt(_selectedPage)
            ,bottomNavigationBar: new Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.red,
                primaryColor: Colors.green,
                textTheme: Theme.of(context)
                    .textTheme
                    .copyWith(caption: new TextStyle(color: Color(0xFFEAEAEA))),
              ),
              child: BottomNavigationBar(
                  currentIndex: _selectedPage,
                  onTap: (int index) {
                    if(index==0){
                      setState(() {
                        _selectedPage = index;
                        isMap = true;
                      });
                    }else{
                    setState(() {
                      _selectedPage = index;
                      isMap = false;
                    });
                  }},
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.map), title: Text('Map')),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.my_location),
                      title: Text('Locations'),
                    ),

                  ]),
            )))
    );}
}

class MyBlockMap extends StatefulWidget {
  final mapBlock block;
  MyBlockMap({Key key, this.block}) : super(key: key);
  @override
  State<MyBlockMap> createState() => MyBlockMapState();
}

class MyBlockMapState extends State<MyBlockMap> {
  mapBlock myBlock;
  Completer<GoogleMapController> mapController = Completer();
  @override
  void initState() {
    super.initState();
    myBlock = widget.block;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: myBlock.pos_stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            print("Has Data");
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                  target:
                      LatLng(snapshot.data.latitude, snapshot.data.longitude),
                  zoom: 15),
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                mapController.complete(controller);
              },
            );
          } else {
            print("No Data");
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(37.42796133580664, -122.085749655962),
                  zoom: 14.4746),
            );
          }
        });
  }
}

class myMap extends StatefulWidget {
  final CameraPosition myCameraPosition;
  final bool myLocLayer;
  myMap({Key key, this.myCameraPosition, this.myLocLayer}) : super(key: key);

  @override
  State<myMap> createState() => new myMapState();
}

class myMapState extends State<myMap> {
  //Permissission handlling, Async returns a Future

  Completer<GoogleMapController> mapController = Completer();
  CameraPosition stateCam;
  bool locLayerBool;
  @override
  void initState() {
    super.initState();
    stateCam = widget.myCameraPosition;
    locLayerBool = widget.myLocLayer;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: stateCam,
        mapType: MapType.normal,
        myLocationEnabled: locLayerBool,
        onMapCreated: (GoogleMapController controller) {
          mapController.complete(controller);
        },
      ),
    );

    Future<void> _goToPosition() async {}
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
          color: Color(0xFF1E9F60).withOpacity(0.8),
          border: new Border.all(
              color: Color(0xFF13663d).withOpacity(0.5),
              width: 6.0,
              style: BorderStyle.solid),
          borderRadius: new BorderRadius.circular(30.0)),
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

