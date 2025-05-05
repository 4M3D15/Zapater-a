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

  factory Resena.fromFirestore(Map<String, dynamic> data) {
    return Resena(
      usuario: data['usuario'] ?? 'Anónimo',
      comentario: data['comentario'] ?? '',
      rating: data['rating'] ?? 0,
      fecha: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuario': usuario,
      'comentario': comentario,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
