import 'package:rxdart/rxdart.dart';
import 'model/location.dart';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geocoder/geocoder.dart';
class add_location_bloc {
   String _uid;
   File _image;
   Firestore db = Firestore.instance;
   FirebaseStorage _storage = FirebaseStorage.instance;

   String locationName;
   String locationDescription;
   String lati;
   String long;
   String imageRef;


   BehaviorSubject<String> locName = new BehaviorSubject<String>();
   BehaviorSubject<String> locDec = new BehaviorSubject<String>();
   BehaviorSubject<String> photoRef = new BehaviorSubject<String>();
   BehaviorSubject<double> lat = new BehaviorSubject<double>();
   BehaviorSubject<double> lon = new BehaviorSubject<double>();
   BehaviorSubject<File> bsubject = new BehaviorSubject<File>();
   BehaviorSubject<Coordinates> coordSubject = new BehaviorSubject<Coordinates>();
   BehaviorSubject<List<Address>> addressSubj = new BehaviorSubject<List<Address>>();
  add_location_bloc(String id){
    this._uid = id;
    print(this._uid);
    print("Above was my id");
    
  

    coordSubject.listen((data)async{
      var addresses = await Geocoder.local.findAddressesFromCoordinates(data);
      addressSubj.add(addresses);
    });
    locName.listen((data){
      print(data);
      this.locationName = data;
    });

    locDec.listen((data){
      this.locationDescription = data;
    }
    );
    photoRef.listen((data){
      print(data);
      this.imageRef = data;
    });
    lat.listen((data){
      print(data);
      this.lati = data.toString();
    });
    lon.listen((data){
      print(data);
      this.long = data.toString();
    });
  }


  Future<Null> uploadFile() async {
    String filep = _image.path;
    Uuid imageUUID = new Uuid();
    final ByteData bytes = await rootBundle.load(filep);
    final Directory tempDir = Directory.systemTemp;
    final String fileName = "${imageUUID.v1()}.jpg";
    final File file = File('${tempDir.path}/$fileName');
    file.writeAsBytes(bytes.buffer.asInt8List(), mode: FileMode.write);

    final StorageReference ref = _storage.ref().child(fileName);
    final StorageUploadTask task = ref.putFile(file);
    var downurl = await(await task.onComplete).ref.getDownloadURL();
    this.imageRef = downurl.toString();
    print(downurl.toString());
    create(this.imageRef);
      }
  Future<Null> create(String url) async{
    final TransactionHandler myTransaction = (Transaction tx) async {
      print(this._uid);
      final DocumentSnapshot ds = await tx.get(db.collection('users').document(this._uid).collection('sites').document());
      var locMap = new Map<String,dynamic>();
      locMap['name']=this.locationName;
      locMap['description']=this.locationDescription;
      locMap['photoRef']=url;
      locMap['lat']=this.lati;
      locMap['lon']=this.long;
      
      await tx.set(ds.reference, locMap);

      return locMap;

    };
    return Firestore.instance.runTransaction(myTransaction).then((mapData) {
      print(mapData);
    });
    }


   Future getImage() async {
     var image = await ImagePicker.pickImage(source: ImageSource.camera);
     bsubject.add(image);
     _image = image;

     //_saveData() {
    //Firestore.instance
      //  .collection("users")
        //.document(_uid).collection("sites").add(data)
  }
}