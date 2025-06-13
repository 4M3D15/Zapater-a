import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/modelos/productos_model.dart';
import 'package:zapato/proveedores/cart_provider.dart';

import '../Servicios/db_local.dart';
import '../widgets/animations.dart';
import '../utils/firestore_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  Future<bool?> _preguntarGuardarLocal() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Guardar inicio de sesión'),
        content: const Text('¿Quieres guardar tus datos para iniciar sesión localmente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('usuarios').doc(user.uid).set({
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'correo': _emailController.text.trim(),
          'avatar': "",
          'fechaRegistro': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          final guardarLocal = await _preguntarGuardarLocal();

          try {
            final user_id = _auth.currentUser?.uid;
            final doc = await _firestore.collection('usuarios').doc(user_id).get();
            final data = doc.data();

            if (guardarLocal == true && data != null) {
              await operaciones_db().setUsuarioLocal(data, _passwordController.text);
            }

            context.read<CartProvider>().obtenerCarrito();
            context.read<FavoritosModel>().obtenerFavoritos();
            context.read<ProductosModel>().obtenerProductos();
          } catch (e) {
            print('Error al guardar el usuario en local: $e');
          }

          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } on FirebaseAuthException catch (e) {
      final mensaje = traducirErrorFirebase(e.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedPageWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Registrarse', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalPadding = 20;
            double maxFormWidth = 500; // Para que no crezca mucho en pantallas grandes

            if (constraints.maxWidth > 600) {
              horizontalPadding = constraints.maxWidth * 0.15;
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxFormWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SlideFadeInFromBottom(
                          delay: const Duration(milliseconds: 100),
                          child: Text(
                            "Crea tu cuenta",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth < 350 ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SlideFadeInFromBottom(
                          delay: const Duration(milliseconds: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _nombreController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                                  TextInputFormatter.withFunction(
                                        (oldValue, newValue) => newValue.copyWith(
                                      text: newValue.text.toUpperCase(),
                                      selection: newValue.selection,
                                    ),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  labelText: "Nombre",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                validator: (v) => v == null || v.isEmpty ? "Por favor ingresa tu nombre" : null,
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "El nombre se convertirá automáticamente a mayúsculas.",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SlideFadeInFromBottom(
                          delay: const Duration(milliseconds: 300),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _apellidoController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                                  TextInputFormatter.withFunction(
                                        (oldValue, newValue) => newValue.copyWith(
                                      text: newValue.text.toUpperCase(),
                                      selection: newValue.selection,
                                    ),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  labelText: "Apellido",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                validator: (v) => v == null || v.isEmpty ? "Por favor ingresa tu apellido" : null,
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "El apellido se convertirá automáticamente a mayúsculas.",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SlideFadeInFromBottom(
                          delay: const Duration(milliseconds: 400),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Correo Electrónico",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.email),
                            ),
                            validator: (v) => v == null || v.isEmpty ? "Por favor ingresa tu correo" : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SlideFadeInFromBottom(
                          delay: const Duration(milliseconds: 500),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Contraseña",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.lock),
                            ),
                            validator: (v) => v == null || v.isEmpty ? "Por favor ingresa tu contraseña" : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SlideFadeInFromBottom(
                          delay: const Duration(milliseconds: 600),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Confirmar Contraseña",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.lock),
                            ),
                            validator: (v) => v != _passwordController.text ? "Las contraseñas no coinciden" : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SlideFadeInFromBottom(
                          delay: const Duration(milliseconds: 700),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _registerUser,
                            child: _isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Text("Registrarse", style: TextStyle(color: Colors.white, fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SlideFadeInFromBottom(
                          delay: const Duration(milliseconds: 800),
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                            child: const Text(
                              "¿Ya tienes cuenta? Inicia sesión",
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
