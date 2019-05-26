import 'package:allset/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum PaymentType { PRICE, CHARGE }

class PaymentResponse {
  final PaymentType type;
  final double value;

  const PaymentResponse(this.type, this.value);

  Map<String, dynamic> toJson() => {
        'type': type.toString().split('.').last.toLowerCase(),
        'value': value,
      };
}

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
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

  String validateCharge(String input) {
    try {
      if (input.length == 0) return '';
      final value = double.parse(input);
      if (value == 0 || value > 100) return 'Carga deve estar entre 0% e 100%';
      return '';
    } on FormatException {
      return 'Número inválido';
    }
  }

  String validatePrice(String input) {
    try {
      if (input.length == 0) return '';
      final value = double.parse(input);
      if (value <= 0) return 'Preço deve ser maior que 0';
      return '';
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

    Navigator.pop(context, PaymentResponse(paymentType, value));
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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 128),
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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 128),
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
