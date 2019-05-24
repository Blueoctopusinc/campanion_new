import 'package:rxdart/rxdart.dart';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camp.dart';
import 'package:campanion_new/auth.dart';
class places_bloc {
  final _allPlacesSubject = BehaviorSubject<List<Camp>>();
  Observable<List<Camp>> get allPlaces => _allPlacesSubject.stream;

  places_bloc() {
    _getData();
  }

  dispose() {
    _allPlacesSubject.close();
  }

  _getData() {
    Firestore.instance
        .collection("users").document(authService.uid).collection("sites")
        .snapshots()
        .listen((QuerySnapshot qs) {
      List<Camp> list = [];
      for (DocumentSnapshot ds in qs.documents) {
        final Camp p = Camp.fromSnapshot(ds);
        list.add(p);
      
      }
      list.sort();
      _allPlacesSubject.sink.add(list);
    });
  }
}
