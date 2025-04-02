import 'package:flutter/material.dart';
import 'package:zapato/modelos/cart_model.dart';


class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(CartItem item) {
    // Verifica si el producto ya está en el carrito con la misma talla
    int index = _items.indexWhere((p) => p.nombre == item.nombre && p.talla == item.talla);

    if (index != -1) {
      _items[index].cantidad += item.cantidad;
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + (item.precio * item.cantidad));
  }
}
