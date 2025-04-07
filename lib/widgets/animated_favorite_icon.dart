import 'package:flutter/material.dart';

class AnimatedFavoriteIcon extends StatefulWidget {
  final bool esFavorito;
  final VoidCallback onTap;

  const AnimatedFavoriteIcon({
    super.key,
    required this.esFavorito,
    required this.onTap,
  });

  @override
  State<AnimatedFavoriteIcon> createState() => _AnimatedFavoriteIconState();
}

class _AnimatedFavoriteIconState extends State<AnimatedFavoriteIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Establecer el valor inicial para que el icono sea visible
    _controller.value = 1.0;

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedFavoriteIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el estado cambia, reinicia y dispara la animación
    if (widget.esFavorito != oldWidget.esFavorito) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(
          widget.esFavorito ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
        onPressed: widget.onTap,
      ),
    );
  }
}
