import 'package:flutter/material.dart';
import 'package:zapato/servicios/firestore_service.dart';
import 'package:zapato/modelos/producto_model.dart';

class ProductosModel with ChangeNotifier {
  List<Producto> _productos = [];
  bool isLoading = false;
  String? error;

  List<Producto> get productos => _productos;

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> obtenerProductos() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _productos = await _firestoreService.obtenerProductos();
    } catch (e) {
      error = 'Error al cargar los productos, comuniquese con soporte tecnico\n(Error $e)';
      debugPrint(error);
      print('Error al obtener productos: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
