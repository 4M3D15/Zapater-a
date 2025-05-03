import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zapato/modelos/cart_model.dart'; // Asegúrate de que CartItem está importado correctamente
import 'pago_screen.dart';

class EnvioScreen extends StatefulWidget {
  final List<CartItem> productos;
  final double total;

  const EnvioScreen({super.key, required this.productos, required this.total});

  @override
  _EnvioScreenState createState() => _EnvioScreenState();
}

class _EnvioScreenState extends State<EnvioScreen> {
  late GoogleMapController _mapController;

  final TextEditingController _codigoPostalController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _coloniaController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final LatLng _ubicacionInicial = LatLng(19.4326, -99.1332); // Ciudad de México

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dirección de Envío"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Mapa de ubicación
                SizedBox(
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      onMapCreated: (controller) => _mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: _ubicacionInicial,
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId("destino"),
                          position: _ubicacionInicial,
                        ),
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Formulario de dirección
                _campoTexto(_codigoPostalController, 'Código Postal'),
                _campoTexto(_calleController, 'Calle'),
                _campoTexto(_numeroController, 'Número'),
                _campoTexto(_coloniaController, 'Colonia'),
                _campoTexto(_ciudadController, 'Ciudad'),
                _campoTexto(_estadoController, 'Estado'),

                SizedBox(height: 20),

                // Mostrar los productos
                Text("Productos en tu compra:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true, // Para que la lista no ocupe espacio infinito
                  itemCount: widget.productos.length,
                  itemBuilder: (context, index) {
                    final item = widget.productos[index];
                    return ListTile(
                      leading: Image.asset(item.imagen, width: 50),
                      title: Text(item.nombre),
                      subtitle: Text("Cantidad: ${item.cantidad} - \$${(item.precio * item.cantidad).toStringAsFixed(2)}"),
                    );
                  },
                ),

                SizedBox(height: 20),

                // Botón para continuar con el pago
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      String direccion = "${_calleController.text} ${_numeroController.text}, "
                          "${_coloniaController.text}, ${_ciudadController.text}, "
                          "${_estadoController.text}, ${_codigoPostalController.text}";

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PagoScreen(
                            direccion: direccion,
                            productos: widget.productos,
                            total: widget.total,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Continuar con el pago"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función para crear los campos de texto
  Widget _campoTexto(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }
}
