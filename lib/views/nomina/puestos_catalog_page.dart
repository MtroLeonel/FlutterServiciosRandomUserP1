import 'package:flutter/material.dart';

import '../../models/sigch_api_model.dart';
import 'sigch_session.dart';

/// Catálogo de puestos: listar y crear puestos.
class PuestosCatalogPage extends StatefulWidget {
  const PuestosCatalogPage({super.key});

  @override
  State<PuestosCatalogPage> createState() => _PuestosCatalogPageState();
}

class _PuestosCatalogPageState extends State<PuestosCatalogPage> {
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  final _baseSalaryController = TextEditingController(text: '900.00');
  final _statusController = TextEditingController(text: 'activo');

  bool _loading = false;
  String? _message;
  List<Position> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    _baseSalaryController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final items = await SigchSession.service.getPuestos();
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
      await SigchSession.service.createPuesto(
        name: _nameController.text.trim(),
        level: _levelController.text.trim(),
        baseSalary: _baseSalaryController.text.trim(),
        status: _statusController.text.trim(),
      );
      if (!mounted) return;
      _nameController.clear();
      _levelController.clear();
      await _loadItems();
      setState(() => _message = 'Puesto creado correctamente');
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
        title: const Text('Catálogo de Puestos'),
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
            'Nuevo puesto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _levelController,
            decoration: const InputDecoration(
              labelText: 'Nivel',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _baseSalaryController,
            decoration: const InputDecoration(
              labelText: 'Salario base',
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
            child: const Text('Crear puesto'),
          ),
          const SizedBox(height: 20),
          if (_message != null) Text(_message!),
          if (_loading) const LinearProgressIndicator(),
          ..._items.map(
            (p) => Card(
              child: ListTile(
                title: Text('${p.name} (${p.level})'),
                subtitle: Text(
                  'Salario: ${p.baseSalary} | Estatus: ${p.status}',
                ),
                trailing: Text('#${p.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
