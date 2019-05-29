import 'package:after_layout/after_layout.dart';
import 'package:allset/data/payment_data.dart';
import 'package:allset/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with AfterLayoutMixin {
  final priceController = TextEditingController();
  final chargeController = TextEditingController();

  final priceFocus = FocusNode();
  final chargeFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    priceFocus.addListener(() => {chargeController.clear()});
    chargeFocus.addListener(() => {priceController.clear()});
  }

  @override
  void dispose() {
    priceController.dispose();
    chargeController.dispose();
    priceFocus.dispose();
    chargeFocus.dispose();

    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final PaymentData initialPaymentData =
        ModalRoute
            .of(context)
            .settings
            .arguments;
    if (initialPaymentData != null) {
      switch (initialPaymentData.type) {
        case PaymentType.PRICE:
          priceController.text = initialPaymentData.value.toStringAsFixed(2);
          break;
        case PaymentType.CHARGE:
          chargeController.text = initialPaymentData.value.toStringAsFixed(0);
          break;
      }
    }
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

  String validatePrice(String input) {
    try {
      if (input.length == 0) return null;
      final value = double.parse(input);
      if (value <= 0) return 'Preço deve ser maior que 0';
      return null;
    } on FormatException {
      return 'Número inválido';
    }
  }

  void goBack(BuildContext context) {
    PaymentType paymentType;
    double value;
    if (priceController.text.length > 0) {
      paymentType = PaymentType.PRICE;
      value = double.parse(priceController.text);
    } else if (chargeController.text.length > 0) {
      paymentType = PaymentType.CHARGE;
      value = double.parse(chargeController.text);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: const Text('Por favor escolha um pagamento'),
        duration: const Duration(seconds: 5),
      ));
      return;
    }

    Navigator.pop(context, PaymentData(paymentType, value));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildPaymentTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pagamento'),
          leading: Builder(
            builder: (context) => WillPopScope(
              onWillPop: () {
                goBack(context);
              },
              child: IconButton(
                icon: Icon(FontAwesomeIcons.arrowLeft),
                onPressed: () => goBack(context),
              ),
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 128),
              child: TextFormField(
                controller: priceController,
                focusNode: priceFocus,
                keyboardType: TextInputType.number,
                validator: validatePrice,
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
              children: const [
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
              padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 128),
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
          ],
        ),
      ),
    );
  }
}
