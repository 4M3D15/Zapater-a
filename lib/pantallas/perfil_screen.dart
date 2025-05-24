import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zapato/Servicios/db_local.dart';
import 'package:zapato/pantallas/welcome_screen.dart';
import '../widgets/animations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';

// Formatter personalizado para convertir texto a mayúsculas mientras se escribe
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late User _user;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _lastNameController;

  File? _avatarFile;
  String? _avatarLocalPath;

  bool _sinInternet = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _lastNameController = TextEditingController();
    _loadUserData();
    _verificarConexion();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _sinInternet = (result == ConnectivityResult.none);
      });
    });
  }

  String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  Future<void> _loadUserData() async {
    try {
      if (_sinInternet) {
        final usuario = await operaciones_db().getUsuario();
        _nameController.text = capitalize(usuario['nombre'] ?? '');
        _lastNameController.text = capitalize(usuario['apellido'] ?? '');
        _avatarFile = File(usuario['avatar']);
      } else {
        _user = _auth.currentUser!;
        final doc = await _firestore.collection('usuarios').doc(_user.uid).get();
        final data = doc.data();
        if (data != null) {
          _nameController.text = capitalize(data['nombre'] ?? '');
          _lastNameController.text = capitalize(data['apellido'] ?? '');
          _avatarFile = data['avatar'] == "" ? null : File(data['avatar']);
        }
      }
    } catch (e) {
      print('Error de datos: $e');
    }
    setState(() {});
  }

  Future<void> _verificarConexion() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _sinInternet = (connectivityResult == ConnectivityResult.none);
    });
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      picked.path,
      quality: 60,
    );

    if (compressedBytes == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'avatar_${_user.uid}.jpg';
    final filePath = p.join(directory.path, fileName);

    final avatarFile = File(filePath);
    await avatarFile.writeAsBytes(compressedBytes);

    setState(() {
      _avatarFile = avatarFile;
      _avatarLocalPath = filePath;
    });
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final nombre = capitalize(_nameController.text.trim());
      final apellido = capitalize(_lastNameController.text.trim());

      final updateData = {
        'nombre': nombre,
        'apellido': apellido,
        'avatar': _avatarLocalPath ?? '',
      };

      operaciones_db().actualizarUsuario(updateData);

      await _firestore.collection('usuarios').doc(_user.uid).update(updateData);
      await _user.updateDisplayName(nombre);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado'), backgroundColor: Colors.green),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  ImageProvider<Object> _avatarProvider() {
    if (_avatarFile != null && _avatarFile!.existsSync()) {
      return FileImage(_avatarFile!);
    }
    return const AssetImage('assets/avatar.png');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPageWrapper(
          child: Scaffold(
            backgroundColor: const Color(0xFFFDFDF8),
            appBar: AppBar(
              automaticallyImplyLeading: false,
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
                child: SlideFadeIn(
                  index: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SlideFadeInFromBottom(
                        delay: const Duration(milliseconds: 100),
                        child: Center(
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: Hero(
                              tag: 'profile-avatar',
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _avatarProvider(),
                                backgroundColor: Colors.grey.shade200,
                                child: _avatarFile == null
                                    ? const Icon(Icons.camera_alt, size: 30, color: Colors.white70)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      SlideFadeInFromBottom(
                        delay: const Duration(milliseconds: 200),
                        child: TextField(
                          controller: _nameController,
                          inputFormatters: [UpperCaseTextFormatter()],
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SlideFadeInFromBottom(
                        delay: const Duration(milliseconds: 300),
                        child: TextField(
                          controller: _lastNameController,
                          inputFormatters: [UpperCaseTextFormatter()],
                          decoration: InputDecoration(
                            labelText: 'Apellido',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SlideFadeInFromBottom(
                        delay: const Duration(milliseconds: 400),
                        child: TextField(
                          controller: TextEditingController(text: _user.email ?? ''),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      SlideFadeInFromBottom(
                        delay: const Duration(milliseconds: 500),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text('Guardar cambios'),
                          onPressed: () {
                            if (_sinInternet) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Solo vista, sin acciones.")),
                              );
                              return;
                            }
                            if (!_isLoading) _updateProfile();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      SlideFadeInFromBottom(
                        delay: const Duration(milliseconds: 600),
                        child: TextButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Cerrar sesión'),
                          onPressed: _signOut,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_sinInternet)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: AnimatedSlide(
                    offset: const Offset(0, 0),
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      color: Colors.red.shade100,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.all(12),
                      child: const Text(
                        'Sin conexión a internet',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
