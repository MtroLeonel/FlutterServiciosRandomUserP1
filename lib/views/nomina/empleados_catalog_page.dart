import 'package:flutter/material.dart';

import '../../models/sigch_api_model.dart';
import 'sigch_session.dart';

/// Catálogo de empleados: listar y crear empleados.
class EmpleadosCatalogPage extends StatefulWidget {
  const EmpleadosCatalogPage({super.key});

  @override
  State<EmpleadosCatalogPage> createState() => _EmpleadosCatalogPageState();
}

class _EmpleadosCatalogPageState extends State<EmpleadosCatalogPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _curpController = TextEditingController();
  final _hireDateController = TextEditingController(text: '2026-01-15');
  final _dailySalaryController = TextEditingController(text: '950.00');
  final _statusController = TextEditingController(text: 'activo');

  bool _loading = false;
  String? _message;
  List<Employee> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _curpController.dispose();
    _hireDateController.dispose();
    _dailySalaryController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final items = await SigchSession.service.getEmpleados();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Error al cargar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createItem() async {
    setState(() => _loading = true);
    try {
      await SigchSession.service.createEmpleado(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        curp: _curpController.text.trim(),
        hireDate: _hireDateController.text.trim(),
        dailySalary: _dailySalaryController.text.trim(),
        status: _statusController.text.trim(),
      );
      if (!mounted) return;
      _firstNameController.clear();
      _lastNameController.clear();
      _curpController.clear();
      await _loadItems();
      setState(() => _message = 'Empleado creado correctamente');
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Error al crear: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Empleados'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadItems,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Nuevo empleado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Apellido',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _curpController,
            decoration: const InputDecoration(
              labelText: 'CURP',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _hireDateController,
            decoration: const InputDecoration(
              labelText: 'Fecha ingreso (YYYY-MM-DD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _dailySalaryController,
            decoration: const InputDecoration(
              labelText: 'Salario diario',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _statusController,
            decoration: const InputDecoration(
              labelText: 'Estatus',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _createItem,
            child: const Text('Crear empleado'),
          ),
          const SizedBox(height: 20),
          if (_message != null) Text(_message!),
          const SizedBox(height: 10),
          const Text(
            'Listado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (_loading) const LinearProgressIndicator(),
          ..._items.map(
            (e) => Card(
              child: ListTile(
                title: Text('${e.firstName} ${e.lastName}'),
                subtitle: Text(
                  'CURP: ${e.curp} | Salario: ${e.dailySalary} | Estatus: ${e.status}',
                ),
                trailing: Text('#${e.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
