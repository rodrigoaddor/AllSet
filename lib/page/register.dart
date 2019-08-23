import 'package:allset/theme.dart';
import 'package:allset/utils/upperformatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final Firestore db = Firestore.instance;
final FirebaseMessaging msg = FirebaseMessaging();

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final plateController = MaskedTextController(mask: 'AAA-0000');
  bool hasValidPlate = false;

  void handleRegister() async {
    await db
        .document('/plates/${plateController.text.toUpperCase()}')
        .setData({'user': db.document('/users/${(await auth.currentUser()).uid}')});

    if (Navigator.canPop(context))
      Navigator.pop(context);
    else
      Navigator.pushReplacementNamed(context, '/');
  }

  void handlePlateValidation() {
    setState(() {
      if (plateController.text.length == 8)
        hasValidPlate = true;
      else
        hasValidPlate = false;
    });
  }

  @override
  void initState() {
    super.initState();
    plateController.addListener(this.handlePlateValidation);

    (() async {
      if (await auth.currentUser() != null) await auth.signOut();

      final authResult = await auth.signInAnonymously();
      db.document('/users/${authResult.user.uid}').setData({'token': await msg.getToken()}, merge: true);
    })();
  }

  @override
  void dispose() {
    plateController.removeListener(this.handlePlateValidation);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildRegisterTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: this.hasValidPlate ? null : Colors.grey[350],
          label: const Text('Register'),
          onPressed: this.hasValidPlate ? handleRegister : null,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          child: SizedBox(height: 36),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(64, 24, 64, 0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Vehicle Plate',
                ),
                controller: plateController,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
