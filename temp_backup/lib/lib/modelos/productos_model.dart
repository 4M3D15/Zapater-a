import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Producto {
  final String nombre;
  final String categoria;
  final String descripcion;
  final double precio;
  final String imagen;
  final String talla;
  final String color;

  Producto({
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.talla,
    required this.color,
  });

  factory Producto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Producto(
      nombre: data['Nombre'],
      categoria: data['Categoria'],
      descripcion: data['Descripcion'],
      precio: data['Precio'].toDouble(),
      imagen: data['Imagen'],
      talla: data['Talla'],
      color: data['Color'],
    );
  }
}

class ProductosModel with ChangeNotifier {
  List<Producto> _productos = [];
  bool isLoading = false;
  String? error;

  List<Producto> get productos => _productos;

  Future<void> obtenerProductos() async {
    isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('productos').get();
      _productos = querySnapshot.docs.map((doc) => Producto.fromFirestore(doc)).toList();
    } catch (e) {
      error = 'Error al obtener productos: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
