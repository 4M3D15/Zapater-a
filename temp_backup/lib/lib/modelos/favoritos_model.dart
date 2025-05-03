import 'package:flutter/material.dart';

class FavoritosModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _favoritos = [];

  List<Map<String, dynamic>> get favoritos => _favoritos;

  void agregarFavorito(Map<String, dynamic> producto) {
    if (!esFavorito(producto)) {
      _favoritos.add(producto);
      notifyListeners();
    }
  }

  void removerFavorito(Map<String, dynamic> producto) {
    _favoritos.removeWhere((item) =>
    item["nombre"] == producto["nombre"] &&
        item["precio"] == producto["precio"] &&
        item["imagen"] == producto["imagen"]);
    notifyListeners();
  }

  bool esFavorito(Map<String, dynamic> producto) {
    return _favoritos.any((item) =>
    item["nombre"] == producto["nombre"] &&
        item["precio"] == producto["precio"] &&
        item["imagen"] == producto["imagen"]);
  }
  void vaciarFavoritos() {
    _favoritos.clear();
    notifyListeners();
  }
}

