import 'package:flutter/material.dart';

import 'sigch_session.dart';

/// Pantalla para iniciar/cerrar sesión usando el endpoint /api/auth/login.
class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({super.key});

  @override
  State<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final _emailController = TextEditingController(text: 'admin@sigch.local');
  final _passwordController = TextEditingController(text: '123456');

  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await SigchSession.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() {
        _message =
            '${response.message}\nUsuario: ${response.user.email} (${response.user.role})';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _logout() {
    SigchSession.logout();
    setState(() {
      _message = 'Sesión cerrada';
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = SigchSession.authResponse;

    return Scaffold(
      appBar: AppBar(title: const Text('Autenticación')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Iniciar sesión en API SIGCH',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _logout,
                  child: const Text('Cerrar sesión'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (auth != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sesión activa',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Usuario: ${auth.user.email}'),
                    Text('Rol: ${auth.user.role}'),
                    Text(
                      'Token: ${auth.token.substring(0, auth.token.length > 25 ? 25 : auth.token.length)}...',
                    ),
                  ],
                ),
              ),
            ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_message!),
            ),
        ],
      ),
    );
  }
}
