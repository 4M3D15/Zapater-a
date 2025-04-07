import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/favoritos_model.dart'; // Importamos FavoritosModel
import 'pantallas/inicio.dart';
import 'pantallas/cart_screen.dart';
import 'pantallas/product_detail_screen.dart';
import 'pantallas/login_screen.dart';
import 'pantallas/registro_screen.dart';
import 'proveedores/cart_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()), // Proveedor del carrito
        ChangeNotifierProvider(create: (context) => FavoritosModel()), // Proveedor de favoritos
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => InicioScreen(),
        '/cart': (context) => CartScreen(),
        '/login': (context) => LoginScreen(),
        '/registro': (context) => RegistroScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product') {
          final producto = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(producto: producto),
          );
        }
        return null;
      },
    );
  }
}
