import 'package:flutter/material.dart';

class InicioScreen extends StatelessWidget {
  final List<Map<String, dynamic>> productos = [
    {"nombre": "Tenis Nike", "precio": 1200, "imagen": "assets/cortez.png"},
    {"nombre": "Adidas Sport", "precio": 1500, "imagen": "assets/YZ1.png"},
    {"nombre": "New Balance Casual", "precio": 1100, "imagen": "assets/55810NB.png"},
    {"nombre": "Yeezy", "precio": 1300, "imagen": "assets/YZPINK.png"},
    {"nombre": "Nike Court Vision", "precio": 1300, "imagen": "assets/courtvision.png"},
    {"nombre": "New Balance", "precio": 1300, "imagen": "assets/55412NB.png"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zapatería'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'login') {
                Navigator.pushNamed(context, '/login');
              } else if (value == 'registro') {
                Navigator.pushNamed(context, '/registro');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'login', child: Text('Iniciar Sesión')),
              const PopupMenuItem(value: 'registro', child: Text('Registrarse')),
            ],
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text("Hombre")),
                ElevatedButton(onPressed: () {}, child: const Text("Mujer")),
                ElevatedButton(onPressed: () {}, child: const Text("Niño/a")),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
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
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.asset(
                              producto["imagen"],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                              },
                            ),
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
            ),
          ),
        ],
      ),
    );
  }
}
