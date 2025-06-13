import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../modelos/cart_model.dart';
import '../utils/navigation.dart';
import '../pantallas/resumen_screen.dart';

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

  String _tipoTarjeta = 'debito';
  bool _isCreditoSelected = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _numeroTarjetaController.dispose();
    _fechaExpiracionController.dispose();
    _codigoSeguridadController.dispose();
    super.dispose();
  }

  Future<void> _guardarPedido(String direccion, List<CartItem> productos, double total, String tipoTarjeta) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final correo = user.email;

      final pedidoRef = FirebaseFirestore.instance.collection('pedidos').doc();
      await pedidoRef.set({
        'correo': correo,
        'direccion': direccion,
        'productos': productos.map((item) => {
          'idProducto': item.id,
          'nombre': item.nombre,
          'precio': item.precio,
          'cantidad': item.cantidad,
          'talla': item.talla,
        }).toList(),
        'total': total,
        'tipoTarjeta': tipoTarjeta,
        'fecha': FieldValue.serverTimestamp(),
      });

      final productosRef = FirebaseFirestore.instance.collection('productos');
      for (var item in productos) {
        final docRef = productosRef.doc(item.id);
        final docSnap = await docRef.get();

        if (docSnap.exists) {
          final data = docSnap.data()!;
          Map<String, dynamic> tallas = Map<String, dynamic>.from(data['Talla']);

          if (tallas.containsKey(item.talla)) {
            int stockActual = tallas[item.talla];
            int nuevoStock = stockActual - item.cantidad;
            if (nuevoStock < 0) nuevoStock = 0;

            await docRef.update({
              'Talla.${item.talla}': nuevoStock,
            });
          }
        }
      }
    }
  }

  void _confirmarPago(String direccion, List<CartItem> productos, double total) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar compra'),
        content: const Text('¿Estás seguro de realizar la compra?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // cerrar el diálogo
              await _guardarPedido(direccion, productos, total, _tipoTarjeta);

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago realizado con éxito')),
              );

              await navigateWithLoading(
                context,
                ResumenScreen(
                  direccion: direccion,
                  productos: productos,
                  total: total,
                ),
                replace: true,
              );
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String direccion = args['direccion'];
    final List<CartItem> productos = List<CartItem>.from(args['productos']);
    final double total = args['total'];

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Pago')
      ),
      body: SafeArea(

        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallWidth = constraints.maxWidth < 600;
            final listHeight = isSmallWidth ? 120.0 : 150.0;
            final buttonHeight = isSmallWidth ? 48.0 : 50.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dirección de Envío:', style: Theme.of(context).textTheme.titleMedium),
                  Text(direccion),
                  SizedBox(height: isSmallWidth ? 12 : 16),
                  Text('Resumen de productos:', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: isSmallWidth ? 6 : 8),
                  SizedBox(

                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productos.length,
                      itemBuilder: (_, index) {
                        final item = productos[index];
                        return ListTile(
                          title: Text(item.nombre),
                          subtitle: Text("Cantidad: ${item.cantidad} | Talla: ${item.talla}"),
                          trailing: Text("\$${(item.precio * item.cantidad).toStringAsFixed(2)}"),
                          contentPadding: EdgeInsets.symmetric(horizontal: isSmallWidth ? 8 : 16),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Text(
                    "Total: \$${total.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: isSmallWidth ? 10 : 12),
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
                            _isCreditoSelected = false;
                          }),
                          contentPadding: EdgeInsets.symmetric(horizontal: isSmallWidth ? 8 : 16),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Tarjeta de crédito'),
                          value: 'credito',
                          groupValue: _tipoTarjeta,
                          onChanged: (v) => setState(() {
                            _tipoTarjeta = v!;
                            _isCreditoSelected = true;
                          }),
                          contentPadding: EdgeInsets.symmetric(horizontal: isSmallWidth ? 8 : 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallWidth ? 12 : 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del Titular',
                            helperText: 'Se convierte automáticamente en mayúsculas',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                            UpperCaseTextFormatter(),
                          ],
                        ),
                        SizedBox(height: isSmallWidth ? 10 : 12),
                        TextFormField(
                          controller: _numeroTarjetaController,
                          decoration: const InputDecoration(
                            labelText: 'Número de tarjeta',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(16),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.length < 16) {
                              return 'Número de tarjeta inválido. Deben ser 16 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isSmallWidth ? 10 : 12),
                        TextFormField(
                          controller: _fechaExpiracionController,
                          decoration: const InputDecoration(
                            labelText: 'Fecha de expiración (MM/AA)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(5),
                            _FechaExpiracionFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.length != 5 || !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                              return 'Fecha de expiración inválida';
                            }
                            int mes = int.tryParse(value.substring(0, 2)) ?? 0;
                            if (mes < 1 || mes > 12) return 'Mes inválido';
                            return null;
                          },
                        ),
                        SizedBox(height: isSmallWidth ? 10 : 12),
                        TextFormField(
                          controller: _codigoSeguridadController,
                          decoration: const InputDecoration(
                            labelText: 'Código de seguridad (CVV)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(3),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.length < 3) {
                              return 'Código de seguridad inválido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: isSmallWidth ? 16 : 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _confirmarPago(direccion, productos, total);
                            }
                          },
                          child: const Text('Pagar ahora'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, buttonHeight),
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
            );
          },
        ),
      ),
    );
  }
}

class _FechaExpiracionFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digitsOnly[i]);
    }

    final String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
