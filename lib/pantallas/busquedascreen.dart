import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/favoritos_model.dart';
import '../modelos/producto_model.dart';
import '../widgets/animated_favorite_icon.dart';
import '../Servicios/firestore_service.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({Key? key}) : super(key: key);

  @override
  _BusquedaScreenState createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  List<Producto> productos = [];
  List<Producto> filteredProductos = [];
  List<String> sugerencias = [];

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    final cargados = await _firestoreService.obtenerProductos();
    setState(() {
      productos = cargados;
      filteredProductos = cargados;
    });
  }

  void _searchProducts(String query) {
    final lower = query.toLowerCase();
    setState(() {
      filteredProductos = productos
          .where((p) => p.nombre.toLowerCase().contains(lower))
          .toList();
      sugerencias = productos
          .where((p) => p.nombre.toLowerCase().startsWith(lower))
          .map((p) => p.nombre)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Busca tu producto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _searchProducts,
            ),
          ),
          if (sugerencias.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                itemCount: sugerencias.length,
                itemBuilder: (_, i) {
                  final s = sugerencias[i];
                  return ListTile(
                    title: Text(s),
                    onTap: () {
                      _searchController.text = s;
                      _searchProducts(s);
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          filteredProductos.isEmpty
              ? const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'No se encontraron productos',
              style: TextStyle(fontSize: 18),
            ),
          )
              : Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredProductos.length,
              itemBuilder: (_, idx) {
                final producto = filteredProductos[idx];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/product',
                    arguments: producto.id,
                  ),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10)),
                                child: producto.imagen.isNotEmpty
                                    ? Image.network(
                                  producto.imagen,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                                    : const Icon(Icons.image,
                                    size: 50, color: Colors.grey),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Consumer<FavoritosModel>(
                                  builder: (_, favs, __) {
                                    final isFav =
                                    favs.esFavorito(producto);
                                    return AnimatedFavoriteIcon(
                                      esFavorito: isFav,
                                      onTap: () => isFav
                                          ? favs.removerFavorito(producto)
                                          : favs.agregarFavorito(producto),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${producto.precio.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.green),
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
