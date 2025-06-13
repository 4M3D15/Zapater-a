import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'pantallas/resumen_screen.dart';

// Proveedores
import 'proveedores/cart_provider.dart';
import 'modelos/favoritos_model.dart';
import 'modelos/productos_model.dart';

// Observador de rutas
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa formato de fechas en español
  await initializeDateFormatting('es');

  // Estilo del sistema para eliminar sombras y bordes por defecto
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Ejecuta la aplicación
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()..obtenerCarrito()),
        ChangeNotifierProvider(create: (_) => FavoritosModel()..obtenerFavoritos()),
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
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: FirebaseAuth.instance.currentUser != null ? '/' : '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/': (context) => const InicioScreen(),
        '/cart': (context) => const CartScreen(),
        '/perfil': (context) => const ProfileScreen(),
        '/pago': (context) => const PagoScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product') {
          final productId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: productId),
          );
        }

        if (settings.name == '/resumen') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ResumenScreen(
              direccion: args['direccion'],
              productos: args['productos'],
              total: args['total'],
            ),
          );
        }

        return null;
      },
    );
  }
}
