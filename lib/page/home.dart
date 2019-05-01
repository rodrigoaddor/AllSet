import 'package:AllSet/data/userData.dart';
import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

Firestore firestore = Firestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage>, SingleTickerProviderStateMixin<HomePage> {
  bool firstBuild = true;
  FirebaseUser currentUser;
  double lastPercentage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    final FirebaseUser user = await auth.currentUser();
    setState(() => currentUser = user);
    if (user == null) {
      Navigator.pushNamed(context, '/qr');
    } else {
      final DocumentSnapshot userData = await firestore.document('/users/${user.uid}').get();
      if (!userData.exists) {
        Navigator.pushNamed(context, '/qr');
      }
    }

    this.firstBuild = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AllSet',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: this.currentUser == null
            ? CircularProgressIndicator()
            : StreamBuilder<DocumentSnapshot>(
                stream: firestore.document('/users/${this.currentUser.uid}').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data.exists) {
                    return CircularProgressIndicator();
                  } else {
                    final userData = UserData.fromMap(snapshot.data.data);

                    return CircularPercentIndicator(
                      percent: userData.percent,
                      center: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (userData.charging) ...[
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
                            userData.hPercent,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Color.fromRGBO(255, 255, 255, 0.06),
                      circularStrokeCap: CircularStrokeCap.round,
                      radius: 300,
                      lineWidth: 16,
                      animation: true,
                      animationDuration: 300,
                      animateFromLastPercent: true,
                    );
                  }
                },
              ),
      ),
    );
  }
}
