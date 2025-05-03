import 'package:flutter/material.dart';
import 'package:zapato/modelos/cart_model.dart';

class ConfirmacionScreen extends StatelessWidget {
  final String direccion;
  final String metodoPago;
  final String tarjetaCompleta;
  final List<CartItem> productos;
  final double total;

  const ConfirmacionScreen({
    super.key,
    required this.direccion,
    required this.metodoPago,
    required this.tarjetaCompleta,
    required this.productos,
    required this.total,
  });

  void _confirmarCompra(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("✅ Compra confirmada"),
        content: const Text("Gracias por tu compra. Tu pedido está en camino."),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmación de compra"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text("🛍️ Productos:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...productos.map((item) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.asset(item.imagen, width: 50),
                      title: Text(item.nombre),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Talla: ${item.talla}"),
                          Text("Cantidad: ${item.cantidad}"),
                        ],
                      ),
                      trailing: Text("\$${(item.precio * item.cantidad).toStringAsFixed(2)}"),
                    ),
                  )),
                  const Divider(),
                  ListTile(title: const Text("📍 Dirección de envío"), subtitle: Text(direccion)),
                  ListTile(
                    title: const Text("💳 Método de pago"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(metodoPago),
                        Text(
                          "Tarjeta: **** ${tarjetaCompleta.length >= 4 ? tarjetaCompleta.substring(tarjetaCompleta.length - 4) : 'N/A'}",
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text("💰 Total"),
                    trailing: Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Confirmar compra"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => _confirmarCompra(context),
            ),
          ],
        ),
      ),
    );
  }
}
