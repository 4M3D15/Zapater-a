class CartItem {
  final String nombre;
  final String imagen;
  final String talla;
  int cantidad; // No usamos `late` ni `final` para que pueda ser modificado
  final double precio;

  // Constructor modificado para aceptar datos de Firestore
  CartItem({
    required this.nombre,
    required this.imagen,
    required this.talla,
    required this.cantidad,
    required this.precio,
  });

  // Método que convierte un mapa de Firestore en un CartItem
  factory CartItem.fromFirestore(Map<String, dynamic> data) {
    return CartItem(
      nombre: data['Nombre'],
      imagen: data['Imagen'],
      talla: data['Talla'],
      cantidad: 1,  // Iniciamos cantidad como 1, puedes modificar según lo necesites
      precio: (data['Precio'] as num).toDouble(),
    );
  }

  // Método para convertir un CartItem a un mapa, útil para Firestore si necesitas guardar o actualizar
  Map<String, dynamic> toMap() {
    return {
      'Nombre': nombre,
      'Imagen': imagen,
      'Talla': talla,
      'Cantidad': cantidad,
      'Precio': precio,
    };
  }
}
