class Producto {
  final String nombre;
  final double precio;
  final double descuento; // Ejemplo: 15.0 para un 15%

  Producto({
    required this.nombre,
    required this.precio,
    required this.descuento,
  });

  double calcularPrecioFinal() {
    return precio - (precio * (descuento / 100));
  }

  void imprimirEtiqueta() {
    print(
      'Articulo: $nombre | Precio Final: \$${calcularPrecioFinal().toStringAsFixed(2)}',
    );
  }
}

void main() {
  final laptop = Producto(nombre: 'Dell XPS', precio: 1500.0, descuento: 10);
  laptop.imprimirEtiqueta();
}
