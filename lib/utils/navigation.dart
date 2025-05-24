import 'package:flutter/material.dart';

Future<void> navigateWithLoading(BuildContext context, Widget page, {bool replace = false}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  await Future.delayed(const Duration(milliseconds: 800)); // Simula carga o espera

  if (replace) {
    Navigator.of(context).pop(); // Cierra el diálogo
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  } else {
    Navigator.of(context).pop(); // Cierra el diálogo
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
