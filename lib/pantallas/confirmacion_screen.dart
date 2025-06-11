import 'package:flutter/material.dart';
import 'package:zapato/modelos/cart_model.dart';
import '../widgets/animations.dart'; // AnimatedPageWrapper, SlideFadeIn, SlideFadeInFromBottom

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
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05; // 5% padding horizontal
    final verticalSpacingSmall = size.height * 0.01;
    final verticalSpacingMedium = size.height * 0.02;

    return AnimatedPageWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Confirmación de compra"),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            children: [
              Expanded(
                child: SlideFadeIn(
                  index: 0,
                  child: ListView(
                    children: [
                      SlideFadeInFromBottom(
                        delay: const Duration(milliseconds: 100),
                        child: const Text(
                          "🛍️ Productos:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: verticalSpacingSmall),
                      ...productos.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        return SlideFadeInFromBottom(
                          delay: Duration(milliseconds: 200 + i * 100),
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: verticalSpacingSmall),
                            child: ListTile(
                              leading: Image.asset(item.imagen,
                                  width: size.width * 0.12,
                                  height: size.width * 0.12,
                                  fit: BoxFit.cover),
                              title: Text(item.nombre),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Talla: ${item.talla}"),
                                  Text("Cantidad: ${item.cantidad}"),
                                ],
                              ),
                              trailing: Text(
                                "\$${(item.precio * item.cantidad).toStringAsFixed(2)}",
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const Divider(),
                      SlideFadeInFromBottom(
                        delay: Duration(milliseconds: 200 + productos.length * 100),
                        child: ListTile(
                          title: const Text("📍 Dirección de envío"),
                          subtitle: Text(direccion),
                        ),
                      ),
                      SlideFadeInFromBottom(
                        delay: Duration(milliseconds: 300 + productos.length * 100),
                        child: ListTile(
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
                      ),
                      SlideFadeInFromBottom(
                        delay: Duration(milliseconds: 400 + productos.length * 100),
                        child: ListTile(
                          title: const Text("💰 Total",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          trailing: Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: verticalSpacingMedium),

              SlideFadeInFromBottom(
                delay: Duration(milliseconds: 500 + productos.length * 100),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text("Confirmar compra"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, size.height * 0.07), // altura adaptativa
                  ),
                  onPressed: () => _confirmarCompra(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
