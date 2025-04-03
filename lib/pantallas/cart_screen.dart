import 'package:flutter/material.dart';
import 'package:zapato/proveedores/cart_provider.dart';
import 'package:provider/provider.dart';
import 'pago_screen.dart'; // Asegúrate de importar el archivo de pago_screen.dart

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                  ? Center(child: Text("Tu carrito está vacío"))
                  : ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Image.asset(item.imagen, width: 80),
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
                                  Text("Cant. "),
                                  DropdownButton<int>(
                                    value: item.cantidad,
                                    items: [1, 2, 3, 4, 5]
                                        .map((e) => DropdownMenuItem<int>(
                                      value: e,
                                      child: Text("$e"),
                                    ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        cart.updateQuantity(item, value);
                                      }
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
              padding: EdgeInsets.all(16),
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
                      // Navegar a la pantalla de pago
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PagoScreen()),
                      );
                    },
                    child: Text("Finalizar compra"),
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
