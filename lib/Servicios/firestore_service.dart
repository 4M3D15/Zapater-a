import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zapato/modelos/producto_model.dart'; // Importación correcta

class FirestoreService {
  final CollectionReference _productosRef =
  FirebaseFirestore.instance.collection('productos');

  Future<List<Producto>> obtenerProductos() async {
    final snapshot = await _productosRef.get();
    return snapshot.docs.map((doc) => Producto.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
  }
}
