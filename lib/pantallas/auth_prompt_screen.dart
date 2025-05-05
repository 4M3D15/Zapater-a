// lib/pantallas/auth_prompt_screen.dart
import 'package:flutter/material.dart';

class AuthPromptScreen extends StatelessWidget {
  const AuthPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1f1f1f),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.white54),
              const SizedBox(height: 20),
              const Text(
                'Inicia sesión o regístrate para ver tu perfil',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Iniciar sesión', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/registro'),
                child: const Text('¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: Colors.white60)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
