import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _user;
  bool _isLoading = false;
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _nameController = TextEditingController(text: _user.displayName ?? '');
    _lastNameController =
        TextEditingController(text: _user.email?.split('@')[0] ?? '');
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('usuarios').doc(_user.uid).update({
        'nombre': _nameController.text,
        'apellido': _lastNameController.text,
      });
      await _user.updateDisplayName(_nameController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Error al actualizar el perfil'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Perfil de Usuario'),
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person, size: 100, color: Colors.black),
              const SizedBox(height: 20),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar cambios'),
              ),
            ],
          ),
        ),

        // >> Aquí el truco: el botón de cerrar sesión en persistentFooterButtons
        persistentFooterButtons: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ),
        ],
        persistentFooterAlignment: AlignmentDirectional.center,
      ),
    );
  }
}
