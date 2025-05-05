// lib/pantallas/inicio_content.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/productos_model.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/widgets/animated_favorite_icon.dart';

class InicioContent extends StatefulWidget {
  const InicioContent({Key? key}) : super(key: key);

  @override
  _InicioContentState createState() => _InicioContentState();
}

class _InicioContentState extends State<InicioContent> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _autoPlayTimer;
  List? _productos;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final productosModel = Provider.of<ProductosModel>(context);
    if (productosModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (productosModel.error != null) {
      return Center(child: Text(productosModel.error!));
    }

    _productos = productosModel.productos;
    final size = MediaQuery.of(context).size;
    final carouselHeight = size.height * 0.28;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zapatería', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
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
                    arguments: p.id,    // ← enviamos sólo el String id
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(p.imagen, fit: BoxFit.cover),
                          Positioned(
                            top: 8, right: 8,
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
                            bottom: 0, left: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black54],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Text(p.nombre, style: const TextStyle(color: Colors.white)),
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

          // Grid de productos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size.width < 600 ? 2 : 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: size.width < 600 ? 0.75 : 0.65,
                ),
                itemCount: _productos!.length,
                itemBuilder: (ctx, i) {
                  final p = _productos![i];
                  return Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/product',
                        arguments: p.id,  // ← enviamos sólo el String id
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
                                  Image.network(p.imagen, fit: BoxFit.cover),
                                  Positioned(
                                    top: 8, right: 8,
                                    child: Consumer<FavoritosModel>(
                                      builder: (_, fav2, __) {
                                        final favFlag = fav2.esFavorito(p);
                                        return AnimatedFavoriteIcon(
                                          esFavorito: favFlag,
                                          onTap: () => favFlag
                                              ? fav2.removerFavorito(p)
                                              : fav2.agregarFavorito(p),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('\$${p.precio.toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
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
          ),
        ],
      ),
    );
  }
}
