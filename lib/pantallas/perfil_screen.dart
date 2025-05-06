// lib/pantallas/perfil_screen.dart

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _user;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _lastNameController;

  File? _avatarImageFile;
  String? _avatarBase64;

  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _nameController = TextEditingController();
    _lastNameController = TextEditingController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await _firestore.collection('usuarios').doc(_user.uid).get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = data['nombre'] ?? '';
      _lastNameController.text = data['apellido'] ?? '';
      _avatarBase64 = data['avatarBase64'];
    }
    _animController.forward();
    setState(() {});
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    _avatarBase64 = base64Encode(bytes);
    setState(() => _avatarImageFile = File(picked.path));
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final updateData = {
        'nombre': _nameController.text,
        'apellido': _lastNameController.text,
        if (_avatarBase64 != null) 'avatarBase64': _avatarBase64,
      };
      await _firestore.collection('usuarios').doc(_user.uid).update(updateData);
      await _user.updateDisplayName(_nameController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  ImageProvider<Object> _avatarProvider() {
    if (_avatarImageFile != null) {
      return FileImage(_avatarImageFile!);
    } else if (_avatarBase64 != null) {
      return MemoryImage(base64Decode(_avatarBase64!));
    } else {
      return const AssetImage('assets/avatar_default.png');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF8), // blanco crema Nike
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Perfil', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar editable con Hero
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Hero(
                      tag: 'profile-avatar',
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _avatarProvider(),
                        backgroundColor: Colors.grey.shade200,
                        child: _avatarImageFile == null && _avatarBase64 == null
                            ? const Icon(Icons.camera_alt, size: 30, color: Colors.white70)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Nombre
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Apellido
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Apellido',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Correo (lectura)
                TextField(
                  controller: TextEditingController(text: _user.email ?? ''),
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),

                // Guardar
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Guardar cambios'),
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),

                // Cerrar sesión
                TextButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  onPressed: _signOut,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
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
