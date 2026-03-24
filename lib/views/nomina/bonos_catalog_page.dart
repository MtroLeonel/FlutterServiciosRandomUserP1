import 'package:flutter/material.dart';

import '../../models/sigch_api_model.dart';
import 'sigch_session.dart';

/// Catálogo de bonos: listar y crear bonos.
class BonosCatalogPage extends StatefulWidget {
  const BonosCatalogPage({super.key});

  @override
  State<BonosCatalogPage> createState() => _BonosCatalogPageState();
}

class _BonosCatalogPageState extends State<BonosCatalogPage> {
  final _nameController = TextEditingController();
  final _amountTypeController = TextEditingController(text: 'fixed');
  final _amountController = TextEditingController(text: '750.00');
  bool _active = true;

  bool _loading = false;
  String? _message;
  List<Bono> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountTypeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final items = await SigchSession.service.getBonos();
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
      await SigchSession.service.createBono(
        name: _nameController.text.trim(),
        amountType: _amountTypeController.text.trim(),
        amount: _amountController.text.trim(),
        active: _active,
      );
      if (!mounted) return;
      _nameController.clear();
      await _loadItems();
      setState(() => _message = 'Bono creado correctamente');
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
        title: const Text('Catálogo de Bonos'),
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
            'Nuevo bono',
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
            controller: _amountTypeController,
            decoration: const InputDecoration(
              labelText: 'Tipo de monto (fixed/percent)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Monto',
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            value: _active,
            title: const Text('Activo'),
            onChanged: _loading
                ? null
                : (value) => setState(() => _active = value),
          ),
          FilledButton(
            onPressed: _loading ? null : _createItem,
            child: const Text('Crear bono'),
          ),
          const SizedBox(height: 20),
          if (_message != null) Text(_message!),
          if (_loading) const LinearProgressIndicator(),
          ..._items.map(
            (b) => Card(
              child: ListTile(
                title: Text(b.name),
                subtitle: Text(
                  'Tipo: ${b.amountType} | Monto: ${b.amount} | Activo: ${b.active}',
                ),
                trailing: Text('#${b.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
