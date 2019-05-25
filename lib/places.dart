import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:rxdart/rxdart.dart';
import 'package:campanion_new/model/places_bloc.dart';
import 'package:campanion_new/model/camp.dart';
import 'dart:math';
import 'package:campanion_new/model/map_model.dart';
import 'show_location_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AllPlaces extends StatelessWidget {
  static String _uid;
  mapBlock mapbloc;
  AllPlaces(String id, mapBlock bloc) {
    _uid = id;
    mapbloc = bloc;
  }
  final bloc = places_bloc();

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  static double distance(double lata, double lnga, double latb, double lngb) {
    final R = 6372.8;
    double dLat = _toRadians(latb - lata);
    double dLon = _toRadians(lngb - lnga);
    lata = _toRadians(lata);
    latb = _toRadians(latb);
    double a =
        pow(sin(dLat / 2), 2) + pow(sin(dLon / 2), 2) * cos(lata) * cos(latb);
    double c = 2 * asin(sqrt(a));
    return R * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Locations"),
        backgroundColor: Colors.red,
      ),
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.indigo, Colors.red[400]],
                begin: const FractionalOffset(0.5, 0.0),
                end: const FractionalOffset(0.0, 0.7),
                stops: [0.3, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: _content(context)),
    );
  }

  Widget _content(BuildContext context) {
    return StreamBuilder(
      stream: bloc.allPlaces,
      builder: (BuildContext context, AsyncSnapshot<List<Camp>> snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        final camps = snapshot.data;
        return _listView(context, camps);
      },
    );
  }

  Widget _distanceText(BuildContext context, Camp c) {
    if (c.lat == null) {
      return Text(
        "No location data available",
        style: TextStyle(color: Colors.white),
      );
    }
    if (mapbloc.lat == null) {
      return Text("No GPS data available",
          style: TextStyle(color: Colors.white));
    }
    double check = distance(
        double.parse(c.lat), double.parse(c.lon), mapbloc.lat, mapbloc.lon);
    print(check);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 200,
            child: Center(
              child: Text(
                "Distance:",
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontStyle: FontStyle.italic,
                    fontSize: 25,
                    color: Colors.white),
              ),
            ),
          ),
          Container(
              width: 200,
              child: Text(
                (check.round().toString() + " KM"),
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontStyle: FontStyle.italic,
                    fontSize: 36,
                    color: Colors.white),
              )),
        ],
      ),
    );
  }

  Widget _photoDialog(BuildContext context, Camp c) {
    return new AlertDialog(
      backgroundColor: Colors.indigo,
      title: Text(c.name + " photo", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      content: Container(
        color: Colors.indigo,
        child: Column(
          
                  children:<Widget>[ CachedNetworkImage(
            imageUrl: c.photoRef, placeholder: (context, url) => new CircularProgressIndicator(),
            
          ),Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(color: Colors.red[400],child: Text("EXIT", style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: Colors.white),),onPressed: (){Navigator.of(context).pop();},),
          )],
        ),
      ),
    );
  }

  Widget _listView(BuildContext context, List<Camp> camps) {
    return ListView.builder(
      itemCount: camps.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildListItem(context, camps[index]);
      },
    );
  }

  Widget _buildListItem(
    BuildContext context,
    Camp c,
  ) {
    Widget descText;
    if (c.description.isNotEmpty) {
      Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Column(children: <Widget>[
          Container(
            child: Text("Hello "),
          ),
          Container(
              child: descText = Text(c.description,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic))),
        ]),
      );
    }
    //double dist = distance(c.lat, c.lon, mapbloc.lat, mapbloc.lon);
    return Center(
        child: Card(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          // Add one stop for each color. Stops should increase from 0 to 1
          stops: [0.00, 0.25, 0.85, 0.99],
          colors: [
            // Colors are easy thanks to Flutter's Colors class.
            Colors.red[800],
            Colors.red[400],
            Colors.red[400],
            Colors.red[800],
          ],
        )),
        child: ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Opacity(
              opacity: 0.9,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          showDialog(context: context, builder: (BuildContext context)=>_photoDialog(context, c),);
                        },
                        child: Container(
                            width: 80,
                            height: 80,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: c.photoRef,
                                placeholder: (context, url) =>
                                    new CircularProgressIndicator(),
                                errorWidget: (context, url, urror) =>
                                    Icon(Icons.error),
                                fit: BoxFit.fill,
                              ),
                            ))),
                    Center(
                      child: Text(
                        c.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
            ),
          ),
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.6),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      topLeft: Radius.circular(10.0))),
              child: Column(
                children: <Widget>[
                  descText,
                  Opacity(
                    opacity: 0.9,
                    child: Container(
                      constraints: BoxConstraints(),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: _distanceText(context, c),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                ButtonTheme(
                                  buttonColor: Colors.indigo,
                                  minWidth: 100,
                                  child: RaisedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .leftToRight,
                                              child: showLocationScreen(
                                                  c.lat.toString(),
                                                  c.lon.toString(),
                                                  c.name)));
                                      print("clicked");
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.map,
                                            color: Colors.white,
                                          ),
                                          Text("View on Map",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                ButtonTheme(
                                  minWidth: 100,
                                  child: RaisedButton(
                                    onPressed: () {
                                      print("clicked");
                                    },
                                    color: Colors.indigo,
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                        Text("Edit",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
