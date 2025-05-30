import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/favoritos_model.dart';
import '../modelos/producto_model.dart';
import '../widgets/animated_favorite_icon.dart';
import '../Servicios/firestore_service.dart';
import '../widgets/particle_explosion.dart';
import '../widgets/animations.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({Key? key}) : super(key: key);

  @override
  _BusquedaScreenState createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  List<Producto> productos = [];
  List<Producto> filteredProductos = [];
  List<String> sugerencias = [];
  OverlayEntry? _explosionOverlay;

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
      filteredProductos = productos.where((p) {
        return p.nombre.toLowerCase().contains(lower) ||
            p.descripcion.toLowerCase().contains(lower) ||
            p.categoria.toLowerCase().contains(lower) ||
            p.color.toLowerCase().contains(lower) ||
            p.sexo.toLowerCase().contains(lower);
      }).toList();

      sugerencias = productos
          .where((p) => p.nombre.toLowerCase().startsWith(lower))
          .map((p) => p.nombre)
          .toList();
    });
  }

  void _mostrarExplosion(Offset globalPosition) {
    _explosionOverlay = OverlayEntry(
      builder: (_) => ParticleExplosion(
        position: globalPosition,
        onComplete: () {
          _explosionOverlay?.remove();
          _explosionOverlay = null;
        },
      ),
    );
    Overlay.of(context).insert(_explosionOverlay!);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideFadeIn(
      index: 0,
      child: Padding(
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

            if (filteredProductos.isEmpty)
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 100),
                child: const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'No se encontraron productos',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            else
              Expanded(
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
                    return SlideFadeInFromBottom(
                      delay: Duration(milliseconds: 100 * (idx + 1)),
                      child: GestureDetector(
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
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                      child: producto.imagen.isNotEmpty
                                          ? Image.network(
                                        producto.imagen,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                          : const Icon(Icons.image, size: 50, color: Colors.grey),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Consumer<FavoritosModel>(
                                        builder: (_, favs, __) {
                                          final isFav = favs.esFavorito(producto);
                                          return AnimatedFavoriteIcon(
                                            esFavorito: isFav,
                                            onTap: () {
                                              final renderBox = context.findRenderObject() as RenderBox?;
                                              if (renderBox != null) {
                                                final position = renderBox.localToGlobal(const Offset(0, 0));
                                                _mostrarExplosion(position);
                                              }
                                              if (isFav) {
                                                favs.removerFavorito(producto);
                                              } else {
                                                favs.agregarFavorito(producto);
                                              }
                                            },
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
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${producto.precio.toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
