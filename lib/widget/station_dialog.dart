import 'dart:async';

import 'package:allset/data/station_data.dart';
import 'package:allset/data/user_data.dart';
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
  Future reserveTask = Future.value();

  void reserveStation(StationData station) async {
    final String uid = (await auth.currentUser()).uid;
    final userRef = db.document('/users/$uid');
    final stationRef = db.document('/stations/${station.id}');
    final Completer task = Completer();
    setState(() {
      reserveTask = task.future;
    });
    await userRef.updateData({'reserved': stationRef});
    await stationRef.updateData({'reserved': userRef});
    task.complete();
  }

  void unReserveStation(StationData station) async {
    final String uid = (await auth.currentUser()).uid;
    final userRef = db.document('/users/$uid');
    final stationRef = db.document('/stations/${station.id}');
    final Completer task = Completer();
    setState(() {
      reserveTask = task.future;
    });
    await stationRef.updateData({'reserved': FieldValue.delete()});
    await userRef.updateData({'reserved': FieldValue.delete()});
    task.complete();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
        future: auth.currentUser(),
        builder: (context, snapshot) {
          final userId = snapshot.hasData ? snapshot.data.uid : '';
          return StreamBuilder<DocumentSnapshot>(
            stream: db.document('/stations/${widget.station.id}').snapshots(),
            builder: (context, snapshot) {
              final StationData station = snapshot.hasData
                  ? StationData.fromJSON(snapshot.data.data..addAll({'id': snapshot.data.documentID}))
                  : widget.station;

              final userReserved = station.reserved != null && station.reserved.documentID == userId;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 32),
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
                                icon: userReserved
                                    ? BitmapDescriptor.defaultMarkerWithHue(300)
                                    : BitmapDescriptor.defaultMarker)
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
                              height: 36,
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
                            SizedBox(
                              height: 28,
                              child: station.reserved != null
                                  ? Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        snapshot.hasData && station.reserved.documentID == userId
                                            ? 'Você reservou essa estação.'
                                            : 'Essa estação já está reservada.',
                                      ),
                                    )
                                  : null,
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
                                reserveTask,
                                auth.currentUser(),
                              ]),
                              builder: (context, snapshot) {
                                final userId = snapshot.connectionState == ConnectionState.done && snapshot.hasData
                                    ? (snapshot.data[1] as FirebaseUser).uid
                                    : '';
                                final reservedByUser =
                                    station.reserved != null && station.reserved.documentID == userId;
                                return StreamBuilder<DocumentSnapshot>(
                                    stream:
                                        userId.length > 0 ? db.document('/users/$userId').snapshots() : Stream.empty(),
                                    builder: (context, userSnapshot) {
                                      final userData =
                                          UserData.fromJson(userSnapshot.hasData ? userSnapshot.data.data : {});
                                      final userHasReservation = userData.reserved != null;
                                      return RaisedButton(
                                        onPressed: (userHasReservation && !reservedByUser) ||
                                                station.hasVehicle ||
                                                (station.reserved != null && !reservedByUser)
                                            ? null
                                            : reservedByUser
                                                ? () => this.unReserveStation(station)
                                                : () => this.reserveStation(station),
                                        child: snapshot.connectionState == ConnectionState.done
                                            ? Text(reservedByUser ? 'Cancelar Reserva' : 'Reservar')
                                            : SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              ),
                                      );
                                    });
                              },
                            ),
                            RaisedButton(
                              child: Text('Fechar'),
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
        });
  }
}
