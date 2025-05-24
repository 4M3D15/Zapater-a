import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/animations.dart'; // AnimatedPageWrapper, SlideFadeInFromBottom

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  bool _isLoading = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    final data = doc.data();
    if (data != null) {
      _nombreCtrl.text = (data['nombre'] ?? '').toString().toUpperCase();
      _apellidoCtrl.text = (data['apellido'] ?? '').toString().toUpperCase();
      _emailCtrl.text = user.email ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _guardarCambios() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _guardando = true);
    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
      'nombre': _nombreCtrl.text.trim().toUpperCase(),
      'apellido': _apellidoCtrl.text.trim().toUpperCase(),
    });
    setState(() => _guardando = false);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Widget _buildField(String label, TextEditingController c,
      {bool enabled = true, int index = 0, bool toUpperCase = false}) {
    return SlideFadeInFromBottom(
      delay: Duration(milliseconds: 100 * index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: c,
            enabled: enabled,
            onChanged: toUpperCase
                ? (value) {
              final upper = value.toUpperCase();
              c.value = c.value.copyWith(
                text: upper,
                selection: TextSelection.collapsed(offset: upper.length),
              );
            }
                : null,
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (toUpperCase)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text(
                'Se convertirá automáticamente a MAYÚSCULAS.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPageWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDF8),
        appBar: AppBar(
          title: const Text('Editar Perfil', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar fijo
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 100),
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/avatar.png'),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildField('Nombre', _nombreCtrl, index: 2, toUpperCase: true),
              const SizedBox(height: 16),
              _buildField('Apellido', _apellidoCtrl, index: 3, toUpperCase: true),
              const SizedBox(height: 16),
              _buildField('Correo electrónico', _emailCtrl, enabled: false, index: 4),
              const SizedBox(height: 30),
              SlideFadeInFromBottom(
                delay: const Duration(milliseconds: 500),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: _guardando
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Guardar cambios'),
                  onPressed: _guardando ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
