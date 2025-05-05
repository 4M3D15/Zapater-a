import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'editar_perfil_screen.dart'; // Asegúrate de que esta ruta sea correcta

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with SingleTickerProviderStateMixin {
  String nombre = '';
  String apellido = '';
  String email = '';

  bool _isLoading = true;

  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    final data = doc.data();

    if (data != null) {
      setState(() {
        nombre = data['nombre'] ?? '';
        apellido = data['apellido'] ?? '';
        email = user.email ?? '';
        _isLoading = false;
      });
      _controller.forward();
    }
  }

  void _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: const AssetImage('assets/avatar.png'),
                      backgroundColor: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '$nombre $apellido',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      email,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildOptionTile(
                    icon: Icons.edit,
                    label: 'Editar perfil',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const EditarPerfilScreen(),
                      ));
                    },
                  ),
                  _buildOptionTile(
                    icon: Icons.history,
                    label: 'Ver pedidos',
                    onTap: () {
                      // Implementar navegación a pedidos
                    },
                  ),
                  _buildOptionTile(
                    icon: Icons.logout,
                    label: 'Cerrar sesión',
                    onTap: _cerrarSesion,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontSize: 16),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.white10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
    );
  }
}
