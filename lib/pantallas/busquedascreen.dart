import 'package:flutter/material.dart';
import 'package:zapato/widgets/animated_favorite_icon.dart';


class busquedascreen extends StatefulWidget {
  const busquedascreen({super.key});

  @override
  _BusquedaScreenState createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<busquedascreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> productos = [
    {"nombre": "Tenis Nike", "precio": 1200, "imagen": "assets/cortez.png"},
    {"nombre": "Adidas Sport", "precio": 1500, "imagen": "assets/YZ1.png"},
    {"nombre": "New Balance Casual", "precio": 1100, "imagen": "assets/55810NB.png"},
    {"nombre": "Yeezy", "precio": 1300, "imagen": "assets/YZPINK.png"},
    {"nombre": "Nike Court Vision", "precio": 1300, "imagen": "assets/courtvision.png"},
    {"nombre": "New Balance", "precio": 1300, "imagen": "assets/55412NB.png"}
  ];

  List<Map<String, dynamic>> filteredProductos = [];

  @override
  void initState() {
    super.initState();
    filteredProductos = productos;  // Inicialmente muestra todos los productos
  }

  void _searchProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredProductos = productos.where((producto) {
        return producto["nombre"].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Productos', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Busca tu producto...',
                prefixIcon: Icon(Icons.search, color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black54),
                ),
              ),
              onChanged: (value) {
                _searchProducts();
              },
            ),
          ),
          Expanded(
            child: filteredProductos.isEmpty
                ? Center(
              child: Text(
                'No se encontraron productos',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredProductos.length,
              itemBuilder: (context, index) {
                final producto = filteredProductos[index];
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
                                child: IconButton(
                                  icon: const Icon(Icons.favorite_border, color: Colors.red),
                                  onPressed: () {},
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
            ),
          ),
        ],
      ),
    );
  }
}
