import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/animations.dart'; // Contiene navigateWithLoading
import 'inicio.dart'; // Asegúrate de que el path sea correcto
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (mounted) {
        await navigateWithLoading(context, const InicioScreen(), replace: true);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        message = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPageWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDF8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text('Iniciar Sesión', style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Email Field
                SlideFadeInFromBottom(
                  delay: const Duration(milliseconds: 100),
                  child: TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu correo';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Correo inválido';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Password Field
                SlideFadeInFromBottom(
                  delay: const Duration(milliseconds: 200),
                  child: TextFormField(
                    controller: _passCtrl,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Login Button
                SlideFadeInFromBottom(
                  delay: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text('Iniciar Sesión', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Register Link
                SlideFadeInFromBottom(
                  delay: const Duration(milliseconds: 400),
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/registro'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('¿No tienes cuenta? Regístrate'),
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
