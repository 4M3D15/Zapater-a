import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  bool _isLoading = true;
  bool _guardando = false;

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    final data = doc.data();

    if (data != null) {
      _nombreCtrl.text = data['nombre'] ?? '';
      _apellidoCtrl.text = data['apellido'] ?? '';
      _emailCtrl.text = user.email ?? '';
    }

    setState(() => _isLoading = false);
    _animController.forward();
  }

  Future<void> _guardarCambios() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _guardando = true);
    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
      'nombre': _nombreCtrl.text.trim(),
      'apellido': _apellidoCtrl.text.trim(),
    });
    setState(() => _guardando = false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1f1f1f), Color(0xFF3c3c3c)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage('assets/avatar.png'),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade800,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              color: Colors.white,
                              onPressed: () {
                                // Aquí puedes implementar selector de imagen
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField('Nombre', _nombreCtrl),
                    const SizedBox(height: 15),
                    _buildTextField('Apellido', _apellidoCtrl),
                    const SizedBox(height: 15),
                    _buildTextField('Correo electrónico', _emailCtrl, enabled: false),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _guardando ? null : _guardarCambios,
                      icon: const Icon(Icons.save),
                      label: _guardando
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Guardar cambios',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
