import 'package:flutter/material.dart';
import 'package:zapato/Servicios/db_local.dart';
import 'producto_model.dart'; // Asegúrate de importar tu modelo Producto

class FavoritosModel extends ChangeNotifier {
  // Lista de productos favoritos
  List<Producto> _favoritos = [];

  // Devuelve los productos favoritos
  List<Producto> get favoritos => _favoritos;
  //List<Producto> get favoritos {

    //operaciones_db().getFavoritos();

    //return _favoritos;
  //}

  // Verifica si un producto es favorito
  bool esFavorito(Producto producto) {
    return _favoritos.contains(producto);
  }

  Future<void> obtenerFavoritos() async{
    _favoritos = await operaciones_db().getFavoritos();
    notifyListeners();
  }

  // Agrega un producto a la lista de favoritos
  void agregarFavorito(Producto producto) {
    if (!_favoritos.contains(producto)) {
      operaciones_db().addFavorito(producto);
      _favoritos.add(producto);
      //Subir a la db en la nube
      //Base local

      notifyListeners(); // Notifica a los consumidores de cambios
    }
  }

  // Remueve un producto de la lista de favoritos
  void removerFavorito(Producto producto) {
    operaciones_db().deleteFavorito(producto);
    _favoritos.remove(producto);
    notifyListeners(); // Notifica a los consumidores de cambios
  }

  // ✅ Nuevo método: vacía toda la lista de favoritos
  void vaciarFavoritos() {
    operaciones_db().limpiarFavoritos();
    _favoritos.clear();
    notifyListeners(); // Notifica que la lista cambió
  }
}
