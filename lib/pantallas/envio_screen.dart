import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../modelos/cart_model.dart';
import '../widgets/animations.dart';

class EnvioScreen extends StatefulWidget {
  final List<CartItem> productos;
  final double total;

  const EnvioScreen({
    super.key,
    required this.productos,
    required this.total,
  });

  @override
  _EnvioScreenState createState() => _EnvioScreenState();
}

class _EnvioScreenState extends State<EnvioScreen> {
  final _codigoPostalController = TextEditingController();
  final _calleController = TextEditingController();
  final _numeroController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _estadoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codigoPostalController.dispose();
    _calleController.dispose();
    _numeroController.dispose();
    _coloniaController.dispose();
    _ciudadController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  Widget _campoTexto(TextEditingController c, String label, int index) {
    final esDireccion = label != 'Código Postal';
    return SlideFadeIn(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          textCapitalization:
          esDireccion ? TextCapitalization.characters : TextCapitalization.none,
          inputFormatters: label == 'Código Postal'
              ? [FilteringTextInputFormatter.digitsOnly]
              : [UpperCaseTextFormatter()],
          keyboardType: label == 'Código Postal'
              ? TextInputType.number
              : TextInputType.text,
          maxLength: label == 'Código Postal' ? 5 : null,
          buildCounter: (_, {int currentLength = 0, bool isFocused = false, int? maxLength}) => null,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Este campo es obligatorio';
            if (label == 'Código Postal' && v.trim().length != 5) {
              return 'El código postal debe tener 5 dígitos';
            }
            return null;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPageWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Dirección de Envío"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SlideFadeIn(
                    index: 0,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        "* Calle, número, colonia, ciudad y estado se convierten automáticamente en mayúsculas.",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),

                  _campoTexto(_codigoPostalController, 'Código Postal', 1),
                  _campoTexto(_calleController, 'Calle', 2),
                  _campoTexto(_numeroController, 'Número', 3),
                  _campoTexto(_coloniaController, 'Colonia', 4),
                  _campoTexto(_ciudadController, 'Ciudad', 5),
                  _campoTexto(_estadoController, 'Estado', 6),

                  const SizedBox(height: 20),

                  SlideFadeIn(
                    index: 7,
                    child: const Text(
                      "Productos en tu compra:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 8),

                  ...widget.productos.asMap().entries.map((entry) {
                    final i = 8 + entry.key;
                    final item = entry.value;
                    final cantidad = item.cantidad;
                    final precioTotal = item.precio * cantidad;

                    return SlideFadeIn(
                      index: i,
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.network(
                            item.imagen,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => const Icon(Icons.error, size: 50),
                          ),
                        ),
                        title: Text(item.nombre),
                        subtitle: Text(
                          "Cantidad: $cantidad — \$${precioTotal.toStringAsFixed(2)}",
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),

                  SlideFadeInFromBottom(
                    delay: Duration(milliseconds: 100 * (widget.productos.length + 10)),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final direccion =
                              "${_calleController.text} ${_numeroController.text}, "
                              "${_coloniaController.text}, "
                              "${_ciudadController.text}, "
                              "${_estadoController.text}, "
                              "CP ${_codigoPostalController.text}";

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Dirección válida. Redirigiendo a pago...'),
                              backgroundColor: Colors.green.shade600,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          );

                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pushNamed(
                              context,
                              '/pago',
                              arguments: {
                                'direccion': direccion,
                                'productos': widget.productos,
                                'total': widget.total,
                              },
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Continuar con el pago"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Formatter personalizado para convertir a mayúsculas mientras se escribe
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
