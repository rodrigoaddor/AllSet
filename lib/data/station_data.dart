import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLng latLngFromGeoPoint(GeoPoint geoPoint) => LatLng(geoPoint.latitude, geoPoint.longitude);

class StationData {
  final String name;
  final LatLng position;

  const StationData({this.name, this.position});

  factory StationData.fromJSON(Map<String, dynamic> json) {
    return StationData(name: json['name'], position: latLngFromGeoPoint(json['position']));
  }
}
