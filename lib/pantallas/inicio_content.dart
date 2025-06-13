import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/productos_model.dart';
import '../modelos/favoritos_model.dart';
import '../widgets/animated_favorite_icon.dart';
import '../widgets/animations.dart'; // Asegúrate de tener esto
import 'package:connectivity_plus/connectivity_plus.dart';

class InicioContent extends StatefulWidget {
  final ScrollController scrollController;

  const InicioContent({Key? key, required this.scrollController}) : super(key: key);

  @override
  _InicioContentState createState() => _InicioContentState();
}

class _InicioContentState extends State<InicioContent> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _autoPlayTimer;
  List? _productos;
  bool _sinInternet = false;

  // Nueva variable de estado para el filtro por sexo
  String _sexoSeleccionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _verificarConexion();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _sinInternet = (result == ConnectivityResult.none);
      });
    });

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients && _productos != null) {
        final next = (_currentPage + 1) % _productos!.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _verificarConexion() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _sinInternet = (connectivityResult == ConnectivityResult.none);
    });
  }

  // Método para filtrar productos según el sexo seleccionado, ignorando mayúsculas
  List filtrarProductos(List productos) {
    if (_sexoSeleccionado.toLowerCase() == 'todos') {
      return productos;
    } else {
      final sexoFiltro = _sexoSeleccionado.toLowerCase();
      final filtrados = productos.where((p) {
        // Asume que p.sexo es String
        final sexoProducto = (p.sexo ?? '').toString().toLowerCase();
        print('Producto: ${p.nombre}, sexo: $sexoProducto, filtro: $sexoFiltro');
        return sexoProducto == sexoFiltro;
      }).toList();

      print('Productos filtrados: ${filtrados.length}');
      return filtrados;
    }
  }

  // Método para capitalizar la primera letra para mostrar en los botones
  String capitalizar(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final productosModel = context.watch<ProductosModel>();

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

    if (productosModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (productosModel.error != null) {
      return Center(child: Text(productosModel.error!));
    }

    _productos = productosModel.productos;
    final size = MediaQuery.of(context).size;
    final carouselHeight = size.height * 0.28;

    // Filtrar productos según sexo seleccionado
    final productosFiltrados = filtrarProductos(_productos!);

    return SlideFadeIn(
      index: 0,
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            // Carrusel
            SizedBox(
              height: carouselHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _productos!.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (ctx, i) {
                  final p = _productos![i];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/product',
                      arguments: p.id,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              p.imagen,
                              fit: BoxFit.fitWidth,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported);
                              },
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Consumer<FavoritosModel>(
                                builder: (_, fav, __) {
                                  final isFav = fav.esFavorito(p);
                                  return AnimatedFavoriteIcon(
                                    esFavorito: isFav,
                                    onTap: () => isFav
                                        ? fav.removerFavorito(p)
                                        : fav.agregarFavorito(p),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, Colors.black54],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Text(
                                  p.nombre,
                                  style: const TextStyle(color: Colors.white),
                                ),
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

            const SizedBox(height: 8),

            // Indicadores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_productos!.length, (i) {
                final active = i == _currentPage;
                return GestureDetector(
                  onTap: () => _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  ),
                  child: Container(
                    width: active ? 14 : 10,
                    height: active ? 14 : 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? Colors.black87 : Colors.black26,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            // Botones de filtro por sexo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: ['Todos', 'Hombre', 'Mujer', 'Niño'].map((sexo) {
                    final activo = _sexoSeleccionado.toLowerCase() == sexo.toLowerCase();
                    return ElevatedButton(
                      onPressed: () {
                        setState(() => _sexoSeleccionado = sexo);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activo ? Colors.black87 : Colors.grey.shade300,
                        foregroundColor: activo ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(capitalizar(sexo)),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Grid de productos filtrados
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size.width < 600 ? 2 : 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: size.width < 600 ? 0.75 : 0.65,
                ),
                itemCount: productosFiltrados.length,
                itemBuilder: (ctx, i) {
                  final p = productosFiltrados[i];
                  return SlideFadeInFromBottom(
                    delay: Duration(milliseconds: 100 * i),
                    child: Material(
                      color: Colors.white,
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/product',
                          arguments: p.id,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      p.imagen,
                                      fit: BoxFit.fitWidth,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.image_not_supported);
                                      },
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Consumer<FavoritosModel>(
                                        builder: (_, fav, __) {
                                          final isFav = fav.esFavorito(p);
                                          return AnimatedFavoriteIcon(
                                            esFavorito: isFav,
                                            onTap: () => isFav
                                                ? fav.removerFavorito(p)
                                                : fav.agregarFavorito(p),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(

                              padding: const EdgeInsets.all(6),
                              child: Text(
                                p.nombre,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                     backgroundColor: Colors.white,
                                     color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text('\$${p.precio.toStringAsFixed(2)}'),
                            ),
                            const SizedBox(height: 6),
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
