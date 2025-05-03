import 'package:flutter/material.dart';
import 'package:zapato/modelos/cart_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Añadir un producto al carrito
  void addToCart(CartItem item) {
    int index = _items.indexWhere((p) => p.nombre == item.nombre && p.talla == item.talla);

    if (index != -1) {
      // Si el producto ya está en el carrito, aumentamos la cantidad
      _items[index].cantidad += item.cantidad;
    } else {
      // Si el producto no está en el carrito, lo agregamos
      _items.add(item);
    }

    notifyListeners();
  }

  // Eliminar un producto del carrito
  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  // Vaciar el carrito
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Obtener el precio total del carrito
  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + (item.precio * item.cantidad));
  }

  // Aumentar la cantidad de un producto
  void increaseQuantity(CartItem item) {
    int index = _items.indexOf(item);
    if (index != -1) {
      _items[index].cantidad++;
      notifyListeners();  // Notificamos a la UI que la cantidad ha cambiado
    }
  }

  // Disminuir la cantidad de un producto
  void decreaseQuantity(CartItem item) {
    int index = _items.indexOf(item);
    if (index != -1 && _items[index].cantidad > 1) {
      _items[index].cantidad--;
      notifyListeners();  // Notificamos a la UI que la cantidad ha cambiado
    }
  }

  // Modificar la cantidad directamente
  void updateQuantity(CartItem item, int newQuantity) {
    int index = _items.indexOf(item);
    if (index != -1 && newQuantity > 0) {
      _items[index].cantidad = newQuantity;
      notifyListeners();  // Notificamos a la UI que la cantidad ha cambiado
    }
  }
}
