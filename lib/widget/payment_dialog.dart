import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:allset/data/user_data.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:allset/data/payment_data.dart';
import 'package:allset/data/app_state.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

final db = Firestore.instance;

class PaymentDialog extends StatefulWidget {
  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> with TickerProviderStateMixin, AfterLayoutMixin {
  TextEditingController paymentController = TextEditingController();
  PaymentType paymentType;
  Completer loading;

  void setPaymentType(PaymentType type) {
    setState(() {
      paymentType = type;
      paymentController.clear();
    });
  }

  void savePayment(BuildContext context) async {
    setState(() {
      loading = Completer();
    });

    final data = PaymentData(paymentType, double.parse(paymentController.text.replaceAll(',', '.')));

    await db
        .document('/users/${Provider.of<UserState>(context).userID}')
        .setData({'payment': data.toJson()}, merge: true);

    Navigator.pop(context);
  }

  String inputValidator(String input) {
    if (input.length == 0) return null;

    try {
      final value = double.parse(input.replaceAll(',', '.'));
      if (paymentType == PaymentType.CHARGE && value > 100) return 'Valor deve estar entre 0 e 100.';
      return null;
    } on FormatException {
      return 'Valor inválido.';
    }
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    final query = await db.document('/users/${Provider.of<UserState>(context).userID}').get();
    if (!query.exists) return;

    final userData = UserData.fromJson(query.data);
    if (userData.payment != null) {
      setState(() {
        paymentType = userData.payment.type;
        paymentController.text = userData.payment.value.toStringAsFixed(2).replaceAll('.', ',');
      });
    }
  }

  Widget generateRadioButton(PaymentType type, IconData icon, {String text, bool reversed = false}) {
    final buttonPadding = paymentType == type ? EdgeInsets.fromLTRB(8, 6, 12, 6) : EdgeInsets.fromLTRB(8, 6, 4, 6);
    final children = [
      Icon(icon),
      if (text != null) ...[
        SizedBox(width: 4),
        SizedBox(
          width: paymentType != type ? 0 : null,
          child: Text(
            text,
            overflow: TextOverflow.clip,
            maxLines: 1,
          ),
        ),
      ],
    ];

    return AnimatedContainer(
      decoration: BoxDecoration(
        border: paymentType == type ? Border.all() : Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      duration: Duration(milliseconds: 350),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: !reversed ? buttonPadding : buttonPadding.flipped,
          child: AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: !reversed ? Alignment.centerLeft : Alignment.centerRight,
            vsync: this,
            child: Row(
              children: !reversed ? children : children.reversed.toList(growable: false),
            ),
          ),
        ),
        onTap: () => setPaymentType(type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pagamento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              generateRadioButton(PaymentType.CHARGE, FontAwesomeIcons.percentage, text: 'Carga'),
              generateRadioButton(PaymentType.PRICE, FontAwesomeIcons.dollarSign, text: 'Preço', reversed: true),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
            child: SizedBox(
              width: 200,
              child: TextFormField(
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: paymentController,
                enabled: paymentType != null,
                readOnly: paymentType == null,
                autovalidate: true,
                validator: inputValidator,
                onChanged: (_) => setState(() {}),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(paymentType == PaymentType.CHARGE ? 3 : 6),
                  WhitelistingTextInputFormatter(RegExp('[0-9,]')),
                ],
                decoration: InputDecoration(
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  hintText: paymentType == null ? 'Pagamento' : paymentType == PaymentType.CHARGE ? '100' : '9,99',
                  suffixText: paymentType == PaymentType.CHARGE ? '%' : null,
                  prefixText: paymentType == PaymentType.PRICE ? 'R\$' : null,
                  helperText: '',
                  errorStyle: Theme.of(context).textTheme.caption.apply(color: Colors.red[700]),
                  errorMaxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        FlatButton(
          child: Text('Cancelar'),
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
              onPressed: (loading == null || loading.isCompleted) && inputValidator(paymentController.text) == null
                  ? () => savePayment(context)
                  : null,
            ),
      ],
    );
  }
}
