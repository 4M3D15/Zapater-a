import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

import '../modelos/favoritos_model.dart';
import '../modelos/producto_model.dart';
import '../widgets/animated_favorite_icon.dart';
import '../widgets/particle_explosion.dart';
import '../widgets/animations.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({Key? key}) : super(key: key);

  @override
  _FavoritosScreenState createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Map<Producto, GlobalKey> _tileKeys = {};
  late List<Producto> _items;
  List<Producto>? _sugerencias;
  Timer? _timer;
  int _currentCarousel = 0;
  final AudioPlayer _player = AudioPlayer();
  bool _sinInternet = false;
  FavoritosModel? _favoritosModel;

  @override
  void initState() {
    super.initState();
    _favoritosModel = context.read<FavoritosModel>();
    _items = List.from(context.read<FavoritosModel>().favoritos);
    context.read<FavoritosModel>().addListener(_syncFavorites);

    _verificarConexion();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _sinInternet = (result == ConnectivityResult.none);
      });
    });

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

  Future<void> _verificarConexion() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _sinInternet = (connectivityResult == ConnectivityResult.none);
    });
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
      await _player.play(AssetSource('sounds/explosion.mp3'), volume: 0.7);
    } catch (e) {
      debugPrint('Error al reproducir sonido: $e');
    }
  }

  @override
  void dispose() {
    _favoritosModel?.removeListener(_syncFavorites);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.25;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título y botón eliminar en fila fija con altura
                  SizedBox(

                    height: 70,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever),
                            onPressed: () {
                              if (_sinInternet) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Solo vista, sin acciones.")),
                                );
                                return;
                              }
                              final favoritos = context.read<FavoritosModel>().favoritos;
                              if (favoritos.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("No hay favoritos para eliminar.")),
                                );
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('¿Vaciar todos los favoritos?'),
                                  action: SnackBarAction(
                                    label: 'Sí',
                                    onPressed: () async {
                                      if (_sinInternet) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Solo vista, sin acciones.")),
                                        );
                                        return;
                                      }
                                      final favModel = context.read<FavoritosModel>();
                                      final overlay = Overlay.of(context);
                                      for (final prod in List<Producto>.from(favModel.favoritos)) {
                                        final key = _tileKeys[prod];
                                        final box = key?.currentContext?.findRenderObject() as RenderBox?;
                                        if (box != null) {
                                          final pos = box.localToGlobal(box.size.center(Offset.zero));
                                          late OverlayEntry exp;
                                          exp = OverlayEntry(
                                            builder: (_) => ParticleExplosion(
                                              position: pos,
                                              onComplete: () => exp.remove(),
                                            ),
                                          );
                                          overlay.insert(exp);
                                          await _playExplosionSound();
                                          await Future.delayed(const Duration(milliseconds: 100));
                                        }
                                        favModel.removerFavorito(prod);
                                        await Future.delayed(const Duration(milliseconds: 150));
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
                  ),

                  // Lista favoritos o mensaje vacío
                  Container(
                    color: Colors.white,
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.45,
                    ),
                    child: _items.isEmpty
                        ? const Center(
                      child: Padding(

                        padding: EdgeInsets.all(20.0),
                        child: Text('No has seleccionado ningún favorito', style: TextStyle(fontSize: 18)),
                      ),
                    )
                        : Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return SlideFadeInFromBottom(
                            delay: Duration(milliseconds: 100 * (index + 1)),
                            child: _buildFavoriteTile(_items[index]),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sugerencias y carrusel con corazón para favoritos
                  if (_sugerencias != null && _sugerencias!.isNotEmpty && !_sinInternet) ...[
                    const Padding(

                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child:
                      Text(
                        'Sugerencias para ti',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(

                      height: carouselHeight,
                      child: PageView.builder(

                        controller: _pageController,
                        itemCount: _sugerencias!.length,
                        onPageChanged: (i) => setState(() => _currentCarousel = i),
                        itemBuilder: (_, i) {
                          final p = _sugerencias![i];
                          final esFavorito = context.watch<FavoritosModel>().esFavorito(p);
                          return SlideFadeInFromBottom(
                            delay: Duration(milliseconds: 100 * (i + 1)),
                            child: Stack(

                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (_sinInternet) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Sin internet, no se puede abrir.")),
                                      );
                                      return;
                                    }
                                    context.read<FavoritosModel>().agregarFavorito(p);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("${p.nombre} agregado a favoritos")),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                        image: NetworkImage(p.imagen),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                     // color: Colors.white,
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                                      ),
                                      child: Text(
                                        p.nombre,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                // Corazón en la esquina superior derecha
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: AnimatedFavoriteIcon(
                                    esFavorito: esFavorito,
                                    onTap: () async {
                                      if (_sinInternet) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Solo vista, sin acciones.")),
                                        );
                                        return;
                                      }
                                      final favs = context.read<FavoritosModel>();
                                      if (esFavorito) {
                                        favs.removerFavorito(p);
                                      } else {
                                        favs.agregarFavorito(p);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteTile(Producto producto) {
    final esFavorito = context.watch<FavoritosModel>().esFavorito(producto);
    _tileKeys[producto] = GlobalKey();
    return Container(
      key: _tileKeys[producto],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(producto.imagen, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(producto.nombre),
        trailing: AnimatedFavoriteIcon(
          esFavorito: esFavorito,
          onTap: () async {
            if (_sinInternet) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Solo vista, sin acciones.")),
              );
              return;
            }
            final favs = context.read<FavoritosModel>();
            if (esFavorito) {
              favs.removerFavorito(producto);
            } else {
              favs.agregarFavorito(producto);
            }
          },
        ),
      ),
    );
  }
}
