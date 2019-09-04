import 'dart:async';

import 'package:allset/data/station_data.dart';
import 'package:allset/widget/station_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final Firestore db = Firestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

class StationsPage extends StatefulWidget {
  @override
  _StationsPageState createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  Completer<GoogleMapController> mapCompleter = Completer();

  @override
  void initState() {
    super.initState();
    LocationPermissions().requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
      future: auth.currentUser(),
      builder: (context, snapshot) {
        final userId = snapshot.hasData ? snapshot.data.uid : '';
        return StreamBuilder<QuerySnapshot>(
          stream: db.collection('/stations').snapshots(),
          builder: (context, snapshot) {
            final List<StationData> stations = !snapshot.hasData
                ? []
                : snapshot.data.documents.map((doc) {
                    doc.data['id'] = doc.documentID;
                    return StationData.fromJSON(doc.data);
                  }).toList(growable: false);

            return GoogleMap(
              myLocationEnabled: true,
              mapToolbarEnabled: false,
              onMapCreated: (newController) => mapCompleter.complete(newController),
              onLongPress: (latLng) => print(latLng),
              markers: stations.map((station) {
                final userReserved = station.reserved != null && station.reserved.documentID == userId;
                return Marker(
                  icon: userReserved ? BitmapDescriptor.defaultMarkerWithHue(300) : BitmapDescriptor.defaultMarker,
                  markerId: MarkerId(station.name),
                  position: station.position,
                  onTap: () => showDialog(context: context, builder: (context) => StationDialog(station)),
                  alpha: station.reserved == null || userReserved ? 1 : 0.5,
                  consumeTapEvents: true,
                );
              }).toSet(),
              initialCameraPosition: CameraPosition(
                target: LatLng(-22.2563022, -45.7034431),
                zoom: 14.4746,
              ),
            );
          },
        );
      },
    );
  }
}
