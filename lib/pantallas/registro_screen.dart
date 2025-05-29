import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/animations.dart'; // AnimatedPageWrapper, SlideFadeIn, SlideFadeInFromBottom
import 'welcome_screen.dart'; // Asegúrate de importar tu pantalla de inicio

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
          'fechaRegistro': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          await navigateWithLoading(context, const WelcomeScreen(), replace: true);
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al registrar el usuario'), backgroundColor: Colors.red),
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
    return AnimatedPageWrapper(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text('Registrarse', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SlideFadeInFromBottom(
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    "Crea tu cuenta",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                SlideFadeInFromBottom(
                  delay: const Duration(milliseconds: 200),
                  child: TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: "Nombre",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Por favor ingresa tu nombre" : null,
                  ),
                ),
                const SizedBox(height: 10),
                SlideFadeInFromBottom(
                  delay: const Duration(milliseconds: 300),
                  child: TextFormField(
                    controller: _apellidoController,
                    decoration: InputDecoration(
                      labelText: "Apellido",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Por favor ingresa tu apellido" : null,
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
                    validator: (v) =>
                    v != _passwordController.text ? "Las contraseñas no coinciden" : null,
                  ),
                ),
                const SizedBox(height: 20),
                SlideFadeInFromBottom(
                  delay: const Duration(milliseconds: 700),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
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
  }
}
