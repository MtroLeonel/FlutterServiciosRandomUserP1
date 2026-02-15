// 5. Sistema de Empleados (Herencia)
// Problema: Crear una clase base "Empleado" con atributos como nombre y salario. Luego, crear una clase derivada "Gerente" que herede de "Empleado" y tenga un método adicional para mostrar un mensaje de bienvenida.
// Estructura: Uso de clases, herencia, atributos y métodos.
class Empleado {
  double salario;
  Empleado(this.salario);

  void calcularPago() => print('Pago: $salario');
}

class Gerente extends Empleado {
  double bono;
  Gerente(double salario, this.bono) : super(salario);

  @override
  void calcularPago() => print('Pago Gerente: ${salario + bono}');
}

void main() {
  // Instancia de la clase padre
  final empleadoComun = Empleado(1000.0);
  empleadoComun.calcularPago();

  // Instancia de la clase hija
  final jefe = Gerente(2500.0, 500.0);
  jefe.calcularPago();
}
