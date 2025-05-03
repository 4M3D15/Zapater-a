import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  CustomPageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0); // Dirección de la animación (a la derecha)
      var end = Offset.zero;
      var curve = Curves.easeInOut; // Tipo de curva de la animación

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      // Aquí puedes cambiar la animación, por ejemplo para hacer que se deslice
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
