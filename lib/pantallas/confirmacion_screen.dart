import 'package:flutter/material.dart';
import 'package:zapato/modelos/cart_model.dart';

class ConfirmacionScreen extends StatelessWidget {
  final String direccion;
  final String metodoPago;
  final String tarjetaCompleta;
  final List<CartItem> productos;
  final double total;

  const ConfirmacionScreen({super.key,
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
        title: Text("✅ Compra confirmada"),
        content: Text("Gracias por tu compra. Tu pedido está en camino."),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmación de compra"),
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
                  Text("🛍️ Productos:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...productos.map((item) => Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
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
                  Divider(),
                  ListTile(title: Text("📍 Dirección de envío"), subtitle: Text(direccion)),
                  ListTile(
                    title: Text("💳 Método de pago"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(metodoPago),
                        Text("Tarjeta: **** ${tarjetaCompleta.substring(tarjetaCompleta.length - 4)}"),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text("💰 Total"),
                    trailing: Text("\$${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.check),
              label: Text("Confirmar compra"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () => _confirmarCompra(context),
            ),
          ],
        ),
      ),
    );
  }
}
