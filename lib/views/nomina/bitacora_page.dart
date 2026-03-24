import 'package:flutter/material.dart';

import '../../models/sigch_api_model.dart';
import 'sigch_session.dart';

/// Pantalla de bitácora: consulta historial de cambios.
class BitacoraPage extends StatefulWidget {
  const BitacoraPage({super.key});

  @override
  State<BitacoraPage> createState() => _BitacoraPageState();
}

class _BitacoraPageState extends State<BitacoraPage> {
  bool _loading = false;
  String? _message;
  List<BitacoraEntry> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final items = await SigchSession.service.getBitacora();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Error al cargar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora'),
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
          if (_message != null) Text(_message!),
          if (_loading) const LinearProgressIndicator(),
          ..._items.map(
            (entry) => Card(
              child: ListTile(
                title: Text(
                  'Cambio: ${entry.changeType} (Empleado #${entry.employeeId})',
                ),
                subtitle: Text(
                  'De ${entry.previousValue} a ${entry.newValue}\nMotivo: ${entry.reason}\nPor usuario #${entry.changedBy}',
                ),
                trailing: Text('#${entry.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
