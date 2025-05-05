import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const ConfettiOverlay({super.key, required this.onComplete});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();

    Future.delayed(const Duration(seconds: 3), () {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildEmitter(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: ConfettiWidget(
        confettiController: _controller,
        blastDirection: pi / 2, // Hacia abajo
        blastDirectionality: BlastDirectionality.directional,
        emissionFrequency: 0.08,
        numberOfParticles: 12,
        gravity: 0.6,
        maxBlastForce: 20,
        minBlastForce: 10,
        shouldLoop: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            buildEmitter(Alignment.topLeft),
            buildEmitter(Alignment.topCenter),
            buildEmitter(Alignment.topRight),
          ],
        ),
      ),
    );
  }
}
