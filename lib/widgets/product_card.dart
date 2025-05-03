import 'package:flutter/material.dart';
import 'package:zapato/modelos/producto_model.dart';

class ProductCard extends StatelessWidget {
  final Producto producto;

  const ProductCard({Key? key, required this.producto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  producto.imagen, // Usando imagen desde Firestore
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    producto.nombre, // Usando nombre desde Firestore
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "\$${producto.precio}", // Usando precio desde Firestore
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
