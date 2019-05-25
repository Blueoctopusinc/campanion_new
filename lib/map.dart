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
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io' show Platform;

class mapScreen extends StatefulWidget {
  @override
  mapScreenState createState() => mapScreenState();
}

class mapScreenState extends State<mapScreen> {
  
  @override
  voidinitState() {
    precacheImage(new AssetImage('assets/images/background.jpg'), context);
    super.initState();
  }

  int _selectedPage = 0;

  static final block = mapBlock();
  final _names = [
    "Map",
    "Locations"
  ];
  final _pageOptions = [MyBlockMap(
                block: block,
              ), AllPlaces(authService.uid, block)];
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
        ) ??
        false;
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
            home: Scaffold(extendBody: true,
          appBar: AppBar(
            leading: Builder(builder: (context) => IconButton(onPressed: (){Scaffold.of(context).openDrawer();}, icon: Icon(Icons.account_circle,)),),
              title: Text(_names[_selectedPage],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red[400]),
          drawer: new Drawer(
            
              child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.jpg'),
                          fit: BoxFit.cover)),
                  child: ListView(children: <Widget>[
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          'Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      height: 600,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: UserProfile()),
                              
                              Expanded(
                                child: new Align(
                                  alignment: Alignment.bottomCenter,
                                  child: ButtonTheme(
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
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ))),
                                ),
                              )
                            ]),
                      ),
                    )
                  ]))),
          body: _pageOptions[_selectedPage],
         bottomNavigationBar: BottomAppBar(shape: CircularNotchedRectangle(), clipBehavior: Clip.antiAlias, notchMargin: 4,
         child: BottomNavigationBar(currentIndex: _selectedPage, onTap: (int index){
           setState(() {
             _selectedPage = index;
           });
         },items: [
           BottomNavigationBarItem(title: Text("Map",style:TextStyle(color: Colors.white)),icon: Icon(Icons.map, color: Colors.white,), activeIcon: Icon(Icons.map, color: Colors.indigo,)),
          BottomNavigationBarItem(title: Text("Locations",style:TextStyle(color: Colors.white)), icon: Icon(Icons.location_on, color: Colors.white,), activeIcon: Icon(Icons.map, color: Colors.indigo,),backgroundColor: Colors.red[400]),

         ],backgroundColor: Colors.red[400],),),
        floatingActionButton: _myActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,)));
  }
  FloatingActionButton _myActionButton(){
    if(_selectedPage == 0){
      return FloatingActionButton(backgroundColor: Colors.indigo,child: Icon(Icons.add_location),onPressed: (){},);
  }
}
}
EdgeInsets _myEdge() {
  if (Platform.isAndroid) {
    return EdgeInsets.only(top: 10);
  } else if (Platform.isIOS) {
    return EdgeInsets.only(top: 10, right: 50);
  }
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                spreadRadius: 5,
                offset: Offset(15, 10),
              )
            ],
            border: Border.all(color: Colors.red[400], width: 5),
            shape: BoxShape.circle,
            gradient: LinearGradient(
              // Where the linear gradient begins and ends
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              // Add one stop for each color. Stops should increase from 0 to 1
              stops: [0.1, 0.3, 0.7, 0.9],
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Colors.indigo[900],
                Colors.indigo[400],
                Colors.indigo[600],
                Colors.indigo[400],
              ],
            )),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: authService.profilePhoto,
                  ),
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Text(
                      authService.displayName,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                    Text(
                      authService.eMail,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
