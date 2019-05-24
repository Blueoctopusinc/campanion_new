import 'package:flutter/material.dart';
import 'dart:async';

import 'package:campanion_new/model/camp.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class showLocationScreen extends StatelessWidget {
  final Set<Marker> _markers = {};
  String locname;
  String lat;
  String lon;
  Completer<GoogleMapController> mapController = Completer();
  showLocationScreen(String lati, String longi, String name){
    lat = lati;
    lon = longi;
    locname = name;
    _markers.add(Marker(markerId: MarkerId(name), position: LatLng(double.parse(lat), double.parse(lon))));
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(appBar: AppBar(title: Text(locname), backgroundColor: Colors.red, ),body: Center(
      child: GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(double.parse(lat), double.parse(lon)),zoom: 60.0),markers: _markers,),)
        
      );

  }
}
