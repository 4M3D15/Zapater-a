// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zapato/pantallas/inicio.dart' show InicioContent;
import 'package:zapato/pantallas/busquedascreen.dart' show BusquedaScreen;
import 'package:zapato/pantallas/inicio_content.dart';
import 'package:zapato/pantallas/product_detail_screen.dart';
import 'package:zapato/pantallas/cart_screen.dart';
import 'package:zapato/pantallas/envio_screen.dart' show EnvioScreen;
import 'package:zapato/pantallas/pago_screen.dart';
import 'package:zapato/pantallas/confirmacion_screen.dart';
import 'package:zapato/pantallas/perfil_screen.dart';
import 'package:zapato/pantallas/login_screen.dart';

import 'package:zapato/modelos/productos_model.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/proveedores/cart_provider.dart';
import 'package:zapato/modelos/cart_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductosModel()..obtenerProductos()),
        ChangeNotifierProvider(create: (_) => FavoritosModel()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
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
      title: 'Zapatería',
      debugShowCheckedModeBanner: false,
      initialRoute: '/inicio',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/inicio':
            return MaterialPageRoute(builder: (_) => const InicioContent());

          case '/busqueda':
            return MaterialPageRoute(builder: (_) => const BusquedaScreen());

          case '/product':
            final producto = settings.arguments as Producto;
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(producto: producto),
            );

          case '/cart':
            return MaterialPageRoute(builder: (_) => const CartScreen());

          case '/envio':
            final argsEnv = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => EnvioScreen(
                productos: argsEnv['productos'] as List<CartItem>,
                total: argsEnv['total'] as double,
              ),
            );

          case '/pago':
            final argsPago = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => PagoScreen(
                direccion: argsPago['direccion'] as String,
                productos: argsPago['productos'] as List<CartItem>,
                total: argsPago['total'] as double,
              ),
            );

          case '/confirmacion':
            final argsConf = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ConfirmacionScreen(
                direccion: argsConf['direccion'] as String,
                metodoPago: argsConf['metodoPago'] as String,
                tarjetaCompleta: argsConf['tarjetaCompleta'] as String,
                productos: argsConf['productos'] as List<CartItem>,
                total: argsConf['total'] as double,
              ),
            );

          case '/perfil':
            return MaterialPageRoute(builder: (_) => const PerfilScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Ruta desconocida: ${settings.name}')),
              ),
            );
        }
      },
    );
  }
}
