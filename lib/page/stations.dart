import 'dart:async';

import 'package:allset/data/station_data.dart';
import 'package:allset/widget/station.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final Firestore db = Firestore.instance;

class StationsPage extends StatefulWidget {
  @override
  _StationsPageState createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  Completer<GoogleMapController> mapCompleter = Completer();
  Set<StationData> stations = Set();

  @override
  void initState() {
    super.initState();
    Geolocator().checkGeolocationPermissionStatus();

    db.collection('/stations').getDocuments().then(
      (documents) {
        final List<StationData> stations = documents.documents.map((doc) {
          doc.data['id'] = doc.documentID;
          return StationData.fromJSON(doc.data);
        }).toList();

        setState(() {
          this.stations.addAll(stations);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      myLocationEnabled: true,
      onMapCreated: (newController) => mapCompleter.complete(newController),
      onTap: ((latlng) => print(latlng)),
      markers: stations
          .map((station) => Marker(
                markerId: MarkerId(station.name),
                position: station.position,
                onTap: () => showDialog(context: context, builder: (context) => StationDialog(station)),
              ))
          .toSet(),
      initialCameraPosition: CameraPosition(
        target: LatLng(-22.2563022, -45.7034431),
        zoom: 14.4746,
      ),
    );
  }
}
