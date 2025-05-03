import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zapato/modelos/productos_model.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/widgets/animated_favorite_icon.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});
  @override
  _BusquedaScreenState createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Producto> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = [];
  }

  void _searchProducts(List<Producto> allProducts) {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? allProducts
          : allProducts.where((p) => p.nombre.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allProducts    = Provider.of<ProductosModel>(context).productos;
    final favoritosModel = Provider.of<FavoritosModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Productos', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Busca tu producto...',
                prefixIcon: Icon(Icons.search, color: Colors.black54),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _searchProducts(allProducts),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Text(
                _searchController.text.isEmpty
                    ? 'Empieza a escribir para buscar'
                    : 'No se encontraron productos',
                style: const TextStyle(fontSize: 18),
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
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final producto = _filtered[index];
                final isFav    = favoritosModel.esFavorito(producto);

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/product',
                    arguments: producto,
                  ),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  esFavorito: isFav,
                                  onTap: () {
                                    if (isFav) favoritosModel.removerFavorito(producto);
                                    else favoritosModel.agregarFavorito(producto);
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
                              Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text("\$${producto.precio}", style: const TextStyle(color: Colors.green)),
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