import 'dart:math';
import 'package:flutter/material.dart';

class ParticleExplosion extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;

  const ParticleExplosion({
    Key? key,
    required this.position,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<ParticleExplosion> createState() => _ParticleExplosionState();
}

class _ParticleExplosionState extends State<ParticleExplosion> with TickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _randomColor() {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 25,
      top: widget.position.dy - 25,
      child: SizedBox(
        width: 100,
        height: 100,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final progress = _controller.value;
            return Stack(
              children: List.generate(20, (i) {
                final angle = (2 * pi / 20) * i;
                final radius = 40 * progress;
                final dx = cos(angle) * radius;
                final dy = sin(angle) * radius;
                return Positioned(
                  left: 40 + dx,
                  top: 40 + dy,
                  child: Opacity(
                    opacity: 1 - progress,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _randomColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
