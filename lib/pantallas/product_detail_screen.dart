import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/producto_model.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/proveedores/cart_provider.dart';
import 'package:zapato/modelos/cart_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Producto producto;

  const ProductDetailScreen({super.key, required this.producto});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int cantidad = 1;
  String tallaSeleccionada = "23 cm";
  final List<String> tallas = ["23 cm", "24 cm", "25 cm", "26 cm", "27 cm", "28 cm"];

  final TextEditingController _comentarioController = TextEditingController();
  int _calificacionSeleccionada = 0;
  final List<Map<String, dynamic>> _resenas = [];

  void _mostrarSelectorTallas() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Selecciona tu talla", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: tallas.map((talla) {
                  final bool seleccionado = talla == tallaSeleccionada;
                  return ChoiceChip(
                    label: Text(talla),
                    selected: seleccionado,
                    onSelected: (selected) {
                      setState(() => tallaSeleccionada = talla);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _agregarResena() {
    if (_comentarioController.text.trim().isEmpty || _calificacionSeleccionada == 0) return;

    setState(() {
      _resenas.add({
        "usuario": "Anónimo",
        "comentario": _comentarioController.text.trim(),
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
        const SizedBox(height: 8),
        ..._resenas.map((resena) {
          return ListTile(
            leading: CircleAvatar(child: Text(resena["usuario"][0])),
            title: Text(resena["usuario"]),
            subtitle: Text(resena["comentario"]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) => Icon(
                i < resena["rating"] ? Icons.star : Icons.star_border,
                color: Colors.amber, size: 16,
              )),
            ),
          );
        }).toList(),
        const SizedBox(height: 10),
        const Text("Deja tu reseña:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: _comentarioController,
          decoration: const InputDecoration(
            hintText: "Escribe un comentario",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            const Text("Calificación: "),
            ...List.generate(5, (i) => IconButton(
              icon: Icon(
                i < _calificacionSeleccionada ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => setState(() => _calificacionSeleccionada = i + 1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )),
            ElevatedButton(
              onPressed: _agregarResena,
              child: const Text("Agregar"),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final favoritosModel = Provider.of<FavoritosModel>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final isFavorito = favoritosModel.esFavorito(producto);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(producto.nombre),
        centerTitle: true,
        actions: [
          AnimatedFavoriteIcon(
            esFavorito: isFavorito,
            onTap: () {
              if (isFavorito) {
                favoritosModel.removerFavorito(producto);
              } else {
                favoritosModel.agregarFavorito(producto);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              producto.imagen,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
            ),
            const SizedBox(height: 10),
            Text(producto.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("\$${producto.precio}", style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _mostrarSelectorTallas,
              child: Text("Talla: $tallaSeleccionada"),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.remove), onPressed: () {
                  if (cantidad > 1) setState(() => cantidad--);
                }),
                Text("$cantidad", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => cantidad++)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Añadir al carrito"),
              ),
            ),
            _buildResenasSection(),
          ],
        ),
      ),
    );
  }
}

class AnimatedFavoriteIcon extends StatelessWidget {
  final bool esFavorito;
  final Function onTap;

  const AnimatedFavoriteIcon({super.key, required this.esFavorito, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: esFavorito
            ? const Icon(Icons.favorite, color: Colors.red, key: ValueKey(1))
            : const Icon(Icons.favorite_border, color: Colors.black, key: ValueKey(0)),
      ),
    );
  }
}
