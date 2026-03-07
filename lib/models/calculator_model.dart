import 'dart:math';

/// Modelo que contiene las operaciones básicas de una calculadora
class Calculator {
  /// Suma dos números
  double sumar(double a, double b) {
    return a + b;
  }

  /// Resta dos números
  double restar(double a, double b) {
    return a - b;
  }

  /// Multiplica dos números
  double multiplicar(double a, double b) {
    return a * b;
  }

  /// Divide dos números
  /// Lanza una excepción si el divisor es cero
  double dividir(double a, double b) {
    if (b == 0) {
      throw Exception('No se puede dividir entre cero');
    }
    return a / b;
  }

  /// Calcula la potencia de un número
  /// [base] es el número base
  /// [exponente] es el exponente al que se elevará la base
  double potencia(double base, double exponente) {
    return pow(base, exponente).toDouble();
  }

  /// Calcula el factorial de un número entero
  /// Lanza una excepción si el número es negativo o mayor a 20
  double factorial(int numero) {
    if (numero < 0) {
      throw Exception(
        'No se puede calcular el factorial de un número negativo',
      );
    }
    if (numero > 20) {
      throw Exception('Número demasiado grande para calcular factorial');
    }

    int resultado = 1;
    for (int i = 1; i <= numero; i++) {
      resultado *= i;
    }
    return resultado.toDouble();
  }

  /// Calcula la raíz cuadrada de un número
  /// Lanza una excepción si el número es negativo
  double raizCuadrada(double numero) {
    if (numero < 0) {
      throw Exception(
        'No se puede calcular la raíz cuadrada de un número negativo',
      );
    }
    return sqrt(numero);
  }
}
