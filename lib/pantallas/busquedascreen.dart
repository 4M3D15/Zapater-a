import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/modelos/producto_model.dart'; // Importando producto_model.dart
import 'package:zapato/widgets/animated_favorite_icon.dart';

import '../Servicios/firestore_service.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  _BusquedaScreenState createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  List<Producto> productos = [];
  List<Producto> filteredProductos = [];

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    productos = await _firestoreService.obtenerProductos();
    setState(() {
      filteredProductos = productos;
    });
  }

  void _searchProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredProductos = productos.where((producto) {
        return producto.nombre.toLowerCase().contains(query);
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
                                child: Image.network(
                                  producto.imagen,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: AnimatedFavoriteIcon(
                                  esFavorito: Provider.of<FavoritosModel>(context).esFavorito(producto),
                                  onTap: () {
                                    final favoritosModel = Provider.of<FavoritosModel>(context, listen: false);
                                    if (favoritosModel.esFavorito(producto)) {
                                      favoritosModel.removerFavorito(producto);
                                    } else {
                                      favoritosModel.agregarFavorito(producto);
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
                                producto.nombre,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "\$${producto.precio}",
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
