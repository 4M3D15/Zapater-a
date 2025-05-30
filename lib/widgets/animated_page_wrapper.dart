import 'package:flutter/material.dart';

/// Un contenedor animado que aplica una transición combinada de deslizamiento hacia abajo y desvanecimiento
/// al cambiar de contenido. Ideal para animar cambios sutiles dentro de una misma pantalla.
class AnimatedPageWrapper extends StatelessWidget {
  final Widget child;

  const AnimatedPageWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Animación de entrada tipo slide desde arriba
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, -0.1), // Comienza ligeramente por arriba
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
