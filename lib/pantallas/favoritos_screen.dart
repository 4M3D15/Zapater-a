import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../modelos/favoritos_model.dart';
import '../modelos/producto_model.dart';
import '../widgets/animated_favorite_icon.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({Key? key}) : super(key: key);

  @override
  _FavoritosScreenState createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Producto> _items;
  List<Producto>? _sugerencias;
  Timer? _timer;
  int _currentCarousel = 0;

  @override
  void initState() {
    super.initState();
    final favs = context.read<FavoritosModel>().favoritos;
    _items = List.from(favs);
    context.read<FavoritosModel>().addListener(_syncFavorites);
    FirebaseFirestore.instance.collection('productos').get().then((snap) {
      _sugerencias = snap.docs.map((d) => Producto.fromFirestore(d)).toList();
      setState(() {});
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_pageController.hasClients && (_sugerencias?.isNotEmpty ?? false)) {
          final next = (_currentCarousel + 1) % _sugerencias!.length;
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }).catchError((e) => debugPrint('Error cargando sugerencias: $e'));
  }

  void _syncFavorites() {
    final favs = context.read<FavoritosModel>().favoritos;
    for (var f in favs) {
      if (!_items.contains(f)) {
        _items.insert(0, f);
        _listKey.currentState?.insertItem(0);
      }
    }
    for (int i = _items.length - 1; i >= 0; i--) {
      if (!favs.contains(_items[i])) {
        final removed = _items.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
              (context, animation) => FadeTransition(
            opacity: animation,
            child: _buildFavoriteTile(removed),
          ),
          duration: const Duration(milliseconds: 400),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    context.read<FavoritosModel>().removeListener(_syncFavorites);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final carouselHeight = size.height * 0.25;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                "Favoritos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () =>
                    context.read<FavoritosModel>().vaciarFavoritos(),
              ),
            ],
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(
              child: Text(
                'No has seleccionado ningún favorito',
                style: TextStyle(fontSize: 18),
              ),
            )
                : AnimatedList(
              key: _listKey,
              initialItemCount: _items.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: _buildFavoriteTile(_items[index]),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Sugerencias para ti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          if (_sugerencias != null && _sugerencias!.isNotEmpty)
            SizedBox(
              height: carouselHeight + 40,
              child: Column(
                children: [
                  SizedBox(
                    height: carouselHeight,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _sugerencias!.length,
                      onPageChanged: (i) =>
                          setState(() => _currentCarousel = i),
                      itemBuilder: (_, i) {
                        final p = _sugerencias![i];
                        return GestureDetector(
                          onTap: () {
                            final favs = context.read<FavoritosModel>();
                            favs.esFavorito(p)
                                ? favs.removerFavorito(p)
                                : favs.agregarFavorito(p);
                          },
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(p.imagen,
                                      fit: BoxFit.cover),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: AnimatedFavoriteIcon(
                                      esFavorito: context
                                          .watch<FavoritosModel>()
                                          .esFavorito(p),
                                      onTap: () {
                                        final favs =
                                        context.read<FavoritosModel>();
                                        favs.esFavorito(p)
                                            ? favs.removerFavorito(p)
                                            : favs.agregarFavorito(p);
                                      },
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _sugerencias!.length,
                          (i) => Container(
                        width: i == _currentCarousel ? 14 : 10,
                        height: i == _currentCarousel ? 14 : 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _currentCarousel
                              ? Colors.black87
                              : Colors.black26,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoriteTile(Producto p) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading:
        Image.network(p.imagen, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(p.nombre),
        subtitle: Text('\$${p.precio.toStringAsFixed(2)}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () =>
              context.read<FavoritosModel>().removerFavorito(p),
        ),
      ),
    );
  }
}
