import 'package:provider/provider.dart'; // 🔹 Falta esta línea
import 'package:flutter/material.dart';
import 'package:zapato/proveedores/cart_provider.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Carrito de Compras"),
      ),
      body: cart.items.isEmpty
          ? Center(child: Text("Tu carrito está vacío"))
          : ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];
          return ListTile(
            leading: Image.asset(item.imagen, width: 50),
            title: Text(item.nombre),
            subtitle: Text("Talla: ${item.talla} - Cantidad: ${item.cantidad}"),
            trailing: Text("\$${item.precio * item.cantidad}"),
            onLongPress: () => cart.removeFromCart(item),
          );
        },
      ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // Aquí podríamos agregar la lógica de checkout
            cart.clearCart();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Compra realizada")));
          },
          child: Text("Pagar (\$${cart.totalPrice})"),
        ),
      ),
    );
  }
}
