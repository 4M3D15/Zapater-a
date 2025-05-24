import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zapato/Servicios/db_local.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/modelos/productos_model.dart';
import 'package:zapato/proveedores/cart_provider.dart';
import '../widgets/animations.dart'; // AnimatedPageWrapper, SlideFadeIn, SlideFadeInFromBottom
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
  bool _mostrarPassword = true;

  // Muestra diálogo para iniciar sesión rápido con usuario guardado localmente
  void _mostrarDialogo(Map<String, dynamic> usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar sesión'),
        content: Text('¿Desea iniciar sesión como ${usuario['nombre']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _emailCtrl.text = usuario['correo'];
              _passCtrl.text = usuario['password'];
              _signIn();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (mounted) {
        final user_id = _auth.currentUser?.uid;
        final _firestore = FirebaseFirestore.instance;
        final doc = await _firestore.collection('usuarios').doc(user_id).get();
        final data = doc.data();

        // Preguntar al usuario si desea guardar el inicio de sesión localmente
        bool guardarLocal = false;
        guardarLocal = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Guardar inicio de sesión'),
            content: const Text('¿Deseas guardar el inicio de sesión en la base local?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sí'),
              ),
            ],
          ),
        ) ??
            false;

        if (guardarLocal) {
          try {
            // Guarda usuario en base local con la contraseña ingresada
            await operaciones_db().setUsuarioLocal(data, _passCtrl.text);
          } catch (e) {
            print('Error al guardar el usuario en local: $e');
          }
        }

        // Actualiza providers de carrito, favoritos y productos
        context.read<CartProvider>().obtenerCarrito();
        context.read<FavoritosModel>().obtenerFavoritos();
        context.read<ProductosModel>().obtenerProductos();

        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') message = 'Usuario no encontrado';
      else if (e.code == 'wrong-password') message = 'Contraseña incorrecta';
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
        resizeToAvoidBottomInset: true,
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: operaciones_db().mostrarUsuarios(),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email input
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

                      // Password input
                      SlideFadeInFromBottom(
                        delay: const Duration(milliseconds: 200),
                        child: TextFormField(
                          controller: _passCtrl,
                          obscureText: _mostrarPassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: Icon(_mostrarPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () {
                                setState(() => _mostrarPassword = !_mostrarPassword);
                              },
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                            if (v.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Botón iniciar sesión
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

                      // Registro
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
                      const SizedBox(height: 30),

                      // Lista horizontal de usuarios guardados localmente
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) ...[
                        const Text('O inicia sesión como:', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final usuario = snapshot.data![index];
                              final nombre = usuario['nombre'];
                              final avatarPath = usuario['avatar'];

                              return GestureDetector(
                                onTap: () => _mostrarDialogo(usuario),
                                onLongPress: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('¿Desea eliminar el usuario?'),
                                      content: Text('Se eliminará  a "${usuario['nombre']}" del dispositivo.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Aceptar'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await operaciones_db().eliminarUsuario(usuario['user_uid']);
                                    setState(() {}); // Refresca la UI
                                  }
                                },
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: (avatarPath != null && avatarPath.isNotEmpty)
                                          ? FileImage(File(avatarPath))
                                          : const AssetImage('assets/avatar.png') as ImageProvider,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(nombre, style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
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
