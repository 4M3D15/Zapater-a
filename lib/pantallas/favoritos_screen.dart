import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class FavoritosScreen extends StatefulWidget {
  static List<Map<String, dynamic>> favoritos = [];

  final List<Map<String, dynamic>> sugeridos = [
    {"nombre": "Tenis Nike", "precio": 1200, "imagen": "assets/cortez.png"},
    {"nombre": "Adidas Sport", "precio": 1500, "imagen": "assets/YZ1.png"},
    {"nombre": "New Balance Casual", "precio": 1100, "imagen": "assets/55810NB.png"},
    {"nombre": "Yeezy", "precio": 1300, "imagen": "assets/YZPINK.png"},
    {"nombre": "Nike Court Vision", "precio": 1300, "imagen": "assets/courtvision.png"},
    {"nombre": "New Balance", "precio": 1300, "imagen": "assets/55412NB.png"}
  ];

  @override
  _FavoritosScreenState createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  void _agregarAFavoritos(Map<String, dynamic> producto) {
    if (!FavoritosScreen.favoritos.contains(producto)) {
      setState(() {
        FavoritosScreen.favoritos.add(producto);
      });

      // Mostrar el Snackbar cuando se agrega el producto a favoritos
      _mostrarSnackbar("Producto agregado a favoritos");
    }
  }

  void _removerDeFavoritos(Map<String, dynamic> producto) {
    setState(() {
      FavoritosScreen.favoritos.remove(producto);
    });
  }

  void _mostrarSnackbar(String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration: Duration(seconds: 2), // Duración del Snackbar (2 segundos)
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar); // Muestra el Snackbar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favoritos")),
      body: Column(
        children: [
          // Lista de favoritos con Flexible para que no empuje el carrusel
          Expanded(
            child: FavoritosScreen.favoritos.isEmpty
                ? Center(child: Text("No tienes favoritos aún"))
                : ListView.builder(
              itemCount: FavoritosScreen.favoritos.length,
              itemBuilder: (context, index) {
                final producto = FavoritosScreen.favoritos[index];
                return ListTile(
                  leading: Image.asset(producto["imagen"], width: 50, height: 50),
                  title: Text(producto["nombre"]),
                  subtitle: Text("\$${producto["precio"]}"),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        FavoritosScreen.favoritos.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // 🔥 "Sugerencias para ti" debe quedar abajo
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "Sugerencias para ti",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 🔥 Carrusel con un tamaño adecuado
          Container(
            height: 180, // 🔥 Ajusté la altura del carrusel
            child: CarouselSlider(
              options: CarouselOptions(
                height: 180.0, // 🔥 Ajusté la altura interna para que coincida
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: widget.sugeridos.map((producto) {
                bool isFavorito = FavoritosScreen.favoritos.contains(producto);
                return GestureDetector(
                  onTap: () => isFavorito ? _removerDeFavoritos(producto) : _agregarAFavoritos(producto),
                  child: Container(
                    width: 350, // 🔥 Ancho ajustado a 350 píxeles
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(producto['imagen']),
                        fit: BoxFit.cover, // 🔥 Ajuste de imagen para cubrir todo el espacio
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                          isFavorito ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isFavorito) {
                              FavoritosScreen.favoritos.remove(producto);
                            } else {
                              FavoritosScreen.favoritos.add(producto);
                              _mostrarSnackbar("Producto agregado a favoritos"); // Mostrar Snackbar
                            }
                          });
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 80), // 🔥 Un poco de espacio al final
        ],
      ),
    );
  }
}
