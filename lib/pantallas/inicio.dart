import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/productos_model.dart';
import 'package:zapato/pantallas/cart_screen.dart';
import 'package:zapato/pantallas/perfil_screen.dart';
import 'package:zapato/pantallas/favoritos_screen.dart';
import 'package:zapato/pantallas/busquedascreen.dart';
import 'inicio_content.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const InicioContent(),
    const BusquedaScreen(),
    FavoritosScreen(),
    const CartScreen(),
    const PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Cargar productos después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductosModel>(context, listen: false).obtenerProductos();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Bolsa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
