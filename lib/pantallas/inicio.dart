import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zapato/pantallas/perfil_screen.dart';

import 'inicio_content.dart';
import 'busquedascreen.dart';
import 'favoritos_screen.dart';
import 'cart_screen.dart';
import 'welcome_screen.dart';
import 'registro_screen.dart';
import 'custom_bottom_nav_bar.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({Key? key}) : super(key: key);

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showNavBar = true;
  late AnimationController _navBarAnimController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

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
    ).animate(
      CurvedAnimation(parent: _navBarAnimController, curve: Curves.easeInOut),
    );

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
        return InicioContent(scrollController: _scrollController);
      case 1:
        return const BusquedaScreen();
      case 2:
        return const FavoritosScreen();
      case 3:
        return const CartScreen();
      case 4:
        final user = FirebaseAuth.instance.currentUser;
        return user != null
            ? const ProfileScreen()
            : const WelcomeScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener dimensiones y escala
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    // Padding adaptativo (5% horizontal, 2% vertical)
    final horizontalPadding = screenWidth * 0.05;
    final verticalPadding = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Padding(
                key: ValueKey(_titulos[_currentIndex]),
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: verticalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título de la sección con tamaño adaptado
                    Text(
                      _titulos[_currentIndex],
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize:
                        (Theme.of(context).textTheme.headlineSmall?.fontSize ?? 24) *
                            textScale,
                      ),
                    ),

                    // Icono de “bolsa” solo en la pestaña Carrito
                    if (_currentIndex == 3)
                      IconButton(
                        icon: const Icon(Icons.shopping_bag),
                        color: Colors.black87,
                        onPressed: () {
                          // Puedes agregar acción si lo deseas
                        },
                      ),
                  ],
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
