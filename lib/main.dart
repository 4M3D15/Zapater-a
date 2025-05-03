// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/modelos/producto_model.dart';   // Clase Producto
import 'package:zapato/modelos/productos_model.dart';  // ProductosModel
import 'package:zapato/proveedores/cart_provider.dart'; // CartProvider

import 'package:zapato/pantallas/inicio.dart';
import 'package:zapato/pantallas/cart_screen.dart';
import 'package:zapato/pantallas/login_screen.dart';
import 'package:zapato/pantallas/registro_screen.dart';
import 'package:zapato/pantallas/favoritos_screen.dart';
import 'package:zapato/pantallas/product_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritosModel()),
        ChangeNotifierProvider(create: (_) => ProductosModel()..obtenerProductos()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Inicia directamente en Inicio
      home: const Inicio(),
      routes: {
        '/cart':     (context) => const CartScreen(),
        '/login':    (context) => const LoginScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/favoritos':(context) => FavoritosScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product') {
          final Producto producto = settings.arguments as Producto;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(producto: producto),
          );
        }
        return null;
      },
    );
  }
}