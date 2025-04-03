import 'package:flutter/material.dart';

class PagoScreen extends StatefulWidget {
  @override
  _PagoScreenState createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos del formulario
  final TextEditingController _numeroTarjetaController = TextEditingController();
  final TextEditingController _fechaExpiracionController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Variable para seleccionar el tipo de tarjeta
  String _tipoTarjeta = 'debito'; // 'debito' o 'credito'

  // Método para validar y realizar el pago
  void _realizarPago() {
    if (_formKey.currentState?.validate() ?? false) {
      // Si los datos son válidos, puedes realizar la acción de pago
      // Aquí puedes agregar la lógica de procesamiento de pagos

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pago realizado exitosamente")),
      );

      // Puedes redirigir a otra pantalla después del pago, por ejemplo:
      // Navigator.pushReplacementNamed(context, '/home');
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selección del tipo de tarjeta (debito o credito)
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Tarjeta de débito'),
                      value: 'debito',
                      groupValue: _tipoTarjeta,
                      onChanged: (value) {
                        setState(() {
                          _tipoTarjeta = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Tarjeta de crédito'),
                      value: 'credito',
                      groupValue: _tipoTarjeta,
                      onChanged: (value) {
                        setState(() {
                          _tipoTarjeta = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Número de tarjeta
              TextFormField(
                controller: _numeroTarjetaController,
                decoration: InputDecoration(
                  labelText: 'Número de tarjeta',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el número de tarjeta';
                  }
                  if (value.length != 16) {
                    return 'El número de tarjeta debe tener 16 dígitos';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Fecha de expiración
              TextFormField(
                controller: _fechaExpiracionController,
                decoration: InputDecoration(
                  labelText: 'Fecha de expiración (MM/AA)',
                  prefixIcon: Icon(Icons.date_range),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la fecha de expiración';
                  }
                  if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(value)) {
                    return 'La fecha de expiración no es válida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // CVV
              TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el CVV';
                  }
                  if (value.length != 3) {
                    return 'El CVV debe tener 3 dígitos';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Botón para realizar el pago
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _realizarPago,
                child: Text("Realizar pago"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
