import 'package:flutter/material.dart';
import '../modelos/cart_model.dart';
import '../pantallas/inicio.dart';

class ResumenScreen extends StatelessWidget {
  final String direccion;
  final List<CartItem> productos;
  final double total;

  const ResumenScreen({
    Key? key,
    required this.direccion,
    required this.productos,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Pedido'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Pedido exitoso!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Resumen de tu compra:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Dirección de envío: $direccion'),
            const Divider(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: productos.length,
                itemBuilder: (_, index) {
                  final item = productos[index];
                  return ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(item.nombre),
                    subtitle: Text("Cantidad: ${item.cantidad} | Talla: ${item.talla}"),
                    trailing: Text("\$${(item.precio * item.cantidad).toStringAsFixed(2)}"),
                  );
                },
              ),
            ),
            const Divider(height: 30),
            Text(
              "Total pagado: \$${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => InicioScreen()), // Asegúrate que 'Inicio' es el widget de inicio
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Volver al inicio'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
