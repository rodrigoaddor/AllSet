import 'dart:async';

import 'package:flutter/material.dart';

import 'package:allset/data/app_state.dart';
import 'package:allset/data/user_data.dart';
import 'package:allset/data/station_data.dart';

import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

Firestore db = Firestore.instance;

class StationSheet extends StatefulWidget {
  final StationData station;

  StationSheet(this.station);

  @override
  _StationSheetState createState() => _StationSheetState();
}

class _StationSheetState extends State<StationSheet> with AfterLayoutMixin, TickerProviderStateMixin {
  StreamSubscription stationSubscription;
  StreamSubscription userSubscription;
  StationData station;
  UserData userData;
  Completer reserving;

  @override
  void initState() {
    super.initState();
    station = widget.station;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    stationSubscription = db.document('/stations/${station.id}').snapshots().listen((snapshot) {
      setState(() {
        station = StationData.fromJSON(snapshot.data..addAll({'id': snapshot.documentID}));
      });
    });

    userSubscription = db.document('/users/${Provider.of<UserState>(context).userID}').snapshots().listen((snapshot) {
      setState(() {
        userData = UserData.fromJson(snapshot.data);
      });
    });
  }

  @override
  void dispose() {
    if (stationSubscription != null) stationSubscription.cancel();
    if (userSubscription != null) userSubscription.cancel();
    super.dispose();
  }

  void handleReservation(BuildContext context) async {
    final userID = Provider.of<UserState>(context).userID;
    final userRef = db.document('/users/$userID');
    final stationRef = db.document('/stations/${station.id}');

    setState(() {
      reserving = Completer();
    });

    if (station.reserved != null && station.reserved.documentID == userID) {
      await stationRef.updateData({'reserved': FieldValue.delete()});
      await userRef.updateData({'reserved': FieldValue.delete()});
    } else if (station.reserved == null) {
      await userRef.updateData({'reserved': stationRef});
      await stationRef.updateData({'reserved': userRef});
    }

    setState(() => reserving.complete());
  }

  @override
  Widget build(BuildContext context) {
    final userID = Provider.of<UserState>(context).userID;
    final userReserve = userData?.reserved?.documentID;
    final stationReserve = station?.reserved?.documentID;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.station.name,
              style: Theme.of(context).textTheme.headline,
            ),
            FutureBuilder<Placemark>(
              future: Geolocator()
                  .placemarkFromPosition(Position(
                    latitude: widget.station.position.latitude,
                    longitude: widget.station.position.longitude,
                  ))
                  .then((list) => list[0]),
              builder: (context, snapshot) {
                final place = snapshot.data;
                final address =
                    snapshot.hasData ? '${place.thoroughfare}, Nº ${place.subThoroughfare}, ${place.subLocality}' : '';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Endereço: $address',
                  ),
                );
              },
            ),
            AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 300),
              alignment: Alignment.topLeft,
              child: station.reserved == null
                  ? SizedBox(width: double.infinity)
                  : Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        station.reserved.documentID == userID
                            ? 'Você reservou essa estação.'
                            : 'Essa estação já está reservada.',
                      ),
                    ),
            ),
            ButtonBar(
              children: [
                RaisedButton(
                  child: AnimatedSize(
                    vsync: this,
                    duration: Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    child: FutureBuilder(
                      future: reserving != null ? reserving.future : Future.value(),
                      builder: (context, snapshot) {
                        return snapshot.connectionState == ConnectionState.done
                            ? Text(station.reserved != null && station.reserved.documentID == userID
                                ? 'Cancelar Reserva'
                                : 'Reservar Estação')
                            : SizedBox.fromSize(
                                size: Size.square(20),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              );
                      },
                    ),
                  ),
                  onPressed: ((userReserve == null && stationReserve == null) || stationReserve == userID) &&
                          (reserving == null || reserving.isCompleted)
                      ? () => handleReservation(context)
                      : null,
                ),
                RaisedButton(
                  child: const Text('Fechar'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
