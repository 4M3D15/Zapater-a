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
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _particles = List.generate(30, (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 4 + 2;
      final color = Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
      return _Particle(
        direction: Offset(cos(angle), sin(angle)) * speed,
        color: color,
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
      left: widget.position.dx - 20,
      top: widget.position.dy - 20,
      child: SizedBox(
        width: 40,
        height: 40,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
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

  _Particle({required this.direction, required this.color});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final offset = p.direction * progress * 10;
      final paint = Paint()..color = p.color.withOpacity(1 - progress);
      canvas.drawCircle(size.center(offset), 2.5 * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
