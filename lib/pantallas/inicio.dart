import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/pantallas/cart_screen.dart';
import 'package:zapato/pantallas/perfil_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:zapato/pantallas/favoritos_screen.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/pantallas/busquedascreen.dart';
import '../widgets/animated_favorite_icon.dart'; // Asegúrate de tener este archivo

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const InicioContent(),
    const busquedascreen(),
    FavoritosScreen(),
    CartScreen(),
    PerfilScreen(),
  ];

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

class InicioContent extends StatelessWidget {
  const InicioContent({super.key});

  final List<Map<String, dynamic>> productos = const [
    {"nombre": "Tenis Nike", "precio": 1200, "imagen": "assets/cortez.png"},
    {"nombre": "Adidas Sport", "precio": 1500, "imagen": "assets/YZ1.png"},
    {"nombre": "New Balance Casual", "precio": 1100, "imagen": "assets/55810NB.png"},
    {"nombre": "Yeezy", "precio": 1300, "imagen": "assets/YZPINK.png"},
    {"nombre": "Nike Court Vision", "precio": 1300, "imagen": "assets/courtvision.png"},
    {"nombre": "New Balance", "precio": 1300, "imagen": "assets/55412NB.png"}
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Compras', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: CarouselSlider(
            options: CarouselOptions(height: 180.0, autoPlay: true, enlargeCenterPage: true),
            items: productos.map((producto) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(producto['imagen']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: Consumer<FavoritosModel>(
            builder: (context, favoritos, child) {
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  final isFavorito = favoritos.esFavorito(producto);

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/product', arguments: producto);
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                  child: Image.asset(
                                    producto["imagen"],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: AnimatedFavoriteIcon(
                                    esFavorito: isFavorito,
                                    onTap: () {
                                      if (isFavorito) {
                                        favoritos.removerFavorito(producto);
                                      } else {
                                        favoritos.agregarFavorito(producto);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  producto["nombre"],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "\$${producto["precio"]}",
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
