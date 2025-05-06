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

class _ParticleExplosionState extends State<ParticleExplosion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _particles = List.generate(35, (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 6 + 2; // Más rango
      final size = _random.nextDouble() * 2 + 2;
      final color = Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
      return _Particle(
        direction: Offset(cos(angle), sin(angle)) * speed,
        color: color,
        size: size,
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 30,
      top: widget.position.dy - 30,
      child: SizedBox(
        width: 60,
        height: 60,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  final Offset direction;
  final Color color;
  final double size;

  _Particle({
    required this.direction,
    required this.color,
    required this.size,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final offset = p.direction * progress * 10;
      final paint = Paint()..color = p.color.withOpacity(1 - progress);
      canvas.drawCircle(size.center(offset), p.size * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
