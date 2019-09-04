import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:allset/data/payment_data.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final Firestore db = Firestore.instance;

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final priceController = MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  final chargeController = TextEditingController();

  final priceFocus = FocusNode();
  final chargeFocus = FocusNode();

  Future saveTask = Future.value();

  @override
  void initState() {
    super.initState();

    priceFocus.addListener(() {
      chargeController.clear();
    });

    chargeFocus.addListener(() {
      priceController.updateValue(0);
    });
  }

  @override
  void dispose() {
    priceController.dispose();
    chargeController.dispose();
    priceFocus.dispose();
    chargeFocus.dispose();

    super.dispose();
  }

  String validateCharge(String input) {
    try {
      if (input.length == 0) return null;
      final value = double.parse(input);
      if (value == 0 || value > 100) return 'Carga deve estar entre 0% e 100%';
      return null;
    } on FormatException {
      return 'Número inválido';
    }
  }

  String validatePrice(_) {
    final value = priceController.numberValue;
    if (value <= 0) return 'Preço deve ser maior que 0';
    return null;
  }

  void saveValue() async {
    final task = new Completer();
    setState(() {
      this.saveTask = task.future;
    });

    final paymentType = priceController.numberValue > 0 ? PaymentType.PRICE : PaymentType.CHARGE;

    final paymentData = PaymentData(
      paymentType,
      paymentType == PaymentType.PRICE ? priceController.numberValue : double.tryParse(chargeController.text) ?? -1,
    );

    await db.document('/users/${(await auth.currentUser()).uid}').setData(
      {'payment': paymentData.toJson()},
      merge: true,
    );

    task.complete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
          child: TextFormField(
            controller: priceController,
            focusNode: priceFocus,
            keyboardType: TextInputType.number,
            validator: priceFocus.hasPrimaryFocus ? validatePrice : (_) => null,
            autovalidate: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              labelText: 'Preço',
              prefix: const Text('R\$ '),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 48, right: 24),
                child: Divider(),
              ),
            ),
            Text('OU'),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 24, right: 48),
                child: Divider(),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
          child: TextFormField(
            controller: chargeController,
            focusNode: chargeFocus,
            keyboardType: TextInputType.number,
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            validator: validateCharge,
            autovalidate: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              labelText: 'Carga',
              suffix: const Text(' %'),
              errorMaxLines: 2,
            ),
          ),
        ),
        RaisedButton(
          onPressed: saveValue,
          child: FutureBuilder(
            future: this.saveTask,
            builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
                ? Text('Salvar')
                : SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
          ),
        )
      ],
    );
  }
}
