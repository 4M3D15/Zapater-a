import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/proveedores/cart_provider.dart';
import 'package:zapato/modelos/cart_model.dart';
import 'package:zapato/pantallas/envio_screen.dart';
import 'package:zapato/widgets/animated_page_wrapper.dart'; // Importa el wrapper de animación

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final itemCount = cart.items.length;

    return AnimatedPageWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Carrito de Compras"),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {},
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
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
                    ? const Center(child: Text("Tu carrito está vacío"))
                    : ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Image.network(item.imagen, width: 80),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.nombre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text("Talla: ${item.talla}"),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove,
                                          color: Colors.black),
                                      onPressed: () {
                                        if (item.cantidad > 1) {
                                          cart.updateQuantity(
                                              item, item.cantidad - 1);
                                        }
                                      },
                                    ),
                                    Text("${item.cantidad}",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add,
                                          color: Colors.black),
                                      onPressed: () {
                                        cart.updateQuantity(
                                            item, item.cantidad + 1);
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon:
                                const Icon(Icons.delete, color: Colors.red),
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
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Subtotal"),
                        Text("\$${cart.totalPrice.toStringAsFixed(2)}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          "\$${cart.totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        if (cart.items.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Por favor, agrega productos al carrito antes de finalizar la compra."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          final List<CartItem> productos =
                          List<CartItem>.from(cart.items);
                          final total = cart.totalPrice;
                          cart.clearCart();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EnvioScreen(
                                productos: productos,
                                total: total,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text("Continuar compra"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
