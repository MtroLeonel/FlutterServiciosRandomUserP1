//3. El Carrito de Compras (Mapas)
// Problema: Crear un programa que simule un carrito de compras, donde se almacenen los productos y sus precios. Luego, aplicar un descuento del 10% a cada producto y mostrar el precio final.
// Estructura: Uso de Map, double, forEach y operadores aritméticos.

void main() {
  Map<String, double> carrito = {
    'Laptop': 1200.0,
    'Mouse': 25.0,
    'Teclado': 45.0,
  };

  // Iterar sobre un mapa para aplicar descuento
  carrito.forEach((producto, precio) {
    double precioConDescuento = precio * 0.90;
    print('$producto: \$${precioConDescuento.toStringAsFixed(2)}');
  });
}
