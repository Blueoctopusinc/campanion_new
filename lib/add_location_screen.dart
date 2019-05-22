import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'add_location_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:campanion_new/model/map_model.dart';
import 'add_location_bloc.dart';

class AddLocation extends StatefulWidget {
  final mapBlock mapbloc;
  final String uid;
  AddLocation({Key key, this.mapbloc, this.uid}) : super(key: key);

  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  mapBlock mapBloc;

  static String myUID;
  @override
  void initState() {
    super.initState();
    mapBloc = widget.mapbloc;
    myUID = widget.uid;
  }

  final bloc = add_location_bloc(myUID);
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
        title: Text('Add Location'),
      ),
      body: Center(
        child: Container(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    bloc.getImage();
                  },
                  child: Container(
                      child: StreamBuilder<File>(
                    stream: bloc.bsubject.stream,
                    builder:
                        (BuildContext context, AsyncSnapshot<File> snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          height: 200,
                          width: 400,
                          child: Image.file(snapshot.data),
                          );
                      } else {
                        return Container(
                        color: Colors.grey,
                        height: 200,
                          width: 400,
                          child: Icon(
                          Icons.camera_alt,
                          size: 40.0,
                        ));
                        }
                    },
                  )),
                ),
              ),
              Container(
                width: 380,
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Text(myUID),
                        StreamBuilder(
                          stream: mapBloc.pos_stream,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              bloc.lat.add(snapshot.data.latitude);
                              bloc.lon.add(snapshot.data.longitude);
                              return Text(snapshot.data.toString());
                            } else {
                              return Text("No Data");
                            }
                          },
                        ),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Location Name'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a location name.';
                            }
                          },onSaved:(value){ bloc.locName.add(value);},
                        ),
                        TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Location Description'), onSaved: (value){
                              bloc.locDec.add(value);

                        },),

                      ],
                    )),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final form = _formKey.currentState;
          if (form.validate()) {
            form.save();
            bloc.uploadFile();
            Navigator.pop(context);

          }
        },
        tooltip: 'Pick Image',
        child: Icon(Icons.save),
      ),
    );
  }
}
