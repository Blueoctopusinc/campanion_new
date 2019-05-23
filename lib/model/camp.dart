import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Camp implements Comparable<Camp> {
  final String name;
  final String description;
  final String photoRef;
  final String id;
  final String lat;
  final String lon;
  final DocumentReference reference;

  int compareTo(Camp c) {
    return this.name.compareTo(c.name);
  }

  Camp({this.name, this.description, this.photoRef, this.id, this.lat, this.lon, this.reference});

  Camp.fromMap(Map<String, dynamic> map, DocumentReference reference)
      : assert(map['name'] != null),
        name = map['name'],
        description = map['description'],
        photoRef = map['photoRef'],
        lat = map['lat'],
        lon = map['lon'],
        reference = reference,
        id = reference.documentID;

  Camp.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, snapshot.reference);


}
