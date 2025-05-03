import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/productos_model.dart';
import 'package:zapato/proveedores/cart_provider.dart';
import 'package:zapato/pantallas/cart_screen.dart';
import 'package:zapato/pantallas/perfil_screen.dart';
import 'package:zapato/pantallas/favoritos_screen.dart';
import 'package:zapato/pantallas/busquedascreen.dart';
import 'package:zapato/pantallas/inicio_content.dart';
import 'package:zapato/widgets/animations.dart';

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  int _selectedIndex = 0;

  final List<Widget> _screens = <Widget>[
    const InicioContent(),
    const BusquedaScreen(),
    FavoritosScreen(),
    CartScreen(),
    const PerfilScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Consumer<ProductosModel>(
        builder: (context, productosModel, child) {
          if (productosModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (productosModel.error != null) {
            return Center(child: Text('Error: ${productosModel.error}'));
          }
          return AnimatedPageWrapper(
            key: ValueKey(_selectedIndex),
            child: _screens[_selectedIndex],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: Offset(0, -1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            final int itemCount = cartProvider.items.fold(
              0,
                  (sum, item) => sum + item.cantidad,
            );

            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              showUnselectedLabels: false,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined, size: 28),
                  activeIcon: Stack(
                    alignment: Alignment.bottomCenter,
                    children: const [
                      Icon(Icons.home, size: 30),
                      Positioned(
                        top: -4,
                        child: Icon(Icons.circle, size: 6, color: Colors.redAccent),
                      ),
                    ],
                  ),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.search_outlined, size: 28),
                  activeIcon: Stack(
                    alignment: Alignment.bottomCenter,
                    children: const [
                      Icon(Icons.search, size: 30),
                      Positioned(
                        top: -4,
                        child: Icon(Icons.circle, size: 6, color: Colors.redAccent),
                      ),
                    ],
                  ),
                  label: 'Buscar',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.favorite_border, size: 28),
                  activeIcon: Stack(
                    alignment: Alignment.bottomCenter,
                    children: const [
                      Icon(Icons.favorite, size: 30),
                      Positioned(
                        top: -4,
                        child: Icon(Icons.circle, size: 6, color: Colors.redAccent),
                      ),
                    ],
                  ),
                  label: 'Favoritos',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 28),
                      if (itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
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
                      const Icon(Icons.shopping_bag, size: 30),
                      if (itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
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
                  icon: const Icon(Icons.person_outline, size: 28),
                  activeIcon: Stack(
                    alignment: Alignment.bottomCenter,
                    children: const [
                      Icon(Icons.person, size: 30),
                      Positioned(
                        top: -4,
                        child: Icon(Icons.circle, size: 6, color: Colors.redAccent),
                      ),
                    ],
                  ),
                  label: 'Perfil',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
