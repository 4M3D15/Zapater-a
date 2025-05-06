// lib/pantallas/envio_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../modelos/cart_model.dart';
import '../widgets/animations.dart'; // AnimatedPageWrapper, SlideFadeIn, SlideFadeInFromBottom

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
  late GoogleMapController _mapController;
  final _codigoPostalController = TextEditingController();
  final _calleController = TextEditingController();
  final _numeroController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _estadoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final LatLng _ubicacionInicial = const LatLng(19.4326, -99.1332);

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
    return SlideFadeIn(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          validator: (v) =>
          (v == null || v.isEmpty) ? 'Este campo es obligatorio' : null,
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mapa
                  SlideFadeInFromBottom(
                    delay: const Duration(milliseconds: 100),
                    child: SizedBox(
                      height: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GoogleMap(
                          onMapCreated: (c) => _mapController = c,
                          initialCameraPosition: CameraPosition(
                            target: _ubicacionInicial,
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId("destino"),
                              position: _ubicacionInicial,
                            ),
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campos de texto
                  _campoTexto(_codigoPostalController, 'Código Postal', 2),
                  _campoTexto(_calleController, 'Calle', 3),
                  _campoTexto(_numeroController, 'Número', 4),
                  _campoTexto(_coloniaController, 'Colonia', 5),
                  _campoTexto(_ciudadController, 'Ciudad', 6),
                  _campoTexto(_estadoController, 'Estado', 7),

                  const SizedBox(height: 20),

                  // Título productos
                  SlideFadeIn(
                    index: 8,
                    child: const Text(
                      "Productos en tu compra:",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Lista de productos
                  ...widget.productos.asMap().entries.map((entry) {
                    final i = 9 + entry.key;
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
                            errorBuilder: (ctx, err, st) =>
                            const Icon(Icons.error, size: 50),
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

                  // Botón continuar pago
                  SlideFadeInFromBottom(
                    delay: Duration(
                        milliseconds:
                        100 * (widget.productos.length + 10)),
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
                              content: const Text(
                                  'Dirección válida. Redirigiendo a pago...'),
                              backgroundColor: Colors.green.shade600,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
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
                            borderRadius: BorderRadius.circular(30)),
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
