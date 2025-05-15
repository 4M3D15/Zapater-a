class CartItem {
  final String id;
  final String nombre;
  final String imagen;
  final double precio;
  final String talla;
  int cantidad;

  CartItem({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.precio,
    required this.talla,
    required this.cantidad,
  });
}
