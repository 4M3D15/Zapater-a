import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zapato/modelos/cart_model.dart';

class PagoScreen extends StatefulWidget {
  final String direccion;
  final List<CartItem> productos;
  final double total;

  const PagoScreen({super.key, required this.direccion, required this.productos, required this.total});

  @override
  _PagoScreenState createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroTarjetaController = TextEditingController();
  final _fechaExpiracionController = TextEditingController();
  final _cvvController = TextEditingController();
  String _tipoTarjeta = 'debito';

  void _realizarPago() {
    if (_formKey.currentState?.validate() ?? false) {
      final metodoPago = "Método: ${_tipoTarjeta == 'debito' ? 'Débito' : 'Crédito'}";
      final tarjetaCompleta =
          "${_numeroTarjetaController.text}|Exp:${_fechaExpiracionController.text}|CVV:${_cvvController.text}";

      Navigator.pushNamed(
        context,
        '/confirmacion',
        arguments: {
          'direccion': widget.direccion,
          'metodoPago': metodoPago,
          'tarjetaCompleta': tarjetaCompleta,
          'productos': widget.productos,
          'total': widget.total,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formas de Pago"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Tarjeta de débito'),
                      value: 'debito',
                      groupValue: _tipoTarjeta,
                      onChanged: (v) => setState(() => _tipoTarjeta = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Tarjeta de crédito'),
                      value: 'credito',
                      groupValue: _tipoTarjeta,
                      onChanged: (v) => setState(() => _tipoTarjeta = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _campoTexto(_numeroTarjetaController, "Número de tarjeta", 16),
              const SizedBox(height: 20),
              _campoTexto(_fechaExpiracionController, "Fecha de expiración (MM/AA)", 5, pattern: r'^(0[1-9]|1[0-2])\/\d{2}$', inputFormatters: [
                _CardExpirationDateFormatter(),
              ]),
              const SizedBox(height: 20),
              _campoTexto(_cvvController, "CVV", 3, pattern: r'^\d{3}$', oculto: true),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _realizarPago,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Realizar pago"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(
      TextEditingController controller,
      String label,
      int length, {
        String? pattern,
        bool oculto = false,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      obscureText: oculto,
      keyboardType: TextInputType.number,
      inputFormatters: inputFormatters ?? [],
      validator: (v) {
        if (v == null || v.isEmpty) return 'Campo obligatorio';
        if (v.length != length) return 'Debe tener $length dígitos';
        if (pattern != null && !RegExp(pattern).hasMatch(v)) return 'Formato inválido';
        return null;
      },
    );
  }
}

class _CardExpirationDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = _formatCardExpirationDate(newValue.text);
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _formatCardExpirationDate(String text) {
    // Eliminar cualquier carácter que no sea un dígito
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    // Formatear como MM/AA
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i == 1)) {
        buffer.write('/');
      }
    }
    return buffer.toString();
  }
}
