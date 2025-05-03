import 'package:flutter/material.dart';
import 'producto_model.dart'; // Asegúrate de importar tu modelo Producto

class FavoritosModel extends ChangeNotifier {
  // Lista de productos favoritos
  final List<Producto> _favoritos = [];

  // Devuelve los productos favoritos
  List<Producto> get favoritos => _favoritos;

  // Verifica si un producto es favorito
  bool esFavorito(Producto producto) {
    return _favoritos.contains(producto);
  }

  // Agrega un producto a la lista de favoritos
  void agregarFavorito(Producto producto) {
    if (!_favoritos.contains(producto)) {
      _favoritos.add(producto);
      notifyListeners(); // Notifica a los consumidores de cambios
    }
  }

  // Remueve un producto de la lista de favoritos
  void removerFavorito(Producto producto) {
    _favoritos.remove(producto);
    notifyListeners(); // Notifica a los consumidores de cambios
  }

  // ✅ Nuevo método: vacía toda la lista de favoritos
  void vaciarFavoritos() {
    _favoritos.clear();
    notifyListeners(); // Notifica que la lista cambió
  }
}
