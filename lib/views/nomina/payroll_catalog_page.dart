import 'package:flutter/material.dart';

import '../../models/sigch_api_model.dart';
import 'sigch_session.dart';

/// Catálogo de nómina: listar y crear periodos de nómina.
class PayrollCatalogPage extends StatefulWidget {
  const PayrollCatalogPage({super.key});

  @override
  State<PayrollCatalogPage> createState() => _PayrollCatalogPageState();
}

class _PayrollCatalogPageState extends State<PayrollCatalogPage> {
  final _typeController = TextEditingController(text: 'quincenal');
  final _startDateController = TextEditingController(text: '2026-03-01');
  final _endDateController = TextEditingController(text: '2026-03-15');
  final _statusController = TextEditingController(text: 'abierto');

  bool _loading = false;
  String? _message;
  List<Payroll> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final items = await SigchSession.service.getPayroll();
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
      await SigchSession.service.createPayroll(
        type: _typeController.text.trim(),
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
        status: _statusController.text.trim(),
      );
      if (!mounted) return;
      await _loadItems();
      setState(() => _message = 'Periodo de nómina creado correctamente');
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
        title: const Text('Catálogo de Nómina'),
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
            'Nuevo periodo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _typeController,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _startDateController,
            decoration: const InputDecoration(
              labelText: 'Fecha inicio (YYYY-MM-DD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _endDateController,
            decoration: const InputDecoration(
              labelText: 'Fecha fin (YYYY-MM-DD)',
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
            child: const Text('Crear periodo'),
          ),
          const SizedBox(height: 20),
          if (_message != null) Text(_message!),
          if (_loading) const LinearProgressIndicator(),
          ..._items.map(
            (p) => Card(
              child: ListTile(
                title: Text('${p.type} (${p.startDate} - ${p.endDate})'),
                subtitle: Text('Estatus: ${p.status}'),
                trailing: Text('#${p.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
