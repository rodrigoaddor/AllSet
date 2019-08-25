import 'package:allset/data/station_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final Firestore db = Firestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

class StationDialog extends StatelessWidget {
  final StationData station;

  StationDialog(this.station);

  void reserveStation() async {
    db.document('/stations/${station.id}').updateData({'reserved': (await auth.currentUser()).uid });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 150, horizontal: 64),
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
                  await Future.delayed(Duration(seconds: 3));
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
                          final address = '${place.thoroughfare}, Nº ${place.subThoroughfare}, ${place.subLocality}';
                          return Text(
                            address,
                            style: Theme.of(context).textTheme.body1,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ButtonBar(children: [
                  RaisedButton(
                    child: Text('Reserve'),
                    onPressed: station.hasVehicle ? null : this.reserveStation,
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
  }
}
