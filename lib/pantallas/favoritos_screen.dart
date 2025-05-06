import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

import '../modelos/favoritos_model.dart';
import '../modelos/producto_model.dart';
import '../widgets/animated_favorite_icon.dart';
import '../widgets/particle_explosion.dart';
import '../widgets/animations.dart'; // <-- tus animaciones centralizadas

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({Key? key}) : super(key: key);

  @override
  _FavoritosScreenState createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Map<Producto, GlobalKey> _tileKeys = {};
  late List<Producto> _items;
  List<Producto>? _sugerencias;
  Timer? _timer;
  int _currentCarousel = 0;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Inicial _items desde el modelo
    _items = List.from(context.read<FavoritosModel>().favoritos);
    context.read<FavoritosModel>().addListener(_syncFavorites);

    // Carga sugerencias y autoplay
    FirebaseFirestore.instance
        .collection('productos')
        .get()
        .then((snap) {
      _sugerencias =
          snap.docs.map((d) => Producto.fromFirestore(d)).toList();
      setState(() {});
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_pageController.hasClients &&
            (_sugerencias?.isNotEmpty ?? false)) {
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
    // Inserciones nuevas
    for (var f in favs) {
      if (!_items.contains(f)) {
        _items.insert(0, f);
        _listKey.currentState?.insertItem(0);
      }
    }
    // Remociones
    for (int i = _items.length - 1; i >= 0; i--) {
      if (!favs.contains(_items[i])) {
        final removed = _items.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
              (ctx, anim) => SlideFadeInFromBottom(
            delay: Duration(milliseconds: 50 * i),
            child: FadeTransition(
              opacity: anim,
              child: _buildFavoriteTile(removed),
            ),
          ),
          duration: const Duration(milliseconds: 400),
        );
      }
    }
  }

  Future<void> _playExplosionSound() async {
    try {
      await _player.play(AssetSource('sounds/explosion.mp3'),
          volume: 0.7);
    } catch (e) {
      debugPrint('Error al reproducir sonido: $e');
    }
  }

  @override
  void dispose() {
    context.read<FavoritosModel>().removeListener(_syncFavorites);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final carouselHeight = size.height * 0.25;

    return SlideFadeIn(
      index: 0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Título “Favoritos” ───
            SlideFadeInFromBottom(
              delay: const Duration(milliseconds: 100),
              child: const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    "Favoritos",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // ─── Botón vaciar ───
            SlideFadeInFromBottom(
              delay: const Duration(milliseconds: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () {
                      final favoritos =
                          context.read<FavoritosModel>().favoritos;
                      if (favoritos.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "No hay favoritos para eliminar.")),
                        );
                        return;
                      }
                      // Confirmación con explosiones
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              '¿Vaciar todos los favoritos?'),
                          action: SnackBarAction(
                            label: 'Sí',
                            onPressed: () async {
                              final favModel =
                              context.read<FavoritosModel>();
                              final overlay = Overlay.of(context);
                              for (final prod
                              in List<Producto>.from(
                                  favModel.favoritos)) {
                                final key = _tileKeys[prod];
                                final box = key
                                    ?.currentContext
                                    ?.findRenderObject()
                                as RenderBox?;
                                if (box != null) {
                                  final pos = box.localToGlobal(
                                      box.size.center(Offset.zero));
                                  late OverlayEntry exp;
                                  exp = OverlayEntry(
                                    builder: (_) => ParticleExplosion(
                                      position: pos,
                                      onComplete: () =>
                                          exp.remove(),
                                    ),
                                  );
                                  overlay.insert(exp);
                                  await _playExplosionSound();
                                  await Future.delayed(
                                      const Duration(
                                          milliseconds: 100));
                                }
                                favModel.removerFavorito(prod);
                                await Future.delayed(
                                    const Duration(
                                        milliseconds: 150));
                              }
                            },
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ─── Lista de favoritos ───
            Expanded(
              child: _items.isEmpty
                  ? SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 300),
                child: const Center(
                  child: Text(
                    'No has seleccionado ningún favorito',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
                  : AnimatedList(
                key: _listKey,
                initialItemCount: _items.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder:
                    (context, index, animation) {
                  return SlideFadeInFromBottom(
                    delay: Duration(
                        milliseconds: 100 * (index + 1)),
                    child: FadeTransition(
                      opacity: animation,
                      child: _buildFavoriteTile(
                          _items[index]),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ─── “Sugerencias para ti” ───
            if (_sugerencias != null &&
                _sugerencias!.isNotEmpty) ...[
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 400),
                child: const Text(
                  'Sugerencias para ti',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: carouselHeight,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _sugerencias!.length,
                  onPageChanged: (i) =>
                      setState(() => _currentCarousel = i),
                  itemBuilder: (_, i) {
                    final p = _sugerencias![i];
                    return SlideFadeInFromBottom(
                      delay: Duration(
                          milliseconds: 100 * (i + 1)),
                      child: GestureDetector(
                        onTap: () {
                          final favs =
                          context.read<FavoritosModel>();
                          favs.esFavorito(p)
                              ? favs.removerFavorito(p)
                              : favs.agregarFavorito(p);
                        },
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 8),
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(16),
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
                                        .watch<
                                        FavoritosModel>()
                                        .esFavorito(p),
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: List.generate(
                  _sugerencias!.length,
                      (i) => Container(
                    width: i == _currentCarousel
                        ? 14
                        : 10,
                    height: i == _currentCarousel
                        ? 14
                        : 10,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentCarousel
                          ? Colors.black87
                          : Colors.black26,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteTile(Producto p) {
    final key =
    _tileKeys.putIfAbsent(p, () => GlobalKey());
    return Card(
      key: key,
      margin:
      const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: Image.network(p.imagen,
            width: 50, height: 50, fit: BoxFit.cover),
        title: Text(p.nombre),
        subtitle: Text('\$${p.precio.toStringAsFixed(2)}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            final box = key.currentContext
                ?.findRenderObject() as RenderBox?;
            if (box != null) {
              final center = box
                  .localToGlobal(box.size.center(Offset.zero));
              late OverlayEntry explosion;
              explosion = OverlayEntry(
                builder: (_) => ParticleExplosion(
                  position: center,
                  onComplete: () => explosion.remove(),
                ),
              );
              Overlay.of(context).insert(explosion);
              await _playExplosionSound();
            }
            context.read<FavoritosModel>().removerFavorito(p);
          },
        ),
      ),
    );
  }
}
