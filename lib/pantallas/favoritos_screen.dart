import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/favoritos_model.dart';
import 'package:zapato/widgets/animated_favorite_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zapato/modelos/producto_model.dart';

class FavoritosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoritos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              // Vaciamos la lista de favoritos
              Provider.of<FavoritosModel>(context, listen: false).vaciarFavoritos();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de productos favoritos
          Expanded(
            child: Consumer<FavoritosModel>(
              builder: (context, favoritosModel, child) {
                final productosFavoritos = favoritosModel.favoritos;

                // Si no hay productos favoritos
                if (productosFavoritos.isEmpty) {
                  return const Center(child: Text("No tienes favoritos aún"));
                }

                // Si hay productos favoritos, mostramos la lista
                return ListView.builder(
                  itemCount: productosFavoritos.length,
                  itemBuilder: (context, index) {
                    final producto = productosFavoritos[index];
                    return Dismissible(
                      key: Key(producto.nombre),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        favoritosModel.removerFavorito(producto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${producto.nombre} eliminado de favoritos")),
                        );
                      },
                      child: ListTile(
                        leading: Image.network(producto.imagen, width: 50, height: 50),
                        title: Text(producto.nombre),
                        subtitle: Text("\$${producto.precio}"),
                        trailing: AnimatedFavoriteIcon(
                          esFavorito: true,
                          onTap: () => favoritosModel.removerFavorito(producto),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Título de sugerencias
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "Sugerencias para ti",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Carrusel de sugerencias
          SizedBox(
            height: 180,
            child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance.collection('productos').get(),
              builder: (context, snapshot) {
                // Si aún se está cargando
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Si ocurrió un error o no hay datos
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text("Error al cargar productos"));
                }

                // Mapeamos los productos de Firestore a objetos Producto
                final productos = snapshot.data!.docs
                    .map((doc) => Producto.fromFirestore(doc))
                    .toList();

                return CarouselSlider(
                  options: CarouselOptions(
                    height: 180.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: productos.map((producto) {
                    return Consumer<FavoritosModel>(
                      builder: (context, favoritosModel, child) {
                        return GestureDetector(
                          onTap: () {
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
                                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(producto.imagen),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: AnimatedFavoriteIcon(
                                  esFavorito: favoritosModel.esFavorito(producto),
                                  onTap: () {
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
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
