import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/cart_model.dart'; // Asegúrate de tener este modelo importado

class PagoScreen extends StatefulWidget {
  const PagoScreen({Key? key}) : super(key: key);

  @override
  _PagoScreenState createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _numeroTarjetaController = TextEditingController();
  final TextEditingController _fechaExpiracionController = TextEditingController();
  final TextEditingController _codigoSeguridadController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  String _tipoTarjeta = 'debito'; // Tarjeta por defecto es débito

  bool _isCreditoSelected = false; // Flag para saber si se seleccionó crédito o débito

  @override
  void dispose() {
    _nombreController.dispose();
    _numeroTarjetaController.dispose();
    _fechaExpiracionController.dispose();
    _codigoSeguridadController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _guardarPedido(String direccion, List<CartItem> productos, double total, String tipoTarjeta) async {
    // Obtener el correo del usuario desde Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final correo = user.email;

      // Guardar el pedido en la base de datos de Firestore
      final pedidoRef = FirebaseFirestore.instance.collection('pedidos').doc();
      await pedidoRef.set({
        'correo': correo,
        'direccion': direccion,
        'productos': productos.map((item) => {
          'nombre': item.nombre,
          'cantidad': item.cantidad,
          'precio': item.precio,
        }).toList(),
        'total': total,
        'tipoTarjeta': tipoTarjeta,
        'fecha': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String direccion = args['direccion'];
    final List<CartItem> productos = List<CartItem>.from(args['productos']);
    final double total = args['total'];

    return Scaffold(
      appBar: AppBar(title: const Text('Pago')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dirección de Envío
            Text('Dirección de Envío:', style: Theme.of(context).textTheme.titleMedium),
            Text(direccion),
            const SizedBox(height: 16),

            // Resumen de Productos
            Text('Resumen de productos:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: productos.length,
                itemBuilder: (_, index) {
                  final item = productos[index];
                  return ListTile(
                    title: Text(item.nombre),
                    subtitle: Text("Cantidad: ${item.cantidad}"),
                    trailing: Text("\$${(item.precio * item.cantidad).toStringAsFixed(2)}"),
                  );
                },
              ),
            ),
            const Divider(),
            Text("Total: \$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Selección de tipo de tarjeta
            Text('Selecciona el tipo de tarjeta', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Tarjeta de débito'),
                    value: 'debito',
                    groupValue: _tipoTarjeta,
                    onChanged: (v) => setState(() {
                      _tipoTarjeta = v!;
                      _isCreditoSelected = false; // Si selecciona débito, desactiva los campos de crédito
                    }),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Tarjeta de crédito'),
                    value: 'credito',
                    groupValue: _tipoTarjeta,
                    onChanged: (v) => setState(() {
                      _tipoTarjeta = v!;
                      _isCreditoSelected = true; // Si selecciona crédito, activa los campos de crédito
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Formulario de Pago
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Campo de nombre del titular
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Titular',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Campo de número de tarjeta
                  TextFormField(
                    controller: _numeroTarjetaController,
                    decoration: const InputDecoration(
                      labelText: 'Número de tarjeta',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length != 16) {
                        return 'Número de tarjeta inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Campo de fecha de expiración
                  TextFormField(
                    controller: _fechaExpiracionController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de expiración (MM/AA)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length != 5) {
                        return 'Fecha de expiración inválida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Campo de código de seguridad
                  TextFormField(
                    controller: _codigoSeguridadController,
                    decoration: const InputDecoration(
                      labelText: 'Código de seguridad (CVV)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length != 3) {
                        return 'Código de seguridad inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Campo de dirección
                  TextFormField(
                    controller: _direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección de facturación',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Botón de pago
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Guardar el pedido
                        _guardarPedido(direccion, productos, total, _tipoTarjeta);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pago realizado con éxito')),
                        );

                        // Navegar a la pantalla de confirmación
                        Navigator.pushNamed(context, '/confirmacion');
                      }
                    },
                    child: const Text('Pagar ahora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
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
