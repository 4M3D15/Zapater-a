import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pantallas/favoritos_screen.dart';
import '../pantallas/busquedascreen.dart';
import '../pantallas/cart_screen.dart';
import '../pantallas/perfil_screen.dart';
import '../pantallas/custom_bottom_nav_bar.dart';
import 'custom_bottom_nav_bar.dart';
import 'inicio_content.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({Key? key}) : super(key: key);

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _currentIndex = 0;

  final List<Widget> _pantallas = const [
    InicioContent(),
    BusquedaScreen(),
    FavoritosScreen(),
    CartScreen(),
    PerfilScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // permite que el fondo del BottomNav sea transparente
      body: _pantallas[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
