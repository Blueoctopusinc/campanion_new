import 'dart:async';
import 'package:location_permissions/location_permissions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class mapBlock {
  double lat;
  double lon;
  final Geolocator geolocator = Geolocator();
  final locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

  final _locationLayer = BehaviorSubject<PermissionStatus>();
  Observable<PermissionStatus> get loc_layer => _locationLayer.stream;

  final _positionStream =BehaviorSubject<Position>();
  Observable<Position> get pos_stream => _positionStream.stream;

  dispose() {}
  mapBlock() {
    _positionStream.listen((Data){
      lat = Data.latitude;
      lon = Data.longitude;
      print("Saving class lat long");
    });
    _locationLayer.stream.listen(print);
    Future<PermissionStatus> permission = LocationPermissions()
        .requestPermissions()
        .then((PermissionStatus permissionStat) {
          _locationLayer.add(permissionStat);
          print("map block permissions Set");
        });
    StreamSubscription<Position> positionStream = geolocator.getPositionStream(locationOptions).listen((Position position){
      print("Block position is: ");
      print(position);
      _positionStream.add(position);
    });
  }
  final _loc_perm = BehaviorSubject<PermissionStatus>();
  Observable<PermissionStatus> get perm_stat => _loc_perm.stream; // =

  final _location = BehaviorSubject<Position>();
  // Permission Data
  
  



  void printer() {
    print("Instantiated");
  }
}

final myblock = mapBlock();
