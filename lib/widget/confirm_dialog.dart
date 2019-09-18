import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmação do Veículo'),
      actions: [
        FlatButton(
          child: const Text('Confirmar'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        FlatButton(
          child: const Text('Ignorar'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ],
    );
  }
}
