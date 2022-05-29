import 'package:flutter/material.dart';

class DialogLoading {
  static void show(BuildContext context, {bool dismissible = true}) {
    showDialog(
        context: context,
        barrierDismissible: dismissible,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
