// 1. El Validador de Edad (Variables y Tipos)
// Problema: Crear un programa que determine si una persona es mayor de edad y si puede votar.
// Estructura: Uso de String, int, bool y operadores lógicos.
void main() {
  // Definición de variables con tipado fuerte
  String nombre = "Juan";
  int edad = 17;

  // Lógica booleana
  bool puedeVotar = edad >= 18;

  print('$nombre tiene $edad años. ¿Puede votar?: $puedeVotar');
}
