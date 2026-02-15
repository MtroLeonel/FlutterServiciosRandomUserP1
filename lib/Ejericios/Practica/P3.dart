class Rectangulo {
  final double ancho;
  final double alto;

  Rectangulo({required this.ancho, required this.alto});

  double calcularArea() => ancho * alto;

  double calcularPerimetro() => 2 * (ancho + alto);

  bool esCuadrado() => ancho == alto;

  void mostrarInfo() {
    print('Rectángulo de ${ancho}x${alto}');
    print('Área: ${calcularArea()}');
    print('Perímetro: ${calcularPerimetro()}');
    print('¿Es un cuadrado?: ${esCuadrado() ? "Sí" : "No"}');
  }
}

void main() {
  final figura = Rectangulo(ancho: 10, alto: 10);
  figura.mostrarInfo();
}
