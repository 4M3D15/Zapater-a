class CartItem {
  final String nombre;
  final String imagen;
  final double precio;
  String talla;
  int cantidad;

  CartItem({
    required this.nombre,
    required this.imagen,
    required this.precio,
    required this.talla,
    required this.cantidad,
  });
}
