//2. Calculadora de Promedio (Listas y Bucles)
// Problema: Crear un programa que calcule el promedio de una lista de calificaciones y determine si el estudiante aprobó o reprobó.
// Estructura: Uso de List, double, for loop y operadores condicionales.

void main() {
  List<double> notas = [7.5, 8.0, 5.5, 9.2];

  double suma = 0;

  // Recorremos la lista para sumar
  for (var nota in notas) {
    suma += nota;
  }

  double promedio = suma / notas.length;
  // Uso de toStringAsFixed para limpiar la salida
  print('Promedio: ${promedio.toStringAsFixed(2)}');
  print(promedio >= 6 ? 'Aprobado' : 'Reprobado');
}
