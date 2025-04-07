class CartItem {
  final String nombre;
  final String imagen;
  final String talla;
  int cantidad; // No usamos `late` ni `final` para que pueda ser modificado
  final double precio;

  CartItem({
    required this.nombre,
    required this.imagen,
    required this.talla,
    required this.cantidad, // Lo dejamos como un campo normal para que se pueda modificar
    required this.precio,
  });
}
