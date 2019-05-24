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
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Where the linear gradient begins and ends
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              // Add one stop for each color. Stops should increase from 0 to 1
              stops: [0.1, 0.3, 0.7, 0.9],
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Colors.green[800],
                Colors.green[700],
                Colors.green[600],
                Colors.green[400],
              ],
            ),
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
        child: Container(
            child: descText = Text(c.description,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.italic))),
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
          stops: [0.1, 0.5, 0.75, 0.95],
          colors: [
            // Colors are easy thanks to Flutter's Colors class.
            Colors.red[400],
            Colors.red[700],
            Colors.red[600],
            Colors.red[400],
          ],
        )),
        child: ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Opacity(
              opacity: 0.9,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: <Widget>[
                Container(width: 80, height: 80,child: ClipOval(child:CachedNetworkImage(imageUrl: c.photoRef,placeholder: (context, url) => new CircularProgressIndicator(),errorWidget: (context, url, urror)=> Icon(Icons.error),fit: BoxFit.fill,),)),
                Center(
                  child: Text(
                    c.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                ButtonTheme(
                                  buttonColor: Colors.green,
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
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.map, color: Colors.white,),
                                        Text("View on Map", style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                                ButtonTheme(
                                  minWidth: 100,
                                  child: RaisedButton(
                                    onPressed: () {
                                      print("clicked");
                                    },
                                    color: Colors.green,
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.photo_album, color: Colors.white,),
                                        Text("View Photo", style: TextStyle(color: Colors.white),),
                                      ],
                                    ),
                                  ),
                                ),
                                ButtonTheme(
                                  minWidth: 100,
                                  child: RaisedButton(
                                    onPressed: () {
                                      print("clicked");
                                    },
                                    color: Colors.green,
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.edit, color: Colors.white,),
                                        Text("Edit", style: TextStyle(color: Colors.white)),
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
