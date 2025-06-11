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
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05; // 5% padding

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Pedido'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
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
              SizedBox(height: size.height * 0.02),
              const Text(
                'Resumen de tu compra:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: size.height * 0.01),
              Text('Dirección de envío: $direccion'),
              Divider(height: size.height * 0.04),
              // Lista de productos sin Expanded
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(), // evita scroll interno
                shrinkWrap: true, // adapta tamaño a contenido
                itemCount: productos.length,
                itemBuilder: (_, index) {
                  final item = productos[index];
                  return ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(item.nombre),
                    subtitle: Text("Cantidad: ${item.cantidad} | Talla: ${item.talla}"),
                    trailing: Text("\$${(item.precio * item.cantidad).toStringAsFixed(2)}"),
                    contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
                  );
                },
              ),
              Divider(height: size.height * 0.04),
              Text(
                "Total pagado: \$${total.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => InicioScreen()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Volver al inicio'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
