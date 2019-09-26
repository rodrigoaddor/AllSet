import 'package:allset/data/station_data.dart';
import 'package:flutter/material.dart';

class StationSheet extends StatefulWidget {
  final StationData station;

  StationSheet(this.station);

  @override
  _StationSheetState createState() => _StationSheetState();
}

class _StationSheetState extends State<StationSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 128),
      child: SizedBox(
        width: double.infinity,
        height: 300,
        child: Center(
          child: Text('hey'),
        ),
      ),
    );
  }
}
