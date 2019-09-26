import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:allset/data/app_state.dart';
import 'package:allset/data/station_data.dart';
import 'package:allset/page/base_page.dart';
import 'package:allset/widget/station_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

final Firestore db = Firestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

final lightMap =
    '[{"featureType":"poi.business","stylers":[{"visibility":"off"}]},{"featureType":"poi.park","elementType":"labels.text","stylers":[{"visibility":"off"}]}]';

final darkMap =
    '[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6b9a76"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f2835"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#f3d19c"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},{"featureType":"transit.station","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]},{"featureType":"water","elementType":"labels.text.stroke","stylers":[{"color":"#17263c"}]}]';

class StationsPage extends StatefulWidget {
  @override
  _StationsPageState createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> with AfterLayoutMixin {
  Completer<GoogleMapController> mapCompleter = Completer();
  Function disposeThemeListener;

  @override
  void initState() {
    super.initState();
    LocationPermissions().requestPermissions();
  }

  @override
  void dispose() {
    if (disposeThemeListener != null) disposeThemeListener();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    mapCompleter.future.then((controller) {
      final themeState = Provider.of<ThemeState>(context);
      void setMapStyle() {
        controller.setMapStyle(themeState.themeMode == ThemeMode.light ? lightMap : darkMap);
      }

      setMapStyle();
      themeState.addListener(setMapStyle);
      if (disposeThemeListener != null) disposeThemeListener();
      disposeThemeListener = () {
        themeState.removeListener(setMapStyle);
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      route: '/stations',
      child: FutureBuilder<FirebaseUser>(
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
                onMapCreated: (controller) => mapCompleter.complete(controller),
                onLongPress: (latLng) => print(latLng),
                markers: stations.map((station) {
                  final userReserved = station.reserved != null && station.reserved.documentID == userId;
                  return Marker(
                    icon: userReserved ? BitmapDescriptor.defaultMarkerWithHue(300) : BitmapDescriptor.defaultMarker,
                    markerId: MarkerId(station.name),
                    position: station.position,
                    alpha: station.reserved == null || userReserved ? 1 : 0.5,
                    consumeTapEvents: true,
                    onTap: () => showDialog(context: context, builder: (context) => StationDialog(station)),
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
      ),
    );
  }
}
