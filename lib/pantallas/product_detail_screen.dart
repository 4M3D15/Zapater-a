import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/cart_model.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import '../proveedores/cart_provider.dart';
import '../widgets/animated_favorite_icon.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  const ProductDetailScreen({super.key, required this.producto});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int cantidad = 1;
  // Valor inicial para la talla
  String tallaSeleccionada = "23 cm";
  // Lista de tallas en centímetros (puedes ajustar estos valores)
  final List<String> tallas = ["23 cm", "24 cm", "25 cm", "26 cm", "27 cm", "28 cm"];

  // Datos de ejemplo para comentarios y reseñas
  final List<Map<String, dynamic>> reseñas = [
  {"usuario": "Juan", "comentario": "¡Producto excelente!", "rating": 5},
  {"usuario": "María", "comentario": "Buena calidad, pero un poco caro.", "rating": 4},
  {"usuario": "Carlos", "comentario": "Me encantó, superó mis expectativas.", "rating": 5},
  ];

  void _mostrarSelectorTallas() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Selecciona tu talla",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: tallas.map((talla) {
                  final bool seleccionado = talla == tallaSeleccionada;
                  return ChoiceChip(
                    label: Text(talla),
                    selected: seleccionado,
                    onSelected: (selected) {
                      setState(() {
                        tallaSeleccionada = talla;
                      });
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

  Widget _buildReseñasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          "Reseñas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reseñas.length,
          itemBuilder: (context, index) {
            final reseña = reseñas[index];
            return ListTile(
            leading: CircleAvatar(
            child: Text(reseña["usuario"][0]),
            ),
            title: Text(reseña["usuario"]),
            subtitle: Text(reseña["comentario"]),
            trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
            5,
            (i) => Icon(
            i < reseña["rating"] ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 16,
            ),
            ),
            ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritosModel = Provider.of<FavoritosModel>(context);
    final isFavorito = favoritosModel.esFavorito(widget.producto);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.producto["nombre"]),
        centerTitle: true,
        actions: [
          AnimatedFavoriteIcon(
            esFavorito: isFavorito,
            onTap: () {
              if (isFavorito) {
                favoritosModel.removerFavorito(widget.producto);
              } else {
                favoritosModel.agregarFavorito(widget.producto);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              widget.producto["imagen"],
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              widget.producto["nombre"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "\$${widget.producto["precio"]}",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 10),
            // Botón para seleccionar tallas
            ElevatedButton(
              onPressed: _mostrarSelectorTallas,
              child: Text("Tallas: $tallaSeleccionada"),
            ),
            const SizedBox(height: 10),
            // Selección de cantidad
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (cantidad > 1) {
                      setState(() => cantidad--);
                    }
                  },
                ),
                Text(
                  "$cantidad",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => cantidad++),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Botón para agregar al carrito
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final cart = Provider.of<CartProvider>(context, listen: false);
                  cart.addToCart(CartItem(
                    nombre: widget.producto["nombre"],
                    imagen: widget.producto["imagen"],
                    precio: (widget.producto["precio"] as num).toDouble(),
                    talla: tallaSeleccionada,
                    cantidad: cantidad,
                  ));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Producto agregado al carrito"),
                      action: SnackBarAction(
                        label: "Ver carrito",
                        onPressed: () {
                          Navigator.pushNamed(context, '/cart');
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Agregar al carrito"),
              ),
            ),
            const SizedBox(height: 20),
            // Sección de comentarios y reseñas
            _buildReseñasSection(),
          ],
        ),
      ),
    );
  }
}
