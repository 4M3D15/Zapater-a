import 'package:flutter/material.dart';

Future<void> navigateWithLoading(BuildContext context, Widget page) async {
  // Mostrar loader
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  // Esperar un pequeño tiempo (simula carga, opcional)
  await Future.delayed(const Duration(milliseconds: 500));

  // Ocultar loader
  Navigator.of(context).pop();

  // Ir a la siguiente pantalla con animación
  Navigator.of(context).push(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ));
}
