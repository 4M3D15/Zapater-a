import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id; // Agrega el campo id
  final String nombre;
  final String categoria;
  final String descripcion;
  final double precio;
  final String imagen;
  final String talla;
  final String color;

  // Constructor
  Producto({
    required this.id, // Incluye el id en el constructor
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
      'id': id, // Incluye el id en el mapa
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
    print('[_parseString] raw=$raw (${raw.runtimeType})'); // Usa print en lugar de debugPrint
    if (raw is String) return raw;
    if (raw is List && raw.isNotEmpty) return raw.first.toString();
    return placeholder;
  }

  // Método específico para parsear la imagen
  static String _parseImagen(dynamic raw) {
    print('[_parseImagen] raw=$raw (${raw.runtimeType})'); // Usa print en lugar de debugPrint
    if (raw is String) return raw;
    if (raw is List && raw.isNotEmpty) return raw.first.toString();
    return 'https://via.placeholder.com/150'; // Imagen por defecto
  }

  // Constructor para crear un Producto a partir de un documento de Firestore
  factory Producto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!; // Accedemos al Map<String, dynamic> de Firestore
    print('🍀 Producto raw data: $data'); // Usa print en lugar de debugPrint

    return Producto(
      id: doc.id, // Asigna el id del documento
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
