import 'package:flutter/material.dart';
import '../models/calculator_model.dart';

/// Página principal de la calculadora
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // Instancia del modelo de calculadora
  final Calculator _calculator = Calculator();

  // Controladores para los campos de texto
  final TextEditingController _numero1Controller = TextEditingController();
  final TextEditingController _numero2Controller = TextEditingController();

  // Variable para almacenar el resultado
  String _resultado = '0';

  /// Realiza la operación seleccionada
  void _realizarOperacion(String operacion) {
    try {
      // Parsear los números ingresados
      double num1 = double.parse(_numero1Controller.text);
      double num2 = double.parse(_numero2Controller.text);
      double resultado;

      // Ejecutar la operación correspondiente
      switch (operacion) {
        case 'sumar':
          resultado = _calculator.sumar(num1, num2);
          break;
        case 'restar':
          resultado = _calculator.restar(num1, num2);
          break;
        case 'multiplicar':
          resultado = _calculator.multiplicar(num1, num2);
          break;
        case 'dividir':
          resultado = _calculator.dividir(num1, num2);
          break;
        case 'potencia':
          resultado = _calculator.potencia(num1, num2);
          break;
        default:
          resultado = 0;
      }

      // Actualizar el estado con el resultado
      setState(() {
        _resultado = resultado.toStringAsFixed(2);
      });
    } catch (e) {
      // Manejar errores (números inválidos, división por cero, etc.)
      setState(() {
        _resultado = 'Error: ${e.toString()}';
      });
    }
  }

  /// Realiza operaciones que solo requieren un número (del primer campo)
  void _realizarOperacionUnNumero(String operacion) {
    try {
      double num1 = double.parse(_numero1Controller.text);
      double resultado;

      switch (operacion) {
        case 'raizCuadrada':
          resultado = _calculator.raizCuadrada(num1);
          break;
        case 'factorial':
          int numeroEntero = num1.toInt();
          resultado = _calculator.factorial(numeroEntero);
          break;
        default:
          resultado = 0;
      }

      setState(() {
        _resultado = resultado.toStringAsFixed(2);
      });
    } catch (e) {
      setState(() {
        _resultado = 'Error: ${e.toString()}';
      });
    }
  }

  /// Limpia los campos y el resultado
  void _limpiar() {
    setState(() {
      _numero1Controller.clear();
      _numero2Controller.clear();
      _resultado = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _limpiar,
            tooltip: 'Limpiar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo de texto para el primer número
            _buildTextField(controller: _numero1Controller, label: 'Número 1'),
            const SizedBox(height: 16),

            // Campo de texto para el segundo número
            _buildTextField(controller: _numero2Controller, label: 'Número 2'),
            const SizedBox(height: 32),

            // Mostrar el resultado
            _buildResultado(),
            const SizedBox(height: 32),

            // Botones de operaciones
            _buildBotonesOperaciones(),
          ],
        ),
      ),
    );
  }

  /// Construye un campo de texto personalizado
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calculate),
      ),
    );
  }

  /// Construye el widget que muestra el resultado
  Widget _buildResultado() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Resultado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _resultado,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye los botones de operaciones
  Widget _buildBotonesOperaciones() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBotonOperacion(
              icono: Icons.add,
              label: 'Sumar',
              onPressed: () => _realizarOperacion('sumar'),
            ),
            _buildBotonOperacion(
              icono: Icons.remove,
              label: 'Restar',
              onPressed: () => _realizarOperacion('restar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBotonOperacion(
              icono: Icons.close,
              label: 'Multiplicar',
              onPressed: () => _realizarOperacion('multiplicar'),
            ),
            _buildBotonOperacion(
              icono: Icons.android,
              label: 'Dividir',
              onPressed: () => _realizarOperacion('dividir'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBotonOperacion(
              icono: Icons.functions,
              label: 'Potencia',
              onPressed: () => _realizarOperacion('potencia'),
            ),
            _buildBotonOperacion(
              icono: Icons.square_foot,
              label: 'Raíz √',
              onPressed: () => _realizarOperacionUnNumero('raizCuadrada'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBotonOperacion(
              icono: Icons.format_list_numbered,
              label: 'Factorial',
              onPressed: () => _realizarOperacionUnNumero('factorial'),
            ),
            // Espacio vacío para mantener el diseño
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  /// Construye un botón de operación personalizado
  Widget _buildBotonOperacion({
    required IconData icono,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icono),
          label: Text(label),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Liberar recursos
    _numero1Controller.dispose();
    _numero2Controller.dispose();
    super.dispose();
  }
}
