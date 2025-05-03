import 'package:flutter/material.dart';
import 'package:zapato/modelos/productos_model.dart'; // Asegúrate de importar la clase Producto

class FavoritosModel extends ChangeNotifier {
  final List<Producto> _favoritos = [];

  List<Producto> get favoritos => _favoritos;

  void agregarFavorito(Producto producto) {
    if (!esFavorito(producto)) {
      _favoritos.add(producto);
      notifyListeners();
    }
  }

  void removerFavorito(Producto producto) {
    _favoritos.removeWhere((item) =>
    item.nombre == producto.nombre &&
        item.precio == producto.precio &&
        item.imagen == producto.imagen);
    notifyListeners();
  }

  bool esFavorito(Producto producto) {
    return _favoritos.any((item) =>
    item.nombre == producto.nombre &&
        item.precio == producto.precio &&
        item.imagen == producto.imagen);
  }

  void vaciarFavoritos() {
    _favoritos.clear();
    notifyListeners();
  }
}
