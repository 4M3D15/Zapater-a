// archivo: pantallas/inicio_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../pantallas/favoritos_screen.dart';
import '../pantallas/busquedascreen.dart';
import '../pantallas/cart_screen.dart';
import '../pantallas/perfil_screen.dart';
import '../pantallas/custom_bottom_nav_bar.dart';
import '../pantallas/inicio_content.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({Key? key}) : super(key: key);

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showNavBar = true;
  late AnimationController _navBarAnimController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final GlobalKey _inicioKey = GlobalKey();

  final List<String> _titulos = [
    'Inicio',
    'Buscar',
    'Favoritos',
    'Carrito',
    'Perfil',
  ];

  @override
  void initState() {
    super.initState();

    _navBarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(
      parent: _navBarAnimController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_navBarAnimController);

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse && _showNavBar) {
        setState(() => _showNavBar = false);
        _navBarAnimController.forward();
      } else if (direction == ScrollDirection.forward && !_showNavBar) {
        setState(() => _showNavBar = true);
        _navBarAnimController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _navBarAnimController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildPantalla(int index) {
    switch (index) {
      case 0:
        return InicioContent(
          key: _inicioKey,
          scrollController: _scrollController,
        );
      case 1:
        return const BusquedaScreen();
      case 2:
        return const FavoritosScreen();
      case 3:
        return const CartScreen();
      case 4:
        return const PerfilScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            // Título dinámico
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: Padding(
                key: ValueKey(_titulos[_currentIndex]),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _titulos[_currentIndex],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            // Contenido principal
            Expanded(
              child: _buildPantalla(_currentIndex),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
