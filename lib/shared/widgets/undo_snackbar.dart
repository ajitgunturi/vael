import 'package:flutter/material.dart';

/// Shows a [SnackBar] with an "Undo" action button.
///
/// The snackbar is displayed for 5 seconds. If the user taps "Undo",
/// [onUndo] is called and the snackbar is dismissed.
void showUndoSnackbar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(label: 'Undo', onPressed: onUndo),
    ),
  );
}
