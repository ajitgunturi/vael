import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A TextFormField specialized for currency input in rupees.
///
/// Accepts major unit input (e.g. "5000") and converts to minor units (paise)
/// via [toPaise]. Displays with ₹ prefix.
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

  /// Converts a major unit string (e.g. "5000") to paise.
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
      ],
      validator: validator,
    );
  }
}
