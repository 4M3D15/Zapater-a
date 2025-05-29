import 'package:flutter/material.dart';
import 'package:zapato/widgets/navigation_helper.dart'; // Importa tu helper
import 'package:zapato/pantallas/login_screen.dart';
import 'package:zapato/pantallas/registro_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<Offset> _titleSlide;

  late AnimationController _buttonsController;
  late Animation<double> _buttonsFade;

  @override
  void initState() {
    super.initState();

    // Animación del título
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutBack),
    );

    // Animación de los botones
    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonsFade = CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeIn,
    );

    // Ejecuta las animaciones en secuencia
    _titleController.forward().whenComplete(() {
      Future.delayed(const Duration(milliseconds: 200), () {
        _buttonsController.forward();
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDF8), // fondo crema
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _titleSlide,
                  child: const Text(
                    'Bienvenido a Zapato',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _titleController,
                  child: const Text(
                    'Explora tus zapatos favoritos y administra tu perfil con estilo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 48),
                FadeTransition(
                  opacity: _buttonsFade,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            navigateWithLoading(context, const LoginScreen()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => navigateWithLoading(
                            context, const RegistroScreen()),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Registrarse',
                          style:
                          TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                      ),
                    ],
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
