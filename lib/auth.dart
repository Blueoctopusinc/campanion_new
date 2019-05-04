import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'map.dart';
import 'package:flutter/material.dart';
import 'dart:async';


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
    FirebaseUser user = await _auth.signInWithGoogle(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
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
    return ref.setData({
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoUrl,
      'displayName': user.displayName,
      'lastSeen': DateTime.now()
    }, merge: true);
  }

  void signOut() {
    _auth.signOut();
  }
}

final AuthService authService = AuthService();
