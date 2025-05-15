// lib/modelos/resena_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Resena {
  final String usuario;
  final String comentario;
  final int rating;
  final DateTime fecha;

  Resena({
    required this.usuario,
    required this.comentario,
    required this.rating,
    required this.fecha,
  });

  factory Resena.fromMap(Map<String, dynamic> map) {
    return Resena(
      usuario: map['usuario'] ?? 'Anónimo',
      comentario: map['comentario'] ?? '',
      rating: map['rating'] ?? 0,
      fecha: (map['fecha'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuario': usuario,
      'comentario': comentario,
      'rating': rating,
      'fecha': fecha,
    };
  }
}
