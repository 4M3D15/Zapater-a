class CartItem {
  final String nombre;
  final String imagen;
  final String talla;
  late final int cantidad;
  final double precio;

  CartItem({
    required this.nombre,
    required this.imagen,
    required this.talla,
    required this.cantidad,
    required this.precio,
  });
}
