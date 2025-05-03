import 'package:flutter/material.dart';

class AnimatedPageWrapper extends StatelessWidget {
  final Widget child;

  const AnimatedPageWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500), // Duración de la animación
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Animación de escalado y desvanecimiento
        return ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.0).animate(animation), // Escalado hacia afuera
          child: FadeTransition(opacity: animation, child: child), // Desvanecimiento simultáneo
        );
      },
      child: child,
    );
  }
}
