import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'edit_location_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:campanion_new/model/map_model.dart';
import 'package:campanion_new/model/camp.dart';
import 'package:cached_network_image/cached_network_image.dart';
class EditLocation extends StatefulWidget {
  final String uid;
  Camp c;
  EditLocation({Key key, this.c, this.uid}) : super(key: key);
  @override
  _EditLocationState createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
  
  Camp c;
  edit_location_bloc bloc;
  static String myUID;
  @override
  void initState() {
    super.initState();
    myUID = widget.uid;
    print(myUID);
    c = widget.c;
        bloc = edit_location_bloc(myUID, c);

  }

  final _formKey = GlobalKey<FormState>();
  File _image;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        title: Text(
          'Edit Location',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.indigo, Colors.green[400]],
                      begin: const FractionalOffset(0.5, 0.0),
                      end: const FractionalOffset(0.0, 0.7),
                      stops: [0.3, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Column(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40))),
                        ),
                      ),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          width: 380,
                          child: Column(children: <Widget>[
                            Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 0, 10, 10),
                                            child: TextFormField(
                                              initialValue: c.name,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 36),
                                              decoration: InputDecoration(
                                                  labelText: "Location Name",
                                                  labelStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 28)),
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Please enter a location name.';
                                                }
                                              },
                                              onSaved: (value) {
                                                bloc.locName.add(value);
                                              },
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 0, 10, 10),
                                            child: TextFormField(
                                              
                                              initialValue: c.description,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30),
                                              decoration: InputDecoration(
                                                  labelText:
                                                      'Location Description',
                                                  labelStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 28)),
                                              onSaved: (value) {
                                                bloc.locDec.add(value);
                                              },
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            bloc.getImage();
                                          },
                                          child: Container(
                                              child: StreamBuilder<File>(
                                            stream: bloc.bsubject.stream,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<File> snapshot) {
                                              if (snapshot.hasData) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    
                                                    child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                                                          child: Image.file(
                                                        snapshot.data,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child:  ClipRRect(borderRadius: BorderRadius.all(Radius.circular(20)),child: CachedNetworkImage(imageUrl: c.photoRef,)),
                                                );
                                              }
                                            },
                                          )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 50.0,
                                              bottom: 50,
                                              left: 10,
                                              right: 10),
                                          child: RaisedButton(
                                            shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30)),
                                            color: Colors.indigo,
                                            child: Center(
                                                child: Container(
                                              height: 80,
                                              width: 200,
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.save,
                                                      color: Colors.white,
                                                      size: 50,
                                                    ),
                                                    Text(
                                                      "Save",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 26,
                                                          color: Colors.white),
                                                    ),
                                                  ]),
                                            )),
                                            onPressed: () {
                                              final form =
                                                  _formKey.currentState;
                                              if (form.validate()) {
                                                form.save();
                                                bloc.uploadFile();
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )),
                          ]))
                    ]),
                  ),
                )))
          ],
        ),
      ),
    );
  }
}
