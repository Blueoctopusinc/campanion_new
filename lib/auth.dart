import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'map.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:campanion_new/places.dart';
import 'add_location_screen.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  final subject =  BehaviorSubject<Map<String,dynamic>>();
  Observable<FirebaseUser> user;
  Observable<Map<String, dynamic>> profile;
  PublishSubject loading = PublishSubject();
  PublishSubject myPublisher = PublishSubject();
  Stream<Map<String, dynamic>> userStream = Stream.empty();
  String eMail;
  String displayName;
  String profilePhoto;
  String uid;

  AuthService() {
    user = Observable(_auth.onAuthStateChanged);

    profile = user.switchMap((FirebaseUser u) {
      if (u != null) {
        myPublisher.add(_db.collection('users').document(u.uid).snapshots().map((snap) => snap.data));
        subject.addStream(_db.collection('users').document(u.uid).snapshots().map((snap) => snap.data));
        print("CHECK BELOW PRINT********************************");
        print(_db.collection('users').document(u.uid).snapshots().map((snap) => snap.data));
        return _db.collection('users').document(u.uid).snapshots().map((snap) => snap.data);

      } else {
        return Observable.just({});
      }
    });

  }
  Future<FirebaseUser> googleSignIn(context) async {
    loading.add(true);
    print("here at sign in");
    GoogleSignInAccount googleUsers = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUsers.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    
    FirebaseUser user = await _auth.signInWithCredential(credential);
    updateUserData(user);
    print("signed in as " + user.displayName);
    loading.add(false);
    if(user != null){
      Navigator.push(context, MaterialPageRoute(builder: (context) => mapScreen()));
    }else{
      final snackBar = SnackBar(content: Text('Google Login Failed'));
      context.showSnackBar(snackBar);
    }
    return user;
  }

  void updateUserData(FirebaseUser user) async {
    DocumentReference ref = _db.collection('users').document(user.uid);
    this.displayName = user.displayName;
    this.eMail = user.email;
    this.profilePhoto = user.photoUrl;
    this.uid = user.uid;
    return ref.setData({
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoUrl,
      'displayName': user.displayName,
      'lastSeen': DateTime.now()
    }, merge: true);
  }

  void signOut(context) {
    _auth.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => authButtons()));
  }
}

final AuthService authService = AuthService();
