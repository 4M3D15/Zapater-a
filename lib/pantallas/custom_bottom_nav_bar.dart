import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../proveedores/cart_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isVisible;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                final itemCount = cartProvider.items.fold<int>(
                  0, (sum, item) => sum + item.cantidad,
                );

                BottomNavigationBarItem buildCartItem() {
                  Widget iconWithBadge(Icon icon) {
                    return Stack(
                      children: [
                        icon,
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
                    );
                  }

                  return BottomNavigationBarItem(
                    icon: iconWithBadge(const Icon(Icons.shopping_bag_outlined, size: 26)),
                    activeIcon: iconWithBadge(const Icon(Icons.shopping_bag, size: 28)),
                    label: 'Bolsa',
                  );
                }

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
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home_rounded, size: 26),
                      activeIcon: Icon(Icons.home, size: 28),
                      label: 'Inicio',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.search_rounded, size: 26),
                      activeIcon: Icon(Icons.search, size: 28),
                      label: 'Buscar',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.favorite_outline_rounded, size: 26),
                      activeIcon: Icon(Icons.favorite, size: 28),
                      label: 'Favoritos',
                    ),
                    buildCartItem(),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline, size: 26),
                      activeIcon: Icon(Icons.person, size: 28),
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