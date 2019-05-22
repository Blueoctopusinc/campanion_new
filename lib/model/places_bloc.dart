import 'package:rxdart/rxdart.dart';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camp.dart';
class places_bloc {
  final _allPlacesSubject = BehaviorSubject<List<Camp>>();
  Observable<List<Camp>> get allPlaces => _allPlacesSubject.stream;
  String uid;

  places_bloc(String myUid) {
    this.uid= myUid;
    _getData();
  }

  dispose() {
    _allPlacesSubject.close();
  }

  _getData() {
    print('getting data');
    Firestore.instance
        .collection("users").document(this.uid).collection('sites')
        .snapshots()
        .listen((QuerySnapshot qs) {
      List<Camp> list = [];
      for (DocumentSnapshot ds in qs.documents) {
        final Camp p = Camp.fromSnapshot(ds);
        list.add(p);
        print(p);
      
      }
      list.sort();
      _allPlacesSubject.sink.add(list);
    });
  }
}
