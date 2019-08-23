import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(_, TextEditingValue newValue) => TextEditingValue(
        text: newValue.text?.toUpperCase(),
        selection: newValue.selection,
      );
}
