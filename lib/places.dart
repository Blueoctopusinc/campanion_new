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
import 'package:page_transition/page_transition.dart';
import 'edit_location_screen.dart';
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
            color: Colors.white
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
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            
            child: Center(
              child: Text(
                "Distance: ",
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontStyle: FontStyle.italic,
                    fontSize: 25,
                    color: Colors.white),
              ),
            ),
          ),
          Container(
              
              child: Text(
                (" "+check.round().toString() + "(KM)"),
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontStyle: FontStyle.italic,
                    fontSize: 30,
                    color: Colors.white),
              )),
        ],
      ),
    );
  }

  Widget _photoDialog(BuildContext context, Camp c) {
    return new AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      backgroundColor: Colors.indigo,
      title: Container(child: Text(c.name + " Photo", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 26),), ),
      content: Container(
        
        color: Colors.indigo,
        child: Column(
          
                  children:<Widget>[ ClipRRect( borderRadius: BorderRadius.all(Radius.circular(20)),
                                      child: CachedNetworkImage(
            imageUrl: c.photoRef, placeholder: (context, url) => new CircularProgressIndicator(),
            
          ),
                  ),Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),color: Colors.red[400],child: Text("Exit", style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: Colors.white),),onPressed: (){Navigator.of(context).pop();},),
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
        padding: const EdgeInsets.only(bottom: 25, top: 20),
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
          color: Colors.indigo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ), 
      child:  ExpansionTile(
        
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
                  color: Colors.red[400],
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: Column(
                children: <Widget>[
                  Container(
                    
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.grey),
                    
                    
                      child: _distanceText(context, c),
                    
                  ),
                  Opacity(
                    opacity: 0.9,
                    child: Container(
                      constraints: BoxConstraints(),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top:10.0),
                            child: Container(
                              child: descText,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                ButtonTheme(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                  buttonColor: Colors.indigo[400],
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                  minWidth: 100,
                                  child: RaisedButton(
                                    onPressed: () {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: EditLocation(c: c, uid: _uid,)));
                                      print("clicked");
                                    },
                                    color: Colors.indigo[400],
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
    );
  }
}
