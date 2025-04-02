import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  ProductDetailScreen({required this.producto});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int cantidad = 1;
  String tallaSeleccionada = "One";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.producto["nombre"]),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(widget.producto["imagen"], height: 200), // Imagen principal
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(widget.producto["imagen"], height: 50),
                SizedBox(width: 10),
                Image.asset(widget.producto["imagen"], height: 50),
                SizedBox(width: 10),
                Image.asset(widget.producto["imagen"], height: 50),
              ],
            ),
            SizedBox(height: 10),
            Text(widget.producto["nombre"], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("\$${widget.producto["precio"]}", style: TextStyle(fontSize: 18, color: Colors.green)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ["One", "Two", "Three", "Four", "Five", "Six"]
                  .map((talla) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(talla),
                  selected: tallaSeleccionada == talla,
                  onSelected: (selected) {
                    setState(() {
                      tallaSeleccionada = talla;
                    });
                  },
                ),
              ))
                  .toList(),
            ),
            SizedBox(height: 10),
            Text("Existencia: Disponible", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (cantidad > 1) {
                      setState(() {
                        cantidad--;
                      });
                    }
                  },
                ),
                Text("$cantidad", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      cantidad++;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.shopping_cart),
              label: Text("Agregar al carrito"),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
