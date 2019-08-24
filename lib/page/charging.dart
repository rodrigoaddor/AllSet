import 'package:allset/data/user_data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ChargingPage extends StatefulWidget {
  final UserData userData;

  ChargingPage(this.userData);

  @override
  _ChargingPageState createState() => _ChargingPageState();
}

class _ChargingPageState extends State<ChargingPage> with SingleTickerProviderStateMixin<ChargingPage> {
  AnimationController fadeController;
  Animation fadeAnimation;

  @override
  void initState() {
    super.initState();
    fadeController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    fadeAnimation = Tween(begin: 0.2, end: 0.7).chain(CurveTween(curve: Curves.easeInOut)).animate(fadeController);
    fadeController.repeat(reverse: true);
  }

  Widget buildIdle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No vehicle found!',
          style: TextStyle(fontSize: 30),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Icon(
              FontAwesomeIcons.chargingStation,
              size: 150,
              color: Colors.grey[800],
            ),
          ),
        ),
        Text(
          'Plug in your vehicle to start using Allset.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget buildChargeIndicator() {
    return CircularPercentIndicator(
      percent: widget.userData.percent,
      progressColor: Color.lerp(Colors.red[900], Colors.green[900], widget.userData.percent),
      backgroundColor: Color.fromRGBO(255, 255, 255, 0.06),
      circularStrokeCap: CircularStrokeCap.round,
      radius: 300,
      lineWidth: 16,
      animation: true,
      animationDuration: 300,
      animateFromLastPercent: true,
      center: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.userData.charging) ...[
            Padding(
              padding: EdgeInsets.only(top: 8, left: 10),
              child: Icon(
                FontAwesomeIcons.bolt,
                size: 190,
                color: Color.fromRGBO(255, 255, 255, 0.06),
              ),
            ),
          ],
          Text(
            widget.userData.hPercent,
            style: TextStyle(
              fontSize: 36,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.userData.hasVehicle ? buildChargeIndicator() : buildIdle();
  }
}
