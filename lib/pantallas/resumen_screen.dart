import 'package:flutter/material.dart';
import '../modelos/cart_model.dart';

class ResumenScreen extends StatelessWidget {
  const ResumenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String direccion = args['direccion'];
    final List<CartItem> productos = List<CartItem>.from(args['productos']);
    final double total = args['total'];

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen del Pedido')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Pedido exitoso!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text('Dirección de Envío:', style: Theme.of(context).textTheme.titleMedium),
            Text(direccion),
            const SizedBox(height: 16),

            Text('Productos:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: productos.length,
                itemBuilder: (_, index) {
                  final item = productos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.network(
                        item.imagen,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                      ),
                      title: Text(item.nombre),
                      subtitle: Text("Cantidad: ${item.cantidad} | Talla: ${item.talla}"),
                      trailing: Text("\$${(item.precio * item.cantidad).toStringAsFixed(2)}"),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Text("Total: \$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/inicio', (route) => false);
                },
                child: const Text('Volver al inicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
