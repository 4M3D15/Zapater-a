import 'package:flutter/material.dart';
import 'confirmacion_screen.dart';
import 'package:zapato/modelos/cart_model.dart';

class PagoScreen extends StatefulWidget {
  final String direccion;
  final List<CartItem> productos;
  final double total;

  const PagoScreen({super.key,
    required this.direccion,
    required this.productos,
    required this.total,
  });

  @override
  _PagoScreenState createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numeroTarjetaController = TextEditingController();
  final TextEditingController _fechaExpiracionController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String _tipoTarjeta = 'debito';

  void _realizarPago() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmacionScreen(
            direccion: widget.direccion,
            metodoPago: "Método: ${_tipoTarjeta == 'debito' ? 'Débito' : 'Crédito'} - **** **** **** ${_numeroTarjetaController.text.substring(12)}",
            tarjetaCompleta: "${_numeroTarjetaController.text} | Exp: ${_fechaExpiracionController.text} | CVV: ${_cvvController.text}",
            productos: widget.productos,
            total: widget.total,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Formas de Pago"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Tarjeta de débito'),
                      value: 'debito',
                      groupValue: _tipoTarjeta,
                      onChanged: (value) => setState(() => _tipoTarjeta = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Tarjeta de crédito'),
                      value: 'credito',
                      groupValue: _tipoTarjeta,
                      onChanged: (value) => setState(() => _tipoTarjeta = value!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _campoTexto(_numeroTarjetaController, "Número de tarjeta", Icons.credit_card, 16),
              SizedBox(height: 20),
              _campoTexto(_fechaExpiracionController, "Fecha de expiración (MM/AA)", Icons.date_range, 5, r'^(0[1-9]|1[0-2])\/([0-9]{2})$'),
              SizedBox(height: 20),
              _campoTexto(_cvvController, "CVV", Icons.lock, 3, r'^\d{3}$', true),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _realizarPago,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Realizar pago"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController controller, String label, IconData icon, int length, [String? pattern, bool oculto = false]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      obscureText: oculto,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obligatorio';
        if (value.length != length) return 'Debe tener $length dígitos';
        if (pattern != null && !RegExp(pattern).hasMatch(value)) return 'Formato inválido';
        return null;
      },
    );
  }
}
