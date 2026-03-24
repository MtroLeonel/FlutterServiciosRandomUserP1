import 'package:flutter/material.dart';

import '../../models/sigch_api_model.dart';
import 'sigch_session.dart';

/// Catálogo de departamentos: listar y crear departamentos.
class DepartamentosCatalogPage extends StatefulWidget {
  const DepartamentosCatalogPage({super.key});

  @override
  State<DepartamentosCatalogPage> createState() =>
      _DepartamentosCatalogPageState();
}

class _DepartamentosCatalogPageState extends State<DepartamentosCatalogPage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _statusController = TextEditingController(text: 'activo');

  bool _loading = false;
  String? _message;
  List<Department> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final items = await SigchSession.service.getDepartamentos();
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
      await SigchSession.service.createDepartamento(
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        status: _statusController.text.trim(),
      );
      if (!mounted) return;
      _nameController.clear();
      _codeController.clear();
      await _loadItems();
      setState(() => _message = 'Departamento creado correctamente');
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
        title: const Text('Catálogo de Departamentos'),
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
            'Nuevo departamento',
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
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Código',
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
            child: const Text('Crear departamento'),
          ),
          const SizedBox(height: 20),
          if (_message != null) Text(_message!),
          if (_loading) const LinearProgressIndicator(),
          ..._items.map(
            (d) => Card(
              child: ListTile(
                title: Text(d.name),
                subtitle: Text('Código: ${d.code} | Estatus: ${d.status}'),
                trailing: Text('#${d.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
