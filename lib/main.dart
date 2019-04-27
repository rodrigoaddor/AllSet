import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AllSet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final double percent = 0.66;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AllSet App'),
      ),
      body: Center(
        child: CircularPercentIndicator(
          radius: 350,
          lineWidth: 20,
          animation: true,
          percent: this.percent,
          circularStrokeCap: CircularStrokeCap.round,
          center: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.2,
                child: Icon(
                  FontAwesomeIcons.bolt,
                  size: 240,
                  color: Colors.black,
                ),
              ),
              Text(
                (this.percent * 100).floor().toString() + '%',
                style:
                    TextStyle(fontFamily: 'OpenSans', fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
