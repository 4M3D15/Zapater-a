import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final double precio;
  final String imagen;
  final String sexo;
  final String talla;
  final String color;

  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.sexo,
    required this.talla,
    required this.color,
  });

  // Convierte a Map para guardar en Firestore si fuera necesario
  Map<String, dynamic> toMap() {
    return {
      'Nombre': nombre,
      'Categoria': categoria,
      'Descripcion': descripcion,
      'Precio': precio,
      'Imagen': imagen,
      'Sexo': sexo,
      'Talla': talla,
      'Color': color,
    };
  }

  // Helpers de parseo
  static String _parseString(dynamic raw, {String placeholder = ''}) {
    if (raw is String) return raw;
    if (raw is List && raw.isNotEmpty) return raw.first.toString();
    return placeholder;
  }

  static String _parseImagen(dynamic raw) {
    if (raw is String) return raw;
    if (raw is List && raw.isNotEmpty) return raw.first.toString();
    return 'https://via.placeholder.com/150';
  }

  factory Producto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Producto(
      id: doc.id,
      nombre: _parseString(data['Nombre'], placeholder: 'Sin nombre'),
      categoria: _parseString(data['Categoria'], placeholder: 'Sin categoría'),
      descripcion: _parseString(data['Descripcion'], placeholder: ''),
      precio: (data['Precio'] as num?)?.toDouble() ?? 0.0,
      sexo: _parseString(data['Sexo'], placeholder: ''),
      imagen: _parseImagen(data['Imagen']),
      talla: _parseString(data['Talla'], placeholder: ''),
      color: _parseString(data['Color'], placeholder: ''),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Producto &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
