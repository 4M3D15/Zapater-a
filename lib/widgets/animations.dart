import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// Animación de cambio de página con transición compartida
class AnimatedPageWrapper extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final SharedAxisTransitionType transitionType;

  const AnimatedPageWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.transitionType = SharedAxisTransitionType.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: duration,
      reverse: false,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Animación que entra desde arriba (ideal para listas)
class SlideFadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const SlideFadeIn({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
  });

  @override
  State<SlideFadeIn> createState() => _SlideFadeInState();
}

class _SlideFadeInState extends State<SlideFadeIn> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay * widget.index).then((_) {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: widget.curve,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, -0.2),
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}

/// Animación que entra desde abajo (ideal para botones, totales, etc.)
class SlideFadeInFromBottom extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const SlideFadeInFromBottom({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
  });

  @override
  State<SlideFadeInFromBottom> createState() => _SlideFadeInFromBottomState();
}

class _SlideFadeInFromBottomState extends State<SlideFadeInFromBottom> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay).then((_) {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: widget.curve,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.2),
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}

/// Función global para navegar con loading
Future<void> navigateWithLoading(BuildContext context, Widget page, {bool replace = false}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  await Future.delayed(const Duration(milliseconds: 800)); // simula carga

  Navigator.of(context).pop(); // cierra el loading

  if (replace) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
