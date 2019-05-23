import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';

class mapBlock {
  double lat;
  double lon;
  final Geolocator geolocator = Geolocator();
  final locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

  final _positionStream =BehaviorSubject<Position>();
  Observable<Position> get pos_stream => _positionStream.stream;

  dispose() {}
  mapBlock() {

    Future<Map<PermissionGroup, PermissionStatus>> permissions =  PermissionHandler().requestPermissions([PermissionGroup.locationWhenInUse]);
    _positionStream.listen((Data){
      lat = Data.latitude;
      lon = Data.longitude;
      print("Saving class lat long");
    });

    StreamSubscription<Position> positionStream = geolocator.getPositionStream(locationOptions).listen((Position position){
      print("Block position is: ");
      print(position);
      _positionStream.add(position);
    });

  final _location = BehaviorSubject<Position>();
  // Permission Data
  }
  



  void printer() {
    print("Instantiated");
  }
}

final myblock = mapBlock();
