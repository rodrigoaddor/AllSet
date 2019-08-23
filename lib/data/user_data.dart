import 'package:allset/data/payment_data.dart';
import 'package:meta/meta.dart';

class UserData {
  final bool hasVehicle;
  final bool charging;
  final double percent;
  final PaymentData payment;

  const UserData({
    @required this.hasVehicle,
    this.charging,
    this.percent,
    this.payment,
  });

  factory UserData.fromJson(Map<dynamic, dynamic> json) {
    return UserData(
      hasVehicle: json['hasVehicle'] ?? false,
      charging: json['charging'] ?? false,
      percent: json['percent']?.toDouble() ?? 0.0,
      payment: json['payment'] != null ? PaymentData.fromJson(json['payment']) : null,
    );
  }

  String get hPercent => (percent * 100).toStringAsFixed(0) + '%';
}
