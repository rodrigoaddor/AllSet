import 'dart:async';

import 'package:allset/data/station_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final Firestore db = Firestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

class StationDialog extends StatefulWidget {
  final StationData station;

  StationDialog(this.station);

  @override
  _StationDialogState createState() => _StationDialogState();
}

class _StationDialogState extends State<StationDialog> {
  Future reserveFuture = Future.value();

  void reserveStation() async {
    final String uid = (await auth.currentUser()).uid;
    setState(() {
      reserveFuture = db.document('/stations/${widget.station.id}').updateData({'reserved': db.document  ('/users/$uid')});
    });
  }

  void unReserveStation() async {
    setState(() {
      reserveFuture = db.document('/stations/${widget.station.id}').updateData({'reserved': FieldValue.delete()});
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: db.document('/stations/${widget.station.id}').snapshots(),
      builder: (context, snapshot) {
        final StationData station = snapshot.hasData
            ? StationData.fromJSON(snapshot.data.data..addAll({'id': snapshot.data.documentID}))
            : widget.station;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 140, horizontal: 64),
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: GoogleMap(
                    mapToolbarEnabled: false,
                    initialCameraPosition: CameraPosition(target: station.position, zoom: 9),
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    markers: Set.of([
                      Marker(
                        markerId: MarkerId('station'),
                        position: station.position,
                      )
                    ]),
                    onMapCreated: (controller) async {
                      await Future.delayed(Duration(seconds: 2));
                      try {
                        await controller.animateCamera(CameraUpdate.zoomTo(15));
                      } catch (e) {} // Doesn't need to be handled, just ignored.
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 44,
                        width: double.infinity,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            station.name,
                            style: Theme.of(context).textTheme.headline,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Address',
                            style: Theme.of(context).textTheme.body2,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: FutureBuilder<Placemark>(
                            future: Geolocator()
                                .placemarkFromPosition(Position(
                                  latitude: station.position.latitude,
                                  longitude: station.position.longitude,
                                ))
                                .then((list) => list[0]),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return LinearProgressIndicator();
                              final place = snapshot.data;
                              final address =
                                  '${place.thoroughfare}, Nº ${place.subThoroughfare}, ${place.subLocality}';
                              return Text(
                                address,
                                style: Theme.of(context).textTheme.body1,
                              );
                            },
                          ),
                        ),
                      ),
                      FutureBuilder<FirebaseUser>(
                        future: auth.currentUser(),
                        builder: (context, snapshot) {
                          return SizedBox(
                            height: 28,
                            child: snapshot.hasData &&
                                    station.reserved != null &&
                                    snapshot.data.uid == station.reserved.documentID
                                ? Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text('You reserved this station.'),
                                  )
                                : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ButtonBar(children: [
                      FutureBuilder(
                        future: Future.wait([
                          reserveFuture,
                          auth.currentUser(),
                        ]),
                        builder: (context, snapshot) {
                          print(snapshot.data);
                          final userId = snapshot.connectionState == ConnectionState.done
                              ? (snapshot.data[1] as FirebaseUser).uid
                              : '';
                          final reservedByUser = station.reserved != null && station.reserved.documentID == userId;
                          return RaisedButton(
                            onPressed: station.hasVehicle || (station.reserved != null && !reservedByUser)
                                ? null
                                : reservedByUser ? this.unReserveStation : this.reserveStation,
                            child: snapshot.connectionState == ConnectionState.done
                                ? Text(reservedByUser ? 'Cancel Reservation' : 'Reserve')
                                : SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                          );
                        },
                      ),
                      RaisedButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ]),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
