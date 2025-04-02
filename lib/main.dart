import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pantallas/inicio.dart';
import 'pantallas/cart_screen.dart';
import 'pantallas/product_detail_screen.dart';
import 'pantallas/login_screen.dart';  // ✅ Importación correcta
import 'pantallas/registro_screen.dart';  // ✅ Importación correcta
import 'proveedores/cart_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => InicioScreen(),
        '/cart': (context) => CartScreen(),
        '/login': (context) => LoginScreen(),  // ✅ Verifica que esté importado correctamente
        '/registro': (context) => RegistroScreen(),  // ✅ Verifica que esté importado correctamente
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
