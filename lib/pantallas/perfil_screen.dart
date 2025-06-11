import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zapato/Servicios/db_local.dart';
import 'package:zapato/pantallas/welcome_screen.dart';
import 'package:zapato/pantallas/mis_compras_screen.dart';
import '../widgets/animations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
    _verificarConexion();
    _loadUserData();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _sinInternet = (result == ConnectivityResult.none);
      });
      if (!_sinInternet) _loadUserData();
    });
  }

  String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  Future<void> _loadUserData() async {
    try {
      _user = _auth.currentUser!;
      if (_sinInternet) {
        final usuario = await operaciones_db().getUsuario();
        _nameController.text = capitalize(usuario['nombre'] ?? '');
        _lastNameController.text = capitalize(usuario['apellido'] ?? '');
        _avatarFile = usuario['avatar'] != null && usuario['avatar'] != "" ? File(usuario['avatar']) : null;
      } else {
        final doc = await _firestore.collection('usuarios').doc(_user.uid).get();
        final data = doc.data();
        if (data != null) {
          _nameController.text = capitalize(data['nombre'] ?? '');
          _lastNameController.text = capitalize(data['apellido'] ?? '');
          _avatarFile = data['avatar'] != null && data['avatar'] != "" ? File(data['avatar']) : null;
        }
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
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
        'avatar': _avatarLocalPath ?? (_avatarFile?.path ?? ''),
      };

      await operaciones_db().actualizarUsuario(updateData);

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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final avatarRadius = constraints.maxWidth * 0.15;
                  final horizontalPadding = constraints.maxWidth * 0.06;
                  final verticalSpacing = constraints.maxHeight * 0.025;

                  final buttonHeight = constraints.maxHeight * 0.07;
                  final fontSizeInput = constraints.maxWidth * 0.045;
                  final fontSizeButtons = constraints.maxWidth * 0.045;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalSpacing,
                    ),
                    child: SlideFadeIn(
                      index: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickAvatar,
                              child: Hero(
                                tag: 'profile-avatar',
                                child: CircleAvatar(
                                  radius: avatarRadius.clamp(40, 70),
                                  backgroundImage: _avatarProvider(),
                                  backgroundColor: Colors.grey.shade200,
                                  child: _avatarFile == null
                                      ? Icon(Icons.camera_alt, size: avatarRadius * 0.6, color: Colors.white70)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: verticalSpacing * 1.5),
                          TextField(
                            controller: _nameController,
                            inputFormatters: [UpperCaseTextFormatter()],
                            style: TextStyle(fontSize: fontSizeInput.clamp(14, 18)),
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: EdgeInsets.symmetric(vertical: verticalSpacing * 0.7, horizontal: 16),
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          TextField(
                            controller: _lastNameController,
                            inputFormatters: [UpperCaseTextFormatter()],
                            style: TextStyle(fontSize: fontSizeInput.clamp(14, 18)),
                            decoration: InputDecoration(
                              labelText: 'Apellido',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: EdgeInsets.symmetric(vertical: verticalSpacing * 0.7, horizontal: 16),
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          TextField(
                            controller: TextEditingController(text: _user.email ?? ''),
                            readOnly: true,
                            style: TextStyle(fontSize: fontSizeInput.clamp(14, 18)),
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: EdgeInsets.symmetric(vertical: verticalSpacing * 0.7, horizontal: 16),
                            ),
                          ),
                          SizedBox(height: verticalSpacing * 2),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _updateProfile,
                            icon: const Icon(Icons.save),
                            label: Text('Guardar Cambios', style: TextStyle(fontSize: fontSizeButtons.clamp(14, 18))),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.35),
                              backgroundColor: const Color(0xF8F8F2FF),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_user.uid.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MisComprasScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('ID de usuario no disponible')),
                                );
                              }
                            },
                            icon: const Icon(Icons.shopping_bag),
                            label: Text('Mis Compras', style: TextStyle(fontSize: fontSizeButtons.clamp(14, 18))),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.35),
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          SizedBox(height: verticalSpacing * 2),
                          Center(
                            child: GestureDetector(
                              onTap: _signOut,
                              child: const Text(
                                'Cerrar sesión',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
