import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _productosRef =
  FirebaseFirestore.instance.collection('productos');

  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    final snapshot = await _productosRef.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
