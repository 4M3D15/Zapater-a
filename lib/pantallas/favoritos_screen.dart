import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/widgets/animated_favorite_icon.dart'; // Importa el widget AnimatedFavoriteIcon

class FavoritosScreen extends StatelessWidget {
  final List<Map<String, dynamic>> sugeridos = [
    {"nombre": "Tenis Nike", "precio": 1200, "imagen": "assets/cortez.png"},
    {"nombre": "Adidas Sport", "precio": 1500, "imagen": "assets/YZ1.png"},
    {"nombre": "New Balance Casual", "precio": 1100, "imagen": "assets/55810NB.png"},
    {"nombre": "Yeezy", "precio": 1300, "imagen": "assets/YZPINK.png"},
    {"nombre": "Nike Court Vision", "precio": 1300, "imagen": "assets/courtvision.png"},
    {"nombre": "New Balance", "precio": 1300, "imagen": "assets/55412NB.png"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favoritos"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              // Vaciar la lista de favoritos
              Provider.of<FavoritosModel>(context, listen: false).vaciarFavoritos();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<FavoritosModel>(
              builder: (context, favoritosModel, child) {
                final productosFavoritos = favoritosModel.favoritos;

                if (productosFavoritos.isEmpty) {
                  return Center(child: Text("No tienes favoritos aún"));
                }

                return ListView.builder(
                  itemCount: productosFavoritos.length,
                  itemBuilder: (context, index) {
                    final producto = productosFavoritos[index];
                    return Dismissible(
                      key: Key(producto["nombre"]),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        color: Colors.redAccent,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        favoritosModel.removerFavorito(producto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${producto['nombre']} eliminado de favoritos")),
                        );
                      },
                      child: ListTile(
                        leading: Image.asset(producto["imagen"], width: 50, height: 50),
                        title: Text(producto["nombre"]),
                        subtitle: Text("\$${producto["precio"]}"),
                        trailing: AnimatedFavoriteIcon(
                          esFavorito: true, // Siempre será true en la lista de favoritos
                          onTap: () => favoritosModel.removerFavorito(producto), // Eliminar favorito al tocar el corazón
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "Sugerencias para ti",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 180,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 180.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: sugeridos.map((producto) {
                return GestureDetector(
                  onTap: () {
                    final favoritosModel = Provider.of<FavoritosModel>(context, listen: false);
                    if (favoritosModel.esFavorito(producto)) {
                      favoritosModel.removerFavorito(producto);
                    } else {
                      favoritosModel.agregarFavorito(producto);
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 350,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(producto['imagen']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AnimatedFavoriteIcon(
                          esFavorito: Provider.of<FavoritosModel>(context).esFavorito(producto),
                          onTap: () {
                            final favoritosModel = Provider.of<FavoritosModel>(context, listen: false);
                            if (favoritosModel.esFavorito(producto)) {
                              favoritosModel.removerFavorito(producto);
                            } else {
                              favoritosModel.agregarFavorito(producto);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
