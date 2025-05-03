import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zapato/modelos/cart_model.dart';

class EnvioScreen extends StatefulWidget {
  final List<CartItem> productos;
  final double total;

  const EnvioScreen({super.key, required this.productos, required this.total});

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

  final LatLng _ubicacionInicial = LatLng(19.4326, -99.1332);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dirección de Envío"), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      onMapCreated: (c) => _mapController = c,
                      initialCameraPosition: CameraPosition(target: _ubicacionInicial, zoom: 14),
                      markers: {
                        Marker(
                          markerId: const MarkerId("destino"),
                          position: _ubicacionInicial,
                        )
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _campoTexto(_codigoPostalController, 'Código Postal'),
                _campoTexto(_calleController, 'Calle'),
                _campoTexto(_numeroController, 'Número'),
                _campoTexto(_coloniaController, 'Colonia'),
                _campoTexto(_ciudadController, 'Ciudad'),
                _campoTexto(_estadoController, 'Estado'),
                const SizedBox(height: 20),
                const Text("Productos en tu compra:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.productos.length,
                  itemBuilder: (ctx, i) {
                    final item = widget.productos[i];
                    final cantidad = item.cantidad ?? 0; // Asegúrate de que cantidad no sea nula
                    final precioTotal = (item.precio ?? 0) * cantidad; // Asegúrate de que precio no sea nulo

                    return ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.network(
                          item.imagen,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 50),
                        ),
                      ),
                      title: Text(item.nombre),
                      subtitle: Text(
                        "Cantidad: $cantidad - \$${precioTotal.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 14, color: Colors.black), // Ajusta el estilo según sea necesario
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final direccion = "\${_calleController.text} \${_numeroController.text}, \${_coloniaController.text}, \${_ciudadController.text}, \${_estadoController.text}, CP \${_codigoPostalController.text}";
                      Navigator.pushNamed(
                        context,
                        '/pago',
                        arguments: {
                          'direccion': direccion,
                          'productos': widget.productos,
                          'total': widget.total,
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Continuar con el pago"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (v) => (v == null || v.isEmpty) ? 'Este campo es obligatorio' : null,
      ),
    );
  }
}
