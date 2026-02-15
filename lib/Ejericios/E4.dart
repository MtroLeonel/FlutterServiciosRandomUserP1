//4. Creación del Modelo "Vehículo" (Clases)
// Problema: Crear una clase "Vehículo" con atributos como marca, modelo y año. Luego, crear un método que muestre la información del vehículo y otro que calcule su antigüedad.
// Estructura: Uso de clases, atributos, métodos y operadores aritméticos.
class Vehiculo {
  final String marca;
  final String modelo;

  // Constructor con parámetros nombrados y obligatorios
  Vehiculo({required this.marca, required this.modelo});

  void mostrarInfo() => print('Vehículo: $marca $modelo');
}

void main() {
  final miAuto = Vehiculo(marca: 'Toyota', modelo: 'Corolla');
  miAuto.mostrarInfo();
}
