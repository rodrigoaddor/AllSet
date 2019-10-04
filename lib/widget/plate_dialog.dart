import 'dart:async';

import 'package:flutter/material.dart';

import 'package:allset/data/app_state.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

final db = Firestore.instance;

class PlateDialog extends StatefulWidget {
  @override
  _PlateDialogState createState() => _PlateDialogState();
}

class _PlateDialogState extends State<PlateDialog> {
  TextEditingController textController = TextEditingController();
  Completer loading;

  void savePlate(BuildContext context) async {
    setState(() {
      loading = Completer();
    });

    await db.document('/users/${Provider.of<UserState>(context).userID}').setData(
      {'plate': textController.text},
      merge: true,
    );

    Navigator.pop(context);
  }

  bool hasText() => textController.text.length > 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastro de Placa'),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: TextField(
          textAlign: TextAlign.center,
          autofocus: true,
          controller: textController,
          onChanged: (_) => setState(() {}),
          inputFormatters: [LengthLimitingTextInputFormatter(7)],
          decoration: InputDecoration(
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            hintText: 'ABC1234',
          ),
        ),
      ),
      actions: [
        FlatButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        RaisedButton(
          child: (loading == null || loading.isCompleted)
              ? Text('Salvar')
              : SizedBox.fromSize(
                  size: Size.square(20),
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
                ),
          color: Colors.red[700],
          textColor: Colors.white,
          onPressed: (loading == null || loading.isCompleted) && hasText() ? () => savePlate(context) : null,
        ),
      ],
    );
  }
}
