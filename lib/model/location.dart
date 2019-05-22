class Location {

  String locationName = '';
  String locationDescription = '';
  String photoRef;
  double lat;
  double lon;
  Location(String locationName,String locationDesc,
      String photoRef, double lat, double lon){
    this.locationName = locationName;
    this.locationDescription = locationDesc;
    this.photoRef = photoRef;
    this.lat = lat;
    this.lon = lon;
  }

}