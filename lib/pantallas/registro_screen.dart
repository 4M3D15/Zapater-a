import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class registroscreen extends StatefulWidget {
  const registroscreen({super.key});

  @override
  State<registroscreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<registroscreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    if (doc.exists) {
      setState(() {
        _userData = doc.data();
        _isLoading = false;
      });
    }
  }

  void _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMMd('es_ES');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Perfil"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Fondo tipo glassmorphism
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F1F1F), Color(0xFF121212)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Contenido
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 40, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${_userData!['nombre']} ${_userData!['apellido']}",
                    style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData!['email'],
                    style: const TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Miembro desde: ${dateFormat.format((_userData!['fechaRegistro'] as Timestamp).toDate())}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 30),

                  _buildOption(Icons.edit, "Editar perfil", () {
                    // Navegar a editar perfil
                  }),
                  _buildOption(Icons.lock, "Cambiar contraseña", () {
                    // Navegar a cambiar contraseña
                  }),
                  _buildOption(Icons.shopping_bag, "Mis pedidos", () {
                    // Navegar a pantalla de pedidos
                  }),
                  _buildOption(Icons.logout, "Cerrar sesión", _cerrarSesion),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
      onTap: onTap,
    );
  }
}
