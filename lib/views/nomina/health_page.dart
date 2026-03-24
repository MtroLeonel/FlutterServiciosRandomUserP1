import 'package:flutter/material.dart';

import 'sigch_session.dart';

/// Pantalla para validar el endpoint público /api/health.
class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  bool _isLoading = false;
  String _result = 'Presiona "Consultar" para verificar el estado de la API.';

  Future<void> _checkHealth() async {
    setState(() => _isLoading = true);
    try {
      final response = await SigchSession.service.health();
      if (!mounted) return;
      setState(
        () => _result =
            'success: ${response.success}\nmessage: ${response.message}',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _result = 'Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Check')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton(
              onPressed: _isLoading ? null : _checkHealth,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Consultar'),
            ),
            const SizedBox(height: 16),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
