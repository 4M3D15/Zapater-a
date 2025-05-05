import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pantallas/favoritos_screen.dart';
import '../pantallas/busquedascreen.dart';
import '../pantallas/cart_screen.dart';
import '../pantallas/perfil_screen.dart';
import '../pantallas/custom_bottom_nav_bar.dart'; // ← nombre correcto del archivo del nav bar
import 'inicio_content.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({Key? key}) : super(key: key);

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _currentIndex = 0;
  bool _isVisible = true;

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
      extendBody: true,
      body: _pantallas[_currentIndex],
      bottomNavigationBar: BarraNavegacionInferior( // ← uso correcto del widget
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        isVisible: _isVisible,
      ),
    );
  }
}
