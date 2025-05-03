import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:zapato/modelos/productos_model.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final carouselHeight = MediaQuery.of(context).size.height * 0.25;

    return Column(
      children: [
        AppBar(
          title: const Text(
            'Compras',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        const SizedBox(height: 10),
        CarouselSlider(
          options: CarouselOptions(
            height: carouselHeight,
            autoPlay: true,
            enlargeCenterPage: true,
          ),
          items: productos.map((producto) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/product',
                  arguments: producto,
                );
              },
              child: Container(
                width: screenWidth * 0.9,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(producto.imagen),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth < 600 ? 2 : 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: screenWidth < 600 ? 0.8 : 0.7,
            ),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/product',
                    arguments: producto,
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          child: Image.network(
                            producto.imagen,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              producto.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "\$${producto.precio}",
                              style: const TextStyle(
                                color: Colors.green,
                              ),
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
