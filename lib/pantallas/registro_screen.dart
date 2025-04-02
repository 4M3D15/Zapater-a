import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrarse")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: "Nombre"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingrese su nombre";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Apellido
              TextFormField(
                controller: _apellidoController,
                decoration: InputDecoration(labelText: "Apellido"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingrese su apellido";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Correo Electrónico
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Correo Electrónico"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingrese su correo";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Contraseña"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingrese su contraseña";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Confirmar Contraseña
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirmar Contraseña"),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return "Las contraseñas no coinciden";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Botón de Registro
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushNamed(context, '/');
                  }
                },
                child: Text("Registrarse"),
              ),

              // Link para ir al Login
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text("¿Ya tienes cuenta? Inicia sesión"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
