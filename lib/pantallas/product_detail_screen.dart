import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/cart_model.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/modelos/producto_model.dart';
import 'package:zapato/proveedores/cart_provider.dart';
import 'package:zapato/widgets/animated_favorite_icon.dart';
import 'package:zapato/widgets/animated_page_wrapper.dart';
import 'package:zapato/modelos/resena_model.dart';
import 'package:zapato/widgets/confetti_overlay.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late Producto producto;
  int cantidad = 1;
  String tallaSeleccionada = '';
  final List<String> tallas = [];
  final TextEditingController _comentarioController = TextEditingController();
  int _calificacionSeleccionada = 0;
  final List<Map<String, dynamic>> _resenas = [];
  final GlobalKey _addBtnKey = GlobalKey();
  final GlobalKey _cartIconKey = GlobalKey();
  late AnimationController _aniController;
  OverlayEntry? _overlayEntry;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cargarProducto();
    _cargarTallas();
  }

  @override
  void dispose() {
    _aniController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _cargarProducto() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('productos')
          .doc(widget.productId)
          .get();
      if (doc.exists) {
        setState(() {
          producto = Producto.fromFirestore(doc);
          _isLoading = false;
        });
      } else {
        debugPrint('El producto no existe en la base de datos.');
      }
    } catch (e) {
      debugPrint('Error al cargar el producto: $e');
    }
  }

  Future<void> _cargarTallas() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('tallas').get();
      final lista = snapshot.docs.map((d) => d.data()['nombre'] as String).toList();
      setState(() {
        tallas.clear();
        tallas.addAll(lista);
        if (tallas.isNotEmpty) tallaSeleccionada = tallas.first;
      });
    } catch (e) {
      debugPrint('Error al cargar tallas: $e');
    }
  }

  void _runAddToCartAnimation(Widget image) {
    final addBox = _addBtnKey.currentContext!.findRenderObject() as RenderBox;
    final start = addBox.localToGlobal(addBox.size.center(Offset.zero));
    final iconBox = _cartIconKey.currentContext!.findRenderObject() as RenderBox;
    final end = iconBox.localToGlobal(iconBox.size.center(Offset.zero));
    _animation = Tween<Offset>(begin: start, end: end).animate(
      CurvedAnimation(parent: _aniController, curve: Curves.easeInOut),
    );
    _overlayEntry = OverlayEntry(builder: (_) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (_, __) => Positioned(
          left: _animation.value.dx - 25,
          top: _animation.value.dy - 25,
          child: SizedBox(width: 50, height: 50, child: image),
        ),
      );
    });
    Overlay.of(context)!.insert(_overlayEntry!);
    _aniController.forward().whenComplete(() {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _aniController.reset();
    });
  }

  void _mostrarSelectorTallas() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona tu talla', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: tallas.map((t) => ChoiceChip(
                label: Text(t),
                selected: t == tallaSeleccionada,
                onSelected: (_) => setState(() {
                  tallaSeleccionada = t;
                  Navigator.pop(ctx);
                }),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _agregarResena() {
    if (_comentarioController.text.trim().isEmpty || _calificacionSeleccionada == 0) return;

    setState(() {
      _resenas.add({
        'usuario': 'Anónimo',
        'comentario': _comentarioController.text.trim(),
        'rating': _calificacionSeleccionada,
      });
      _comentarioController.clear();
      _calificacionSeleccionada = 0;
    });

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ConfettiOverlay(onComplete: () {
        entry.remove();
      }),
    );

    Overlay.of(context).insert(entry);

  }

  Widget _buildResenasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Reseñas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._resenas.map((res) => ListTile(
          leading: CircleAvatar(child: Text(res['usuario'][0])),
          title: Text(res['usuario']),
          subtitle: Text(res['comentario']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) => Icon(
              i < res['rating'] ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 16,
            )),
          ),
        )),
        const SizedBox(height: 10),
        const Text('Deja tu reseña:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: _comentarioController,
          decoration: const InputDecoration(hintText: 'Escribe un comentario', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            const Text('Calificación: '),
            ...List.generate(5, (i) => IconButton(
              icon: Icon(i < _calificacionSeleccionada ? Icons.star : Icons.star_border, color: Colors.amber),
              onPressed: () => setState(() => _calificacionSeleccionada = i + 1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )),
            ElevatedButton(onPressed: _agregarResena, child: const Text('Agregar')),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final favModel = Provider.of<FavoritosModel>(context);
    final cartProv = Provider.of<CartProvider>(context);
    final isFav = favModel.esFavorito(producto);
    final cartCount = cartProv.items.length;

    return AnimatedPageWrapper(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          title: Text(producto.nombre),
          centerTitle: true,
          actions: [
            AnimatedFavoriteIcon(
              esFavorito: isFav,
              onTap: () {
                if (isFav) favModel.removerFavorito(producto);
                else favModel.agregarFavorito(producto);
              },
            ),
            Stack(alignment: Alignment.center, children: [
              IconButton(key: _cartIconKey, icon: const Icon(Icons.shopping_cart), onPressed: () {}),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(cartCount),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
            ])
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: producto.nombre,
                child: Image.network(
                  producto.imagen,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                ),
              ),
              const SizedBox(height: 10),
              Text(producto.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('\$${producto.precio}', style: const TextStyle(fontSize: 18, color: Colors.green)),
              const SizedBox(height: 10),
              Text('Categoría: ${producto.categoria}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              Text('Descripción: ${producto.descripcion}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              Text('Color: ${producto.color}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _mostrarSelectorTallas, child: Text('Talla: $tallaSeleccionada')),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => cantidad = cantidad > 1 ? cantidad - 1 : 1)),
                  Text('$cantidad', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => cantidad++)),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: _addBtnKey,
                  onPressed: () {
                    _runAddToCartAnimation(Image.network(producto.imagen, fit: BoxFit.cover));
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
              const SizedBox(height: 16),
              _buildResenasSection(),
            ],
          ),
        ),
      ),
    );
  }
}
