import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zapato/modelos/productos_model.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Importa carousel_slider
import 'package:zapato/widgets/product_card.dart'; // Asegúrate de tener este widget

class InicioContent extends StatelessWidget {
  const InicioContent({super.key});

  @override
  Widget build(BuildContext context) {
    final productosModel = Provider.of<ProductosModel>(context);

    if (productosModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productosModel.error != null) {
      return Center(child: Text(productosModel.error!));
    }

    final productos = productosModel.productos;

    return Column(
      children: [
        AppBar(
          title: const Text('Compras', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: CarouselSlider(
            options: CarouselOptions(height: 180.0, autoPlay: true, enlargeCenterPage: true),
            items: productos.map((producto) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(producto.imagen), // 🔁 Usando imagen de Firestore
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/product', arguments: producto);
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              child: Image.network(
                                producto.imagen, // 🔁 Usando imagen de Firestore
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              producto.nombre, // 🔁 Usando nombre de Firestore
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "\$${producto.precio}", // 🔁 Usando precio de Firestore
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
