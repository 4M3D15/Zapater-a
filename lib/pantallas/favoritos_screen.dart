import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/modelos/producto_model.dart';
import 'package:zapato/widgets/animated_favorite_icon.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({Key? key}) : super(key: key);

  @override
  _FavoritosScreenState createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _current = 0;
  List<Producto>? _sugerencias;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Cargar sugerencias de Firestore
    FirebaseFirestore.instance.collection('productos').get().then((snap) {
      setState(() => _sugerencias = snap.docs.map((d) => Producto.fromFirestore(d)).toList());
      // Auto-play cada 4s
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (_pageController.hasClients && _sugerencias != null) {
          final next = (_current + 1) % _sugerencias!.length;
          _pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoritos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => Provider.of<FavoritosModel>(context, listen: false).vaciarFavoritos(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de favoritos
          Expanded(
            child: Consumer<FavoritosModel>(
              builder: (_, favModel, __) {
                final favs = favModel.favoritos;
                if (favs.isEmpty) {
                  return const Center(child: Text("No tienes favoritos aún"));
                }
                return ListView.builder(
                  itemCount: favs.length,
                  itemBuilder: (_, i) {
                    final p = favs[i];
                    return Dismissible(
                      key: Key(p.nombre),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => favModel.removerFavorito(p),
                      child: ListTile(
                        leading: Image.network(p.imagen, width: 50, height: 50),
                        title: Text(p.nombre),
                        subtitle: Text("\$${p.precio.toStringAsFixed(2)}"),
                        trailing: AnimatedFavoriteIcon(esFavorito: true, onTap: () => favModel.removerFavorito(p)),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Sugerencias para ti", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),

          // Carrusel de sugerencias con PageView
          if (_sugerencias == null)
            const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()))
          else
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _sugerencias!.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) {
                  final p = _sugerencias![i];
                  return GestureDetector(
                    onTap: () {
                      final favs = Provider.of<FavoritosModel>(context, listen: false);
                      favs.esFavorito(p) ? favs.removerFavorito(p) : favs.agregarFavorito(p);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(image: NetworkImage(p.imagen), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: Consumer<FavoritosModel>(
                              builder: (_, fav, __) {
                                final isFav = fav.esFavorito(p);
                                return AnimatedFavoriteIcon(
                                  esFavorito: isFav,
                                  onTap: () => isFav ? fav.removerFavorito(p) : fav.agregarFavorito(p),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
