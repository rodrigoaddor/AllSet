enum PaymentType { PRICE, CHARGE }

String paymentTypeToString(PaymentType type) {
  return type.toString().split('.').last.toLowerCase();
}

PaymentType paymentTypeFromString(String type) {
  return PaymentType.values.firstWhere((enumType) => enumType.toString().split('.').last.toLowerCase() == type);
}

class PaymentData {
  final PaymentType type;
  final double value;

  const PaymentData(this.type, this.value);

  factory PaymentData.fromJson(Map<dynamic, dynamic> json) =>
      PaymentData(paymentTypeFromString(json['type']), json['value']);

  Map<String, dynamic> toJson() => {
        'type': paymentTypeToString(type),
        'value': value,
      };
}
