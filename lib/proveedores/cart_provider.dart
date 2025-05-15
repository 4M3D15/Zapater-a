import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/cart_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalPrice => _items.fold(
      0.0, (total, item) => total + item.precio * item.cantidad);

  void addToCart(CartItem item) {
    final index = _items.indexWhere(
            (element) => element.id == item.id && element.talla == item.talla);
    if (index >= 0) {
      _items[index].cantidad += item.cantidad;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _items.removeWhere(
            (element) => element.id == item.id && element.talla == item.talla);
    notifyListeners();
  }

  void updateQuantity(CartItem item, int nuevaCantidad) {
    final index = _items.indexWhere(
            (element) => element.id == item.id && element.talla == item.talla);
    if (index >= 0) {
      _items[index].cantidad = nuevaCantidad;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<int> getStockDisponible(String productoId, String talla) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('productos')
          .doc(productoId)
          .get();
      final data = doc.data();
      if (data == null) return 0;

      final tallaMap = data['Talla'] as Map<String, dynamic>?;
      if (tallaMap == null) return 0;

      return tallaMap[talla]?.toInt() ?? 0;
    } catch (e) {
      print('Error al obtener el stock disponible: $e');
      return 0;
    }
  }
}
