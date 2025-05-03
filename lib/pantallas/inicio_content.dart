import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/productos_model.dart';
import 'package:zapato/widgets/animated_favorite_icon.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;

class InicioContent extends StatefulWidget {
  const InicioContent({Key? key}) : super(key: key);

  @override
  State<InicioContent> createState() => _InicioContentState();
}

class _InicioContentState extends State<InicioContent> {
  final carousel.CarouselController _carouselController = carousel.CarouselController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productosModel = Provider.of<ProductosModel>(context);

    if (productosModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (productosModel.error != null) {
      return Center(child: Text(productosModel.error!));
    }

    final productos = productosModel.productos;
    final size = MediaQuery.of(context).size;
    final carouselHeight = size.height * 0.28;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Zapatería',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 60,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Carrusel de productos
          carousel.CarouselSlider(
            carouselController: _carouselController,
            options: carousel.CarouselOptions(
              height: carouselHeight,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.85,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
            items: productos.map((producto) {
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/product', arguments: producto),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        producto.imagen,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                      // Icono de favorito en el carrusel
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Consumer<FavoritosModel>(
                          builder: (context, favModel, child) {
                            final esFav = favModel.esFavorito(producto);
                            return AnimatedFavoriteIcon(
                              esFavorito: esFav,
                              onTap: () => esFav
                                  ? favModel.removerFavorito(producto)
                                  : favModel.agregarFavorito(producto),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black54],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Text(
                            producto.nombre,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),
          // Indicadores del carrusel con fondo semitransparente
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: productos.asMap().entries.map((entry) {
                final idx = entry.key;
                final isActive = idx == _currentIndex;
                return GestureDetector(
                  onTap: () => _carouselController.animateToPage(idx),
                  child: Container(
                    width: isActive ? 14 : 10,
                    height: isActive ? 14 : 10,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.black87 : Colors.black26,
                    ),
                  ),
                );
              }).toList(),
            ),
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
                itemCount: productos.length,
                itemBuilder: (ctx, index) {
                  final producto = productos[index];
                  return Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pushNamed(ctx, '/product', arguments: producto),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(producto.imagen, fit: BoxFit.cover),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Consumer<FavoritosModel>(
                                      builder: (context, favModel, child) {
                                        final esFav = favModel.esFavorito(producto);
                                        return AnimatedFavoriteIcon(
                                          esFavorito: esFav,
                                          onTap: () => esFav
                                              ? favModel.removerFavorito(producto)
                                              : favModel.agregarFavorito(producto),
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
                                Text(
                                  producto.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${producto.precio.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }
}
