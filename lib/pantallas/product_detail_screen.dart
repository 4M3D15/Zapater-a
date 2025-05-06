// lib/pantallas/product_detail_screen.dart

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modelos/cart_model.dart';
import '../modelos/favoritos_model.dart';
import '../modelos/producto_model.dart';
import '../modelos/resena_model.dart';
import '../proveedores/cart_provider.dart';
import '../widgets/animated_favorite_icon.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/animations.dart'; // AnimatedPageWrapper, SlideFadeIn, SlideFadeInFromBottom

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = true;
  late Producto producto;
  int cantidad = 1;
  String tallaSeleccionada = '';
  final List<String> tallas = [];

  final TextEditingController _comentarioController = TextEditingController();
  int _calificacionSeleccionada = 0;
  final List<Resena> _resenas = [];

  @override
  void initState() {
    super.initState();
    _cargarProducto();
    _cargarTallas();
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _cargarProducto() async {
    final doc = await FirebaseFirestore.instance
        .collection('productos')
        .doc(widget.productId)
        .get();
    if (doc.exists) {
      setState(() {
        producto = Producto.fromFirestore(doc);
        _isLoading = false;
      });
    }
  }

  Future<void> _cargarTallas() async {
    final snap = await FirebaseFirestore.instance.collection('tallas').get();
    final lista = snap.docs.map((d) => d.data()['nombre'] as String).toList();
    setState(() {
      tallas.clear();
      tallas.addAll(lista);
      if (tallas.isNotEmpty) tallaSeleccionada = tallas.first;
    });
  }

  void _mostrarSelectorTallas() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          children: tallas.map((t) {
            return ChoiceChip(
              label: Text(t),
              selected: t == tallaSeleccionada,
              onSelected: (_) {
                setState(() => tallaSeleccionada = t);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _agregarResena() {
    if (_comentarioController.text.trim().isEmpty || _calificacionSeleccionada == 0) return;

    setState(() {
      _resenas.insert(0, Resena(
        usuario: 'Anónimo',
        comentario: _comentarioController.text.trim(),
        rating: _calificacionSeleccionada,
        fecha: DateTime.now(),                   // <-- required parameter
      ));
      _comentarioController.clear();
      _calificacionSeleccionada = 0;
    });

    // Confetti
    late OverlayEntry entry;                     // <-- late declaration
    entry = OverlayEntry(builder: (_) {
      return ConfettiOverlay(onComplete: () {
        entry.remove();
      });
    });
    Overlay.of(context)!.insert(entry);
  }

  Widget _buildResenasSection() {
    return SlideFadeIn(
      index: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text('Reseñas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._resenas.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            return SlideFadeInFromBottom(
              delay: Duration(milliseconds: 100 * (i + 1)),
              child: ListTile(
                leading: CircleAvatar(child: Text(r.usuario[0])),
                title: Text(r.usuario),
                subtitle: Text(r.comentario),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (j) {
                    return Icon(
                      j < r.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          const Text('Deja tu reseña:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          SlideFadeInFromBottom(
            delay: const Duration(milliseconds: 100),
            child: TextField(
              controller: _comentarioController,
              decoration: const InputDecoration(
                hintText: 'Escribe un comentario',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SlideFadeInFromBottom(
            delay: const Duration(milliseconds: 200),
            child: Wrap(
              spacing: 8,
              children: [
                const Text('Calificación:'),
                ...List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < _calificacionSeleccionada
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () =>
                        setState(() => _calificacionSeleccionada = i + 1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                }),
                ElevatedButton(onPressed: _agregarResena, child: const Text('Agregar')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final favModel = context.watch<FavoritosModel>();
    final cartProv = context.watch<CartProvider>();
    final isFav = favModel.esFavorito(producto);
    final cartCount = cartProv.items.length;

    return AnimatedPageWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(producto.nombre),
          centerTitle: true,
          actions: [
            SlideFadeInFromBottom(
              delay: const Duration(milliseconds: 100),
              child: AnimatedFavoriteIcon(
                esFavorito: isFav,
                onTap: () {
                  if (isFav) favModel.removerFavorito(producto);
                  else favModel.agregarFavorito(producto);
                },
              ),
            ),
            Stack(alignment: Alignment.center, children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: SlideFadeInFromBottom(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Text('$cartCount',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
            ]),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SlideFadeIn(
                index: 0,
                child: Hero(
                  tag: producto.nombre,
                  child: Image.network(
                    producto.imagen,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 100),
                child: Text(producto.nombre,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 5),
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 200),
                child: Text('\$${producto.precio}',
                    style:
                    const TextStyle(fontSize: 18, color: Colors.green)),
              ),
              const SizedBox(height: 10),
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 300),
                child: Text('Categoría: ${producto.categoria}',
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 5),
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 400),
                child: Text('Descripción: ${producto.descripcion}',
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 5),
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 500),
                child: Text('Color: ${producto.color}',
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 10),
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 600),
                child: ElevatedButton(
                    onPressed: _mostrarSelectorTallas,
                    child: Text('Talla: $tallaSeleccionada')),
              ),
              const SizedBox(height: 10),
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 700),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setState(
                                () => cantidad = max(1, cantidad - 1))),
                    Text('$cantidad',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => cantidad++)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 800),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      cartProv.addToCart(CartItem(
                        nombre: producto.nombre,
                        imagen: producto.imagen,
                        precio: producto.precio,
                        talla: tallaSeleccionada,
                        cantidad: cantidad,
                      ));
                    },
                    child: const Text('Añadir al carrito'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildResenasSection(),
            ],
          ),
        ),
      ),
    );
  }
}
