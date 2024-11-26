// ui_helpers.dart
import 'package:flutter/material.dart';

void showErrorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

void showSuccessMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green),
  );
}
