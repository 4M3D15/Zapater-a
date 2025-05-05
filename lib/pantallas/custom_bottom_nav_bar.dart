// archivo: widgets/barra_navegacion.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/proveedores/cart_provider.dart';

class BarraNavegacionInferior extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isVisible;

  const BarraNavegacionInferior({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                final itemCount = cartProvider.items.fold<int>(
                  0,
                      (sum, item) => sum + item.cantidad,
                );
                return BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.black.withOpacity(0.5),
                  elevation: 0,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  showUnselectedLabels: false,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white70,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home_rounded, size: 26),
                      activeIcon: const Icon(Icons.home, size: 28),
                      label: 'Inicio',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.search_rounded, size: 26),
                      activeIcon: const Icon(Icons.search, size: 28),
                      label: 'Buscar',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.favorite_outline_rounded, size: 26),
                      activeIcon: const Icon(Icons.favorite_rounded, size: 28),
                      label: 'Favoritos',
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 26),
                          if (itemCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.lightBlueAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$itemCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      activeIcon: Stack(
                        children: [
                          const Icon(Icons.shopping_bag_rounded, size: 28),
                          if (itemCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.lightBlueAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$itemCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      label: 'Bolsa',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person_outline_rounded, size: 26),
                      activeIcon: const Icon(Icons.person_rounded, size: 28),
                      label: 'Perfil',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}