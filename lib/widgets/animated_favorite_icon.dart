import 'package:flutter/material.dart';

class AnimatedFavoriteIcon extends StatelessWidget {
  final bool esFavorito;
  final Function onTap;

  const AnimatedFavoriteIcon({super.key, required this.esFavorito, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: esFavorito
            ? const Icon(Icons.favorite, color: Colors.red, key: ValueKey(1))
            : const Icon(Icons.favorite_border, color: Colors.black, key: ValueKey(0)),
      ),
    );
  }
}
