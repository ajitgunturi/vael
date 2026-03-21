import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A TextFormField specialized for currency input in rupees.
///
/// Accepts major unit input (e.g. "5000") and converts to minor units (paise)
/// via [toPaise]. Displays with ₹ prefix and live Indian comma formatting
/// (1,00,000 / 1,00,00,000) as the user types.
class CurrencyInput extends StatelessWidget {
  const CurrencyInput({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.initialValuePaise,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  /// If set, pre-fills the field with this amount (in paise) converted to major units.
  final int? initialValuePaise;

  /// Converts a major unit string (e.g. "5000" or "12,34,567") to paise.
  static int toPaise(String majorUnits) {
    final parsed = double.tryParse(majorUnits.replaceAll(',', ''));
    if (parsed == null) return 0;
    return (parsed * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '₹ ',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        const _IndianCommaFormatter(),
      ],
      validator: validator,
    );
  }
}

/// Applies Indian number grouping (1,23,456 format) live as user types.
class _IndianCommaFormatter extends TextInputFormatter {
  const _IndianCommaFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final stripped = newValue.text.replaceAll(',', '');
    if (stripped.isEmpty) return newValue;

    // Handle decimal part separately
    final parts = stripped.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';

    final formatted = _formatIndian(intPart);
    final newText = '$formatted$decPart';

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  static String _formatIndian(String digits) {
    if (digits.length <= 3) return digits;

    // Last 3 digits
    final last3 = digits.substring(digits.length - 3);
    var remaining = digits.substring(0, digits.length - 3);

    // Group remaining in pairs from right
    final buffer = StringBuffer();
    while (remaining.length > 2) {
      buffer.write(remaining.substring(0, remaining.length - 2).isEmpty
          ? ''
          : '');
      final pair = remaining.substring(remaining.length - 2);
      remaining = remaining.substring(0, remaining.length - 2);
      if (buffer.isEmpty) {
        buffer.write(pair);
      } else {
        buffer.write(',$pair');
      }
    }

    // Build result: remaining digits, then pairs, then last 3
    final pairs = <String>[];
    var rem = digits.substring(0, digits.length - 3);
    while (rem.length > 2) {
      pairs.insert(0, rem.substring(rem.length - 2));
      rem = rem.substring(0, rem.length - 2);
    }
    if (rem.isNotEmpty) pairs.insert(0, rem);

    return '${pairs.join(',')},${last3}';
  }
}
