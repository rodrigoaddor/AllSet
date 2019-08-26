import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLng latLngFromGeoPoint(GeoPoint geoPoint) => LatLng(geoPoint.latitude, geoPoint.longitude);

class StationData {
  final String id;
  final String name;
  final LatLng position;
  final bool hasVehicle;
  final DocumentReference reserved;

  const StationData({this.id, this.name, this.position, this.hasVehicle, this.reserved});

  factory StationData.fromJSON(Map<String, dynamic> json) {
    return StationData(
      id: json['id'],
      name: json['name'],
      position: latLngFromGeoPoint(json['position']),
      hasVehicle: json['hasVehicle'],
      reserved: json['reserved'],
    );
  }
}
