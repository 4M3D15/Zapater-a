import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // generado por flutterfire
import 'modelos/producto_model.dart';
import 'pantallas/inicio.dart';
import 'pantallas/cart_screen.dart';
import 'pantallas/product_detail_screen.dart';
import 'pantallas/login_screen.dart';
import 'pantallas/registro_screen.dart';
import 'pantallas/favoritos_screen.dart';
import 'modelos/favoritos_model.dart';
import 'proveedores/cart_provider.dart';
import 'modelos/productos_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => FavoritosModel()),
        ChangeNotifierProvider(create: (context) => ProductosModel()..obtenerProductos()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zapato',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const InicioScreen(),
        '/cart': (context) => const CartScreen(),
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/favoritos': (context) => FavoritosScreen(), // 🔧 Añadido const
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product') {
          final producto = settings.arguments as Producto;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(producto: producto),
          );
        }
        return null;
      },
    );
  }
}
