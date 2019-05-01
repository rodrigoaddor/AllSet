import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final Firestore firestore = Firestore.instance;

class QRPage extends StatefulWidget {
  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> with AfterLayoutMixin<QRPage> {
  FirebaseUser currentUser;

  @override
  void afterFirstLayout(BuildContext context) async {
    final FirebaseUser newUser = await auth.signInAnonymously();
    setState(() => currentUser = newUser);

    final Stream<DocumentSnapshot> firestoreStream = firestore.document('/users/${this.currentUser.uid}').snapshots();
    await for (final snapshot in firestoreStream) {
      if (snapshot.exists) {
        Navigator.pop(context);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Builder(
        builder: (context) => Center(
              child: currentUser == null
                  ? CircularProgressIndicator()
                  : GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: currentUser.uid,
                          ),
                        );
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('User ID copied to clipboard'),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(32),
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImage(
                          data: currentUser.uid,
                        ),
                      ),
                    ),
            ),
      ),
    );
  }
}
