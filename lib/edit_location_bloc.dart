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
import 'package:campanion_new/model/camp.dart';
class edit_location_bloc{

   bool imageChanged = false;
   
   String _uid;
   File _image;
   Firestore db = Firestore.instance;
   FirebaseStorage _storage = FirebaseStorage.instance;
    Camp c;
   String locationName;
   String locationDescription;
   String lati;
   String long;
   String imageRef;
   DocumentReference docref;

   BehaviorSubject<String> locName = new BehaviorSubject<String>();
   BehaviorSubject<String> locDec = new BehaviorSubject<String>();
   BehaviorSubject<String> photoRef = new BehaviorSubject<String>();
   BehaviorSubject<double> lat = new BehaviorSubject<double>();
   BehaviorSubject<double> lon = new BehaviorSubject<double>();
   BehaviorSubject<File> bsubject = new BehaviorSubject<File>();


  edit_location_bloc(String id, Camp camp){
    this._uid = id;
    print(this._uid);
    
    c = camp;
    docref = c.reference;
    print(docref.documentID+"Doc ref");
    photoRef.add(c.photoRef);

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
    if(imageChanged == true){
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
    }
    create(this.imageRef);
      }
  Future<Null> create(String url) async{
    final TransactionHandler myTransaction = (Transaction tx) async {
      print(this._uid);
      final DocumentSnapshot ds = await docref.get();
      var locMap = new Map<String,dynamic>();
      locMap['name']=this.locationName;
      locMap['description']=this.locationDescription;
      locMap['photoRef']=url;
  
      
      await tx.update(ds.reference, locMap);

      return locMap;

    };
    return Firestore.instance.runTransaction(myTransaction).then((mapData) {
      print(mapData);
    });
    }


   Future getImage() async {
     imageChanged=true;
     var image = await ImagePicker.pickImage(source: ImageSource.camera);
     bsubject.add(image);
     _image = image;

     //_saveData() {
    //Firestore.instance
      //  .collection("users")
        //.document(_uid).collection("sites").add(data)
  }
}
