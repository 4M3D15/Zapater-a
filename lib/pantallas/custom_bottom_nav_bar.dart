import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/proveedores/cart_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  final List<_NavBarItemData> _items = const [
    _NavBarItemData(icon: Icons.home, label: 'Inicio'),
    _NavBarItemData(icon: Icons.search, label: 'Buscar'),
    _NavBarItemData(icon: Icons.favorite_border, label: 'Favoritos'),
    _NavBarItemData(icon: Icons.shopping_bag_outlined, label: 'Bolsa'),
    _NavBarItemData(icon: Icons.person_outline, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final cartItemCount = context.watch<CartProvider>().items.fold<int>(
      0,
          (total, item) => total + item.cantidad,
    );

    return SafeArea(
      top: false,  // solo aplica safearea abajo
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.05),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final isSelected = index == currentIndex;
                  final isCart = index == 3;

                  return GestureDetector(
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          isCart
                              ? _AnimatedCartIconWithBadge(
                            icon: item.icon,
                            count: cartItemCount,
                            isSelected: isSelected,
                          )
                              : Icon(
                            item.icon,
                            color: isSelected ? Colors.white : Colors.grey[400],
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: isSelected
                                ? Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedCartIconWithBadge extends StatefulWidget {
  final IconData icon;
  final int count;
  final bool isSelected;

  const _AnimatedCartIconWithBadge({
    required this.icon,
    required this.count,
    required this.isSelected,
  });

  @override
  State<_AnimatedCartIconWithBadge> createState() =>
      _AnimatedCartIconWithBadgeState();
}

class _AnimatedCartIconWithBadgeState extends State<_AnimatedCartIconWithBadge>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  int _previousCount = 0;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_bounceController);

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey[400],
      end: Colors.orangeAccent,
    ).animate(_colorController);
  }

  @override
  void didUpdateWidget(covariant _AnimatedCartIconWithBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.count != _previousCount) {
      _previousCount = widget.count;
      _bounceController.forward(from: 0);
      _colorController.forward(from: 0).then((_) => _colorController.reverse());
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected
                    ? Colors.white
                    : _colorAnimation.value ?? Colors.grey[400],
              ),
              if (widget.count > 0)
                Positioned(
                  top: -6,
                  right: -6,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Container(
                      key: ValueKey(widget.count),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          '${widget.count}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NavBarItemData {
  final IconData icon;
  final String label;

  const _NavBarItemData({
    required this.icon,
    required this.label,
  });
}
