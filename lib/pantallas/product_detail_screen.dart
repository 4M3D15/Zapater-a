// lib/pantallas/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/proveedores/cart_provider.dart';
import 'package:zapato/modelos/cart_model.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/modelos/productos_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Producto producto;

  const ProductDetailScreen({Key? key, required this.producto}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int cantidad = 1;
  String tallaSeleccionada = "23 cm";
  final tallas = ["23 cm", "24 cm", "25 cm", "26 cm", "27 cm", "28 cm"];

  final _comentarioController = TextEditingController();
  int _calificacionSeleccionada = 0;
  final _resenas = <Map<String, dynamic>>[];

  void _mostrarSelectorTallas() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Selecciona tu talla", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
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
        ]),
      ),
    );
  }

  void _agregarResena() {
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty || _calificacionSeleccionada == 0) return;
    setState(() {
      _resenas.add({
        "usuario": "Anónimo",
        "comentario": texto,
        "rating": _calificacionSeleccionada,
      });
      _comentarioController.clear();
      _calificacionSeleccionada = 0;
    });
  }

  Widget _buildResenasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text("Reseñas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ..._resenas.map((r) => ListTile(
          leading: CircleAvatar(child: Text(r["usuario"][0])),
          title: Text(r["usuario"]),
          subtitle: Text(r["comentario"]),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
                  (i) => Icon(
                i < r["rating"] ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              ),
            ),
          ),
        )),
        const SizedBox(height: 10),
        const Text("Deja tu reseña:", style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: _comentarioController,
          decoration: const InputDecoration(hintText: "Escribe un comentario", border: OutlineInputBorder()),
        ),
        Row(children: [
          const Text("Calificación:"),
          ...List.generate(5, (i) => IconButton(
            icon: Icon(i < _calificacionSeleccionada ? Icons.star : Icons.star_border, color: Colors.amber),
            onPressed: () => setState(() => _calificacionSeleccionada = i + 1),
          )),
          ElevatedButton(onPressed: _agregarResena, child: const Text("Agregar")),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final favoritosModel = Provider.of<FavoritosModel>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final esFav = favoritosModel.esFavorito(producto);

    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        centerTitle: true,
        leading: BackButton(),
        actions: [
          IconButton(
            icon: Icon(esFav ? Icons.favorite : Icons.favorite_border, color: esFav ? Colors.red : null),
            onPressed: () => esFav
                ? favoritosModel.removerFavorito(producto)
                : favoritosModel.agregarFavorito(producto),
          ),
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => Navigator.pushNamed(context, '/cart')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.network(producto.imagen, height: 200, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100)),
          const SizedBox(height: 10),
          Text(producto.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("\$${producto.precio}", style: const TextStyle(fontSize: 18, color: Colors.green)),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _mostrarSelectorTallas, child: Text("Talla: $tallaSeleccionada")),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.remove), onPressed: cantidad > 1 ? () => setState(() => cantidad--) : null),
            Text("$cantidad", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => cantidad++)),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text("Añadir al carrito"),
              onPressed: () {
                cartProvider.addToCart(CartItem(
                  nombre: producto.nombre,
                  imagen: producto.imagen,
                  precio: producto.precio,
                  talla: tallaSeleccionada,
                  cantidad: cantidad,
                ));
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildResenasSection(),
        ]),
      ),
    );
  }
}
