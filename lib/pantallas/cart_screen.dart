import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/proveedores/cart_provider.dart';
import 'package:zapato/modelos/cart_model.dart';
import 'package:zapato/pantallas/envio_screen.dart';
import '../widgets/animations.dart'; // AnimatedPageWrapper, SlideFadeIn, SlideFadeInFromBottom

const kBackgroundColor = Color(0xFFFDFDF8);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreen createState() => _CartScreen();
}

class _CartScreen extends State<CartScreen> {
  bool _sinInternet = false;

  @override
  void initState() {
    super.initState();
    _verificarConexion();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _sinInternet = (result == ConnectivityResult.none);
      });
    });
  }

  Future<void> _verificarConexion() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _sinInternet = (connectivityResult == ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final itemCount = cart.items.length;

    return Stack(
      children: [
          AnimatedPageWrapper(
          child: Scaffold(
          backgroundColor: kBackgroundColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: kBackgroundColor,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              actions: [
                SizedBox(
                  height: 40, // Ajusta según necesidad
                  width: 40,  // o usa double.infinity
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (itemCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$itemCount',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: cart.items.isEmpty
                        ? const Center(
                      child: SlideFadeInFromBottom(
                        delay: Duration(milliseconds: 100),
                        duration: Duration(milliseconds: 700),
                        curve: Curves.easeOutBack,
                        child: Text(
                          "Tu carrito está vacío",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return SlideFadeIn(
                          index: index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutBack,
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      item.imagen,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.fitWidth,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.image_not_supported);
                                      }
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(item.nombre,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text("Talla: ${item.talla}"),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                if(_sinInternet){
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Solo vista, sin acciones.")),
                                                  );
                                                  return;
                                                }
                                                if (item.cantidad > 1) {
                                                  cart.updateQuantity(item,
                                                      item.cantidad - 1);
                                                }
                                              },
                                            ),
                                            Text('${item.cantidad}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold)),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () async {
                                                if(_sinInternet){
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Solo vista, sin acciones.")),
                                                  );
                                                  return;
                                                }
                                                final nuevoValor =
                                                    item.cantidad + 1;
                                                final stockDisponible =
                                                await cart
                                                    .getStockDisponible(
                                                    item.id,
                                                    item.talla);

                                                if (nuevoValor <=
                                                    stockDisponible) {
                                                  cart.updateQuantity(item,
                                                      nuevoValor);
                                                } else {
                                                  ScaffoldMessenger.of(
                                                      context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Solo hay $stockDisponible unidades disponibles para la talla ${item.talla}.",
                                                      ),
                                                      backgroundColor:
                                                      Colors.orange,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "\$${(item.precio * item.cantidad).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          if(_sinInternet){
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Solo vista, sin acciones.")),
                                            );
                                            return;
                                          }
                                          cart.removeFromCart(item);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Total y botón
                  SlideFadeInFromBottom(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutBack,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Subtotal"),
                              Text("\$${cart.totalPrice.toStringAsFixed(2)}"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                "\$${cart.totalPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: () {
                              if(_sinInternet){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Solo vista, sin acciones.")),
                                );
                                return;
                              }
                              if (cart.items.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Agrega productos antes de continuar."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                final productos =
                                List<CartItem>.from(cart.items);
                                final total = cart.totalPrice;
                                cart.clearCart();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EnvioScreen(
                                      productos: productos,
                                      total: total,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text("Continuar compra"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_sinInternet)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true, // para permitir que los toques pasen a widgets debajo
              child: Container(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: AnimatedSlide(
                    offset: Offset(0, _sinInternet ? 0 : -1),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Sin conexión a Internet: Modo vista',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
