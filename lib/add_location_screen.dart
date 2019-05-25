import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'add_location_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:campanion_new/model/map_model.dart';

class AddLocation extends StatefulWidget {
  final mapBlock mapbloc;
  final String uid;
  AddLocation({Key key, this.mapbloc, this.uid}) : super(key: key);
  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  mapBlock mapBloc;
  add_location_bloc bloc;
  static String myUID;
  @override
  void initState() {
    super.initState();
    mapBloc = widget.mapbloc;
    myUID = widget.uid;
    print(myUID);
    bloc = add_location_bloc(myUID);
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
        backgroundColor: Colors.red[400],
        title: Text(
          'Add Location',
        ),
      ),
      body: SingleChildScrollView(
              child: Column(children: <Widget>[
                               Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.red[400]],
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
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(40))),
                          
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        width: 380,
                        child: Column(
                                              children:<Widget>[StreamBuilder(
                                  stream: mapBloc.pos_stream,
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      bloc.lat.add(snapshot.data.latitude);
                                      bloc.lon.add(snapshot.data.longitude);
                                      return Container(
                                        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(20)),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                        child: Text("Latitude: ",
                                                            style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 18,
                                                                fontStyle: FontStyle
                                                                    .italic))),
                                                    Container(
                                                        child: Text(
                                                            snapshot.data.latitude
                                                                .toString(),
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.white)))
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      child: Text(
                                                        "Longitude: ",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontStyle:
                                                                FontStyle.italic),
                                                      ),
                                                    ),
                                                    Container(
                                                        child: Text(
                                                            snapshot.data.longitude
                                                                .toString(),
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.white)))
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Text("No Data");
                                              }
                                  },
                                              ),Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                   
                                  Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 10, 10),
                                          child: TextFormField(
                                            style: TextStyle(
                                                color: Colors.white, fontSize: 36),
                                            decoration: InputDecoration(
                                                labelText: 'Location Name',
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
                                            style: TextStyle(
                                                color: Colors.white, fontSize: 30),
                                            decoration: InputDecoration(
                                                labelText: 'Location Description',
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
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.green, width: 5)),
                                        height: 200,
                                        width: 400,
                                        child: Image.file(
                                          snapshot.data,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white70,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.red, width: 5)),
                                          height: 200,
                                          width: 400,
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 40.0,
                                          )),
                                    );
                                  }
                                },
                              )),
                            ),
                                 
                                      Padding(
                          padding: const EdgeInsets.only(top:50.0,bottom: 50, left: 10, right: 10),
                          child: RaisedButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30)),
                            color: Colors.indigo,
                            child: Center(
                                child: Container(
                              height: 80,
                              width: 200,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[Icon(Icons.save, color: Colors.white,size: 50,),Text("Save", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white),), ]),
                            )),
                            onPressed: () {
            final form = _formKey.currentState;
            if (form.validate()) {
                form.save();
                bloc.uploadFile();
                Navigator.pop(context);
            }},
                          ),
                      )
                                    ],
                                  ),
                                ],
                              )),
                                              ]),
                      ),
                      
                    ],
                  ),
                ),
            ),
          ),
        ),
              ]),
      ),
      
    );
  }
}
