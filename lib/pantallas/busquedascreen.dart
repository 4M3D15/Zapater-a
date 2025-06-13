import 'package:connectivity_plus/connectivity_plus.dart';
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
  bool _sinInternet = false;

  @override
  void initState() {
    super.initState();
    _loadProductos();
    _verificarConexion();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _sinInternet = (result == ConnectivityResult.none);
      });
    });
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

  Future<void> _verificarConexion() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _sinInternet = (connectivityResult == ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener tamaño de pantalla para adaptaciones responsivas
    final size = MediaQuery.of(context).size;

    if (_sinInternet) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Sin conexión a internet', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return SlideFadeIn(
      index: 0,
      child: Padding(
        padding: EdgeInsets.only(bottom: size.height * 0.015),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(size.width * 0.025),
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
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.15,
                ),
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.025),
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

            SizedBox(height: size.height * 0.012),

            if (filteredProductos.isEmpty)
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: EdgeInsets.only(top: size.height * 0.02),
                  child: const Text(
                    'No se encontraron productos',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: size.width < 600 ? 2 : 4, // Responsive: 2 columnas en móviles, 4 en pantallas grandes
                    mainAxisSpacing: size.height * 0.015,
                    crossAxisSpacing: size.width * 0.03,
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
                          color: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                      child: producto.imagen.isNotEmpty
                                          ? Image.network(
                                        producto.imagen,
                                        fit: BoxFit.fitWidth,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image_not_supported);
                                        },
                                      )
                                          : const Icon(Icons.image, size: 50, color: Colors.grey),
                                    ),
                                    Positioned(
                                      top: size.height * 0.01,
                                      right: size.width * 0.02,
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
                                padding: EdgeInsets.all(size.width * 0.02),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      producto.nombre,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: size.height * 0.005),
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
