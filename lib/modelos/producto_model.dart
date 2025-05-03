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

  // Método para convertir Producto a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'Nombre': nombre,
      'Categoria': categoria,
      'Descripcion': descripcion,
      'Precio': precio,
      'Imagen': imagen,
      'Talla': talla,
      'Color': color,
    };
  }

  // parse genérico para Strings o List<String>
  static String _parseString(dynamic raw, {String placeholder = ''}) {
    debugPrint('[_parseString] raw=$raw (${raw.runtimeType})');
    if (raw is String) return raw;
    if (raw is List && raw.isNotEmpty) return raw.first.toString();
    return placeholder;
  }

  static String _parseImagen(dynamic raw) {
    debugPrint('[_parseImagen] raw=$raw (${raw.runtimeType})');
    if (raw is String) return raw;
    if (raw is List && raw.isNotEmpty) return raw.first.toString();
    return 'https://via.placeholder.com/150';
  }

  factory Producto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!; // Accedemos al Map<String, dynamic>
    debugPrint('🍀 Producto raw data: $data');

    return Producto(
      nombre: _parseString(data['Nombre'], placeholder: 'Sin nombre'),
      categoria: _parseString(data['Categoria'], placeholder: 'Sin categoría'),
      descripcion: _parseString(data['Descripcion'], placeholder: ''),
      precio: (data['Precio'] as num?)?.toDouble() ?? 0.0,
      imagen: _parseImagen(data['Imagen']),
      talla: _parseString(data['Talla'], placeholder: ''),
      color: _parseString(data['Color'], placeholder: ''),
    );
  }
}
