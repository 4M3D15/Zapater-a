import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Firebase Options generado automáticamente
import 'firebase_options.dart';

// Pantallas
import 'pantallas/welcome_screen.dart';
import 'pantallas/inicio.dart';
import 'pantallas/cart_screen.dart';
import 'pantallas/login_screen.dart';
import 'pantallas/registro_screen.dart';
import 'pantallas/perfil_screen.dart';
import 'pantallas/product_detail_screen.dart';
import 'pantallas/pago_screen.dart';


// Proveedores
import 'proveedores/cart_provider.dart';
import 'modelos/favoritos_model.dart';
import 'modelos/productos_model.dart';

// Observador de rutas para animaciones o tracking
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa formato de fechas en español
  await initializeDateFormatting('es');

  // Ejecuta la aplicación
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
      title: 'Zapato',
      navigatorObservers: [routeObserver],
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/': (context) => const InicioScreen(),
        '/cart': (context) => const CartScreen(),
        '/perfil': (context) => const ProfileScreen(),
        '/pago': (context) => const PagoScreen(),
      },
      // Ruta dinámica para detalle de producto
      onGenerateRoute: (settings) {
        if (settings.name == '/product') {
          final productId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: productId),
          );
        }
        return null;
      },
    );
  }
}
