import 'package:flutter/material.dart';
import 'package:zapato/modelos/producto_model.dart';

class FavoritosModel with ChangeNotifier {
  final List<Producto> _favoritos = [];

  List<Producto> get favoritos => _favoritos;

  bool esFavorito(Producto producto) {
    return _favoritos.contains(producto);
  }

  void agregarFavorito(Producto producto) {
    if (!esFavorito(producto)) {
      _favoritos.add(producto);
      notifyListeners();
    }
  }

  void removerFavorito(Producto producto) {
    if (esFavorito(producto)) {
      _favoritos.remove(producto);
      notifyListeners();
    }
  }

  void vaciarFavoritos() {
    _favoritos.clear();
    notifyListeners();
  }
}
