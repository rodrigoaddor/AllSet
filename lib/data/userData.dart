import 'package:meta/meta.dart';

class UserData {
  final bool charging;
  final double percent;

  String get hPercent => (percent * 100).toStringAsFixed(0) + '%';

  const UserData({@required this.charging, @required this.percent});

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      charging: map['charging'],
      percent: map['percent'].toDouble()
    );
  }
}