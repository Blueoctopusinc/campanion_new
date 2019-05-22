import 'package:flutter/material.dart';
import 'package:campanion_new/model/map_model.dart';
class LocationAdder extends StatefulWidget{
  final mapBlock mybloc;
  LocationAdder({Key key, this.mybloc}) : super(key: key);

  @override
  State<LocationAdder> createState() => new LocationAdderState();
}
class LocationAdderState extends State<LocationAdder>{
  mapBlock bloc;
  @override void initState() {
    // TODO: implement initState
    super.initState();
    bloc =widget.mybloc;
  }

  @override
  Widget build(BuildContext context) {
    print("Building Location adder");
    bloc.pos_stream.listen(print);
    return StreamBuilder(
      stream: bloc.pos_stream ,
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.hasData){
          return Container(
          child: Text(snapshot.data.toString()),
        );
        }else{
          print("no data");
          return Text("NOPE");
        }
        
      },
    );
  }
}