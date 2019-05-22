import 'package:flutter/material.dart';
import 'dart:async';

import 'package:campanion_new/model/camp.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class showLocationScreen extends StatelessWidget {

  String lat;
  String lon;
  Completer<GoogleMapController> mapController = Completer();
  showLocationScreen(String lati, String longi){
    lat = lati;
    lon = longi;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(children: <Widget>[
      GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(double.parse(lat), double.parse(lon)),zoom: 20.0),)
    ],);
  }
}
