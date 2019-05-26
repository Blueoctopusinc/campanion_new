import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:campanion_new/model/camp.dart';
import 'package:campanion_new/model/map_model.dart';
import 'package:campanion_new/model/places_bloc.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'edit_location_screen.dart';
import 'show_location_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';


class linePainter extends CustomPainter{
  int mycount;



  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.white;
    paint.strokeWidth=1;
    canvas.drawLine(Offset(size.width/5, (size.height/2)*1.5), Offset((size.width/5)*4, (size.height/2)*1.5), paint);
    canvas.drawLine(Offset(0, size.height/2), Offset(size.width, size.height/2), paint);
  }

  @override
  bool shouldRepaint(linePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(linePainter oldDelegate) => false;
}

class AllPlaces extends StatelessWidget {
  _deleteData(Camp c) async{
    await Firestore.instance.runTransaction((Transaction deleteTransaction) async{
      await deleteTransaction.delete(c.reference);
    });
  }
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
          decoration: BoxDecoration(gradient: 
              LinearGradient(colors: [Colors.deepPurple, Colors.indigo[400]],
                begin: const FractionalOffset(0.55, 0.0),
                end: const FractionalOffset(0.0, 0.7),
                stops: [0.3,1.0],
                tileMode: TileMode.clamp
              
            ),),
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

  Widget _viewButton(BuildContext context, Camp c) {
    if (c.lat != null) {
      return ButtonTheme(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5))),
        buttonColor: Colors.green[400],
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.leftToRight,
                    child: showLocationScreen(
                        c.lat.toString(), c.lon.toString(), c.name)));
            print("clicked");
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Container(
              decoration: BoxDecoration(),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.map,
                    color: Colors.white,
                    size: 32,
                  ),
                  Text(
                    "View on Map",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return ButtonTheme(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15))),
        buttonColor: Colors.indigo,
        child: RaisedButton(
          onPressed: null,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.map,
                      color: Colors.white,
                      size: 32,
                    ),
                    Text(
                      "View on Map",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
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
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
            ),
          ),
          Container(
              child: Text(
            (" " + check.round().toString() + "(KM)"),
            style: TextStyle(
                fontFamily: "Roboto",
              fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.green[400]),
          )),
        ],
      ),
    );
  }

  Widget _deleteDialog(Camp c, places_bloc bloc, BuildContext context) {
    
    return new AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      backgroundColor: Colors.indigo,
      content: Column(
        children: <Widget>[
          Container(
            child: Text("Are you sure you wish to delete " +
                c.name +
                "? This action is permanent "),
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            color: Colors.red,
            child: Text(
              "Delete",
              style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            onPressed: () {
              _deleteData(c);
              Navigator.of(context).pop();
            },
          ),

        ],
      ),
    );
  }

  Widget _photoDialog(BuildContext context, Camp c) {
    return new AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      backgroundColor: Colors.green[400],
      title: Container(
        child: Text(
          c.name + " Photo",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 26),
        ),
      ),
      content: 
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: c.photoRef,
                placeholder: (context, url) => new CircularProgressIndicator(),
              ),
            )
          ,
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
      Future<String>cAddress;
      if(c.lat != null){
      cAddress =Geocoder.local.findAddressesFromCoordinates(Coordinates(double.parse(c.lat), double.parse(c.lon))).then((onValue){
          
          
           return onValue.first.addressLine;

        });
      
      }
    Widget descText;
    if (c.description.isNotEmpty) {
      Padding(
        
        padding: const EdgeInsets.only(bottom: 25, top: 20),
        child: Column(children: <Widget>[
          Container(
            child: Text("Hello "),
          ),
          Container(
              child:Column(children: <Widget>[
                           
                    descText = Column(children: <Widget>[
                             Text("Information", style: TextStyle(color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Roboto',fontWeight: FontWeight.bold)),CustomPaint(painter: linePainter(),child: Container(width: 80,height: 20,),),Text(c.description, 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                  )
              ),CustomPaint(painter: linePainter(),child: Container(width: 30,height: 20,),)],)
              ]),
        )]),
      );
    }
    //double dist = distance(c.lat, c.lon, mapbloc.lat, mapbloc.lon);
    return Center(
      child: Card(
        color: Colors.grey[400].withOpacity(0.2),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: ExpansionTile(
          onExpansionChanged: (value)=>{
              
          },
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Opacity(
              opacity: 0.9,
              child: Row(children: <Widget>[
                Column(
                  children: <Widget>[
                    Center(
                      child: Container(
                        child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _photoDialog(context, c),
                              );
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
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          c.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 29,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.50,
                            actions: <Widget>[
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                child: IconSlideAction(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.leftToRight,
                                            child: EditLocation(
                                              c: c,
                                              uid: _uid,
                                            )));
                                  },
                                  icon: Icons.mode_edit,
                                  color: Colors.amber[400],
                                  caption: 'Edit',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  child: IconSlideAction(
                                    onTap: () {
                                      showDialog(context: context,
                                      builder: (BuildContext context) => 
                                      _deleteDialog(c, bloc, context));
                                    },
                                    icon: Icons.delete_forever,
                                    color: Colors.redAccent,
                                    caption: 'Delete',
                                  ),
                                ),
                              )
                            ],
                            child: Container(
                              constraints: BoxConstraints(),
                              decoration: BoxDecoration(
                                
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10.0))),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.white,
                                            size: 36,
                                          )
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),                                           color: Colors.grey.withBlue(200).withOpacity(0.5),
),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              FutureBuilder(
                                                future: cAddress,
                                                initialData: "Getting Address",
                                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                                  
                                                  return Text(snapshot.data, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 18),);
                                                },
                                              ),
                                                                                            CustomPaint(painter: linePainter(),child: Container(width: 300,height: 20,),),

                                              Container(alignment: Alignment.topLeft,
                                                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                                
Container(
                                          
                                                  child: _distanceText(context, c),
                                                  
                                                ),
                                                CustomPaint(painter: linePainter(),child: Container(width: 160,height: 20,),),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 10.0),
                                                  child: Container(
                                                    child: descText,
                                                  ),
                                                ),
                                                ],),
                                              )
                                            ,
                                              
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _viewButton(context, c)
          ],
        ),
      ),
    );
  }
}
