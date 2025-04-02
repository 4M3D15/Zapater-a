import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registro_screen.dart';

class PerfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Fondo uniforme como en las otras pantallas
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: Colors.black),
            SizedBox(height: 20),
            Text(
              "Bienvenido a tu perfil",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Fondo del botón negro
                foregroundColor: Colors.white, // Texto blanco
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Borde redondeado
                ),
              ),
              child: Text("Iniciar Sesión", style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Fondo del botón negro
                foregroundColor: Colors.white, // Texto blanco
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Borde redondeado
                ),
              ),
              child: Text("Registrarse", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
