import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/cart_model.dart';
import '../proveedores/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  const ProductDetailScreen({Key? key, required this.producto}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int cantidad = 1;
  String tallaSeleccionada = "One";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.producto["nombre"]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart'); // ✅ Redirige al carrito
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(widget.producto["imagen"], height: 200, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text(widget.producto["nombre"], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("\$${widget.producto["precio"]}", style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 10),

            // Selección de talla
            const Text("Selecciona tu talla:", style: TextStyle(fontSize: 16)),
            Wrap(
              spacing: 8,
              children: ["One", "Two", "Three", "Four", "Five", "Six"]
                  .map((talla) => ChoiceChip(
                label: Text(talla),
                selected: tallaSeleccionada == talla,
                onSelected: (selected) {
                  setState(() {
                    tallaSeleccionada = talla;
                  });
                },
              ))
                  .toList(),
            ),
            const SizedBox(height: 10),

            // Cantidad
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
                Text("$cantidad", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => cantidad++),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Botón Agregar al carrito
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final cart = Provider.of<CartProvider>(context, listen: false); // ✅ listen: false evita redibujar la pantalla
                  cart.addToCart(CartItem(
                    nombre: widget.producto["nombre"],
                    imagen: widget.producto["imagen"],
                    precio: (widget.producto["precio"] as num).toDouble(), // ✅ Asegura que el precio sea un `double`
                    talla: tallaSeleccionada,
                    cantidad: cantidad,
                  ));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Producto agregado al carrito"),
                      action: SnackBarAction(
                        label: "Ver carrito",
                        onPressed: () {
                          Navigator.pushNamed(context, '/cart'); // ✅ Botón para ir al carrito
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Agregar al carrito"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
