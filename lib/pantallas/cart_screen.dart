import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/proveedores/cart_provider.dart';
import 'package:zapato/modelos/cart_model.dart';
import 'package:zapato/pantallas/envio_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Carrito de Compras"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bolsa",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: cart.items.isEmpty
                  ? Center(child: Text("Tu carrito está vacío"))
                  : ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Image.network(item.imagen, width: 80),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nombre,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("Talla: ${item.talla}"),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, color: Colors.black),
                                    onPressed: () {
                                      if (item.cantidad > 1) {
                                        cart.updateQuantity(item, item.cantidad - 1);
                                      }
                                    },
                                  ),
                                  Text(
                                    "${item.cantidad}",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add, color: Colors.black),
                                    onPressed: () {
                                      cart.updateQuantity(item, item.cantidad + 1);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "\$${(item.precio * item.cantidad).toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => cart.removeFromCart(item),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal"),
                      Text("\$${cart.totalPrice.toStringAsFixed(2)}"),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "\$${cart.totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      if (cart.items.isEmpty) {
                        // Si el carrito está vacío, mostramos un mensaje
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Por favor, agrega productos al carrito antes de finalizar la compra."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        // Guardar los productos como una lista de tipo List<CartItem>
                        final List<CartItem> productos = List<CartItem>.from(cart.items);
                        final total = cart.totalPrice;

                        // Vaciar el carrito antes de navegar a EnvioScreen
                        cart.clearCart();

                        // Navegar a la pantalla de envío pasando los productos y el total
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EnvioScreen(
                              productos: productos, // Pasa la lista de productos
                              total: total,           // Pasa el total calculado
                            ),
                          ),
                        );
                      }
                    },
                    child: Text("Continuar compra"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
