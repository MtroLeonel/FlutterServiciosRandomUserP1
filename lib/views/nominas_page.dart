import 'package:flutter/material.dart';

import '../models/sigch_api_model.dart';
import 'nomina/sigch_session.dart';

/// Panel principal de práctica nómina con menú lateral y módulos CRUD.
class NominasPage extends StatefulWidget {
  const NominasPage({super.key});

  @override
  State<NominasPage> createState() => _NominasPageState();
}

class _NominasPageState extends State<NominasPage> {
  _NominaSection _selected = _NominaSection.login;

  bool _loading = false;
  String? _message;

  List<Employee> _empleados = const [];
  List<Department> _departamentos = const [];
  List<Position> _puestos = const [];
  List<Payroll> _nominas = const [];
  List<Bono> _bonos = const [];
  List<BitacoraEntry> _bitacora = const [];
  ApiMessageResponse? _health;

  final _passwordController = TextEditingController(text: '123456');

  final _eNombre = TextEditingController();
  final _eApellidos = TextEditingController();
  final _eCurp = TextEditingController();
  final _eIngreso = TextEditingController();
  final _eSalario = TextEditingController();
  String? _eDepartamento;
  String? _ePuesto;

  final _nTipo = TextEditingController(text: 'quincenal');
  final _nInicio = TextEditingController();
  final _nFin = TextEditingController();

  final _bNombre = TextEditingController();
  final _bMonto = TextEditingController();
  String _bTipoMonto = 'fixed';
  bool _bActivo = true;

  final _dNombre = TextEditingController();
  final _dCodigo = TextEditingController();

  final _pNombre = TextEditingController();
  final _pNivel = TextEditingController();
  final _pSalario = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = SigchSession.isLoggedIn
        ? _NominaSection.inicio
        : _NominaSection.login;
  }

  @override
  void dispose() {
    _passwordController.dispose();

    _eNombre.dispose();
    _eApellidos.dispose();
    _eCurp.dispose();
    _eIngreso.dispose();
    _eSalario.dispose();

    _nTipo.dispose();
    _nInicio.dispose();
    _nFin.dispose();

    _bNombre.dispose();
    _bMonto.dispose();

    _dNombre.dispose();
    _dCodigo.dispose();

    _pNombre.dispose();
    _pNivel.dispose();
    _pSalario.dispose();

    super.dispose();
  }

  Future<void> _select(_NominaSection section) async {
    if (!SigchSession.isLoggedIn &&
        section != _NominaSection.login &&
        section != _NominaSection.health) {
      setState(() {
        _selected = _NominaSection.login;
        _message = 'Inicia sesión para acceder al sistema de nómina.';
      });
      return;
    }

    setState(() {
      _selected = section;
      _message = null;
    });

    if (section == _NominaSection.nuevoEmpleado) {
      await _ensureEmployeeSources();
    }

    await _loadFor(section);
  }

  Future<void> _ensureEmployeeSources() async {
    if (_departamentos.isEmpty) {
      _departamentos = await SigchSession.service.getDepartamentos();
    }
    if (_puestos.isEmpty) {
      _puestos = await SigchSession.service.getPuestos();
    }
    if (_eDepartamento == null && _departamentos.isNotEmpty) {
      _eDepartamento = _departamentos.first.name;
    }
    if (_ePuesto == null && _puestos.isNotEmpty) {
      _ePuesto = _puestos.first.name;
    }
  }

  Future<void> _loadFor(_NominaSection section) async {
    setState(() => _loading = true);
    try {
      switch (section) {
        case _NominaSection.empleados:
          _empleados = await SigchSession.service.getEmpleados();
          break;
        case _NominaSection.departamentos:
          _departamentos = await SigchSession.service.getDepartamentos();
          if (_eDepartamento == null && _departamentos.isNotEmpty) {
            _eDepartamento = _departamentos.first.name;
          }
          break;
        case _NominaSection.puestos:
          _puestos = await SigchSession.service.getPuestos();
          if (_ePuesto == null && _puestos.isNotEmpty) {
            _ePuesto = _puestos.first.name;
          }
          break;
        case _NominaSection.nomina:
          _nominas = await SigchSession.service.getPayroll();
          break;
        case _NominaSection.bonos:
          _bonos = await SigchSession.service.getBonos();
          break;
        case _NominaSection.bitacora:
          _bitacora = await SigchSession.service.getBitacora();
          break;
        case _NominaSection.health:
          _health = await SigchSession.service.health();
          break;
        case _NominaSection.inicio:
        case _NominaSection.login:
        case _NominaSection.perfil:
        case _NominaSection.nuevoEmpleado:
        case _NominaSection.nuevoNomina:
        case _NominaSection.nuevoBono:
        case _NominaSection.nuevoDepartamento:
        case _NominaSection.nuevoPuesto:
          break;
      }
    } catch (e) {
      setState(() => _message = 'Error: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final auth = await SigchSession.login(
        password: _passwordController.text,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _selected = _NominaSection.perfil;
        _message = auth.message;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _message = 'Error de login: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _logout() {
    SigchSession.logout();
    setState(() {
      _selected = _NominaSection.login;
      _message = 'Sesión cerrada';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(_selected.label),
              backgroundColor: const Color(0xFF1F3C68),
              foregroundColor: Colors.white,
            ),
      drawer: isDesktop
          ? null
          : Drawer(child: SafeArea(child: _sidebar(isInDrawer: true))),
      body: Container(
        color: const Color(0xFFF2F3F5),
        child: Row(
          children: [
            if (isDesktop)
              SizedBox(width: 280, child: _sidebar(isInDrawer: false)),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _content()),
                  _footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebar({required bool isInDrawer}) {
    final menu = [
      _NominaSection.inicio,
      _NominaSection.empleados,
      _NominaSection.departamentos,
      _NominaSection.puestos,
      _NominaSection.nomina,
      _NominaSection.bonos,
      _NominaSection.bitacora,
      _NominaSection.login,
      _NominaSection.health,
    ];

    return Container(
      color: const Color(0xFF1F3C68),
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Práctica Nómina',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24),
          Expanded(
            child: ListView.builder(
              itemCount: menu.length,
              itemBuilder: (context, index) {
                final item = menu[index];
                final selected = _isSelectedMenu(item);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    selected: selected,
                    selectedTileColor: const Color(0xFF415D84),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: Icon(item.icon, color: Colors.white),
                    title: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onTap: () async {
                      await _select(item);
                      if (isInDrawer && Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          if (SigchSession.authResponse != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usuario activo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    SigchSession.authResponse!.user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rol: ${SigchSession.authResponse!.user.role}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _select(_NominaSection.perfil),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1F3C68),
              ),
              icon: const Icon(Icons.person),
              label: const Text('Perfil', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSelectedMenu(_NominaSection menu) {
    if (_selected == menu) {
      return true;
    }

    if (menu == _NominaSection.empleados &&
        _selected == _NominaSection.nuevoEmpleado) {
      return true;
    }
    if (menu == _NominaSection.nomina &&
        _selected == _NominaSection.nuevoNomina) {
      return true;
    }
    if (menu == _NominaSection.bonos && _selected == _NominaSection.nuevoBono) {
      return true;
    }
    if (menu == _NominaSection.departamentos &&
        _selected == _NominaSection.nuevoDepartamento) {
      return true;
    }
    if (menu == _NominaSection.puestos &&
        _selected == _NominaSection.nuevoPuesto) {
      return true;
    }

    return false;
  }

  Widget _content() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      children: [
        if (_loading) const LinearProgressIndicator(),
        if (_message != null) ...[
          const SizedBox(height: 8),
          Text(_message!, style: const TextStyle(color: Color(0xFFB00020))),
          const SizedBox(height: 8),
        ],
        if (_selected == _NominaSection.inicio) _inicio(),
        if (_selected == _NominaSection.login) _loginView(),
        if (_selected == _NominaSection.perfil) _perfilView(),
        if (_selected == _NominaSection.health) _healthView(),
        if (_selected == _NominaSection.empleados) _empleadosView(),
        if (_selected == _NominaSection.nuevoEmpleado) _nuevoEmpleadoView(),
        if (_selected == _NominaSection.departamentos) _departamentosView(),
        if (_selected == _NominaSection.nuevoDepartamento)
          _nuevoDepartamentoView(),
        if (_selected == _NominaSection.puestos) _puestosView(),
        if (_selected == _NominaSection.nuevoPuesto) _nuevoPuestoView(),
        if (_selected == _NominaSection.nomina) _nominaView(),
        if (_selected == _NominaSection.nuevoNomina) _nuevoNominaView(),
        if (_selected == _NominaSection.bonos) _bonosView(),
        if (_selected == _NominaSection.nuevoBono) _nuevoBonoView(),
        if (_selected == _NominaSection.bitacora) _bitacoraView(),
      ],
    );
  }

  Widget _inicio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFF468ECC),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenido a Práctica Nómina',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Sistema de Gestión de Nómina',
                style: TextStyle(color: Colors.white70, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loginView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Iniciar sesión',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _profileLine('Email', SigchSession.email),
            const SizedBox(height: 10),
            _field('Contraseña', _passwordController, obscure: true),
            const SizedBox(height: 4),
            Row(
              children: [
                FilledButton(
                  onPressed: _loading ? null : _login,
                  child: const Text('Entrar'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _loading ? null : _logout,
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _perfilView() {
    final auth = SigchSession.authResponse;
    if (auth == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perfil',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('No hay sesión activa.'),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () => _select(_NominaSection.login),
                child: const Text('Ir a login'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(radius: 30, child: Icon(Icons.person, size: 36)),
                SizedBox(width: 10),
                Text(
                  'Perfil',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _profileLine('ID', '${auth.user.id}'),
            _profileLine('Email', auth.user.email),
            _profileLine('Rol', auth.user.role),
          ],
        ),
      ),
    );
  }

  Widget _profileLine(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E5EA)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF8FAFC),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _healthView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Check',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _loading
                  ? null
                  : () => _loadFor(_NominaSection.health),
              child: const Text('Consultar'),
            ),
            const SizedBox(height: 10),
            if (_health != null)
              Text(
                'success: ${_health!.success}\nmessage: ${_health!.message}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _empleadosView() {
    return _tableView(
      'Empleados',
      onNuevo: () => setState(() => _selected = _NominaSection.nuevoEmpleado),
      table: DataTable(
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('CURP')),
          DataColumn(label: Text('Departamento')),
          DataColumn(label: Text('Puesto')),
          DataColumn(label: Text('Salario diario')),
          DataColumn(label: Text('Ingreso')),
        ],
        rows: _empleados
            .map(
              (e) => DataRow(
                cells: [
                  DataCell(Text('${e.firstName} ${e.lastName}')),
                  DataCell(Text(e.curp)),
                  const DataCell(Text('N/A')),
                  const DataCell(Text('N/A')),
                  DataCell(Text('\$${e.dailySalary}')),
                  DataCell(Text(e.hireDate)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _departamentosView() {
    return _tableView(
      'Departamentos',
      onNuevo: () =>
          setState(() => _selected = _NominaSection.nuevoDepartamento),
      table: DataTable(
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Código')),
          DataColumn(label: Text('Estatus')),
        ],
        rows: _departamentos
            .map(
              (d) => DataRow(
                cells: [
                  DataCell(Text(d.name)),
                  DataCell(Text(d.code)),
                  DataCell(Text(d.status)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _puestosView() {
    return _tableView(
      'Puestos',
      onNuevo: () => setState(() => _selected = _NominaSection.nuevoPuesto),
      table: DataTable(
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Nivel')),
          DataColumn(label: Text('Salario base')),
          DataColumn(label: Text('Estatus')),
        ],
        rows: _puestos
            .map(
              (p) => DataRow(
                cells: [
                  DataCell(Text(p.name)),
                  DataCell(Text(p.level)),
                  DataCell(Text('\$${p.baseSalary}')),
                  DataCell(Text(p.status)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _nominaView() {
    return _tableView(
      'Nómina',
      onNuevo: () => setState(() => _selected = _NominaSection.nuevoNomina),
      table: DataTable(
        columns: const [
          DataColumn(label: Text('Tipo')),
          DataColumn(label: Text('Fecha inicio')),
          DataColumn(label: Text('Fecha fin')),
          DataColumn(label: Text('Estatus')),
        ],
        rows: _nominas
            .map(
              (n) => DataRow(
                cells: [
                  DataCell(Text(n.type)),
                  DataCell(Text(n.startDate)),
                  DataCell(Text(n.endDate)),
                  DataCell(Text(n.status)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _bonosView() {
    return _tableView(
      'Bonos',
      onNuevo: () => setState(() => _selected = _NominaSection.nuevoBono),
      table: DataTable(
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Tipo de monto')),
          DataColumn(label: Text('Monto')),
          DataColumn(label: Text('Activo')),
        ],
        rows: _bonos
            .map(
              (b) => DataRow(
                cells: [
                  DataCell(Text(b.name)),
                  DataCell(Text(b.amountType)),
                  DataCell(Text('\$${b.amount}')),
                  DataCell(Text(b.active ? 'Sí' : 'No')),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _bitacoraView() {
    return _tableView(
      'Bitácora',
      table: DataTable(
        columns: const [
          DataColumn(label: Text('Empleado')),
          DataColumn(label: Text('Tipo cambio')),
          DataColumn(label: Text('Anterior')),
          DataColumn(label: Text('Nuevo')),
          DataColumn(label: Text('Motivo')),
        ],
        rows: _bitacora
            .map(
              (x) => DataRow(
                cells: [
                  DataCell(Text('${x.employeeId}')),
                  DataCell(Text(x.changeType)),
                  DataCell(Text(x.previousValue)),
                  DataCell(Text(x.newValue)),
                  DataCell(Text(x.reason)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _tableView(
    String title, {
    required DataTable table,
    VoidCallback? onNuevo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (onNuevo != null)
              FilledButton(
                onPressed: onNuevo,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF09C4A8),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Nuevo'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
          ),
        ),
      ],
    );
  }

  Widget _nuevoEmpleadoView() {
    final departamentosItems = _departamentos.isNotEmpty
        ? _departamentos.map((d) => d.name).toList(growable: false)
        : const ['RH', 'TI', 'Ventas'];
    final puestosItems = _puestos.isNotEmpty
        ? _puestos.map((p) => p.name).toList(growable: false)
        : const ['Ejecutiva de Ventas', 'Senior Dev', 'Analista'];

    _eDepartamento ??= departamentosItems.first;
    _ePuesto ??= puestosItems.first;

    return _formContainer(
      title: 'Nuevo empleado',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Nombre', _eNombre),
          _field('Apellidos', _eApellidos),
          _field('CURP', _eCurp),
          _field('Fecha de ingreso', _eIngreso),
          _field('Salario diario', _eSalario),
          const Text(
            'Departamento',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _eDepartamento,
            items: departamentosItems
                .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                .toList(),
            onChanged: (value) => setState(() => _eDepartamento = value),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          const Text('Puesto', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _ePuesto,
            items: puestosItems
                .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                .toList(),
            onChanged: (value) => setState(() => _ePuesto = value),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              FilledButton(
                onPressed: _saveEmpleado,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF09C4A8),
                ),
                child: const Text('Guardar'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () =>
                    setState(() => _selected = _NominaSection.empleados),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nuevoNominaView() {
    return _formContainer(
      title: 'Nuevo periodo de nómina',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Tipo', _nTipo),
          _field('Fecha inicio', _nInicio),
          _field('Fecha fin', _nFin),
          Row(
            children: [
              FilledButton(
                onPressed: _saveNomina,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF09C4A8),
                ),
                child: const Text('Guardar'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () =>
                    setState(() => _selected = _NominaSection.nomina),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nuevoBonoView() {
    return _formContainer(
      title: 'Nuevo bono',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Nombre', _bNombre),
          const Text(
            'Tipo de monto',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _bTipoMonto,
            items: const [
              DropdownMenuItem(value: 'fixed', child: Text('Fijo')),
              DropdownMenuItem(value: 'percent', child: Text('Porcentaje')),
            ],
            onChanged: (value) =>
                setState(() => _bTipoMonto = value ?? 'fixed'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          _field('Monto', _bMonto),
          CheckboxListTile(
            value: _bActivo,
            onChanged: (value) => setState(() => _bActivo = value ?? true),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text('Activo'),
          ),
          Row(
            children: [
              FilledButton(
                onPressed: _saveBono,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF09C4A8),
                ),
                child: const Text('Guardar'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () =>
                    setState(() => _selected = _NominaSection.bonos),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nuevoDepartamentoView() {
    return _formContainer(
      title: 'Nuevo departamento',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Nombre', _dNombre),
          _field('Código', _dCodigo),
          Row(
            children: [
              FilledButton(
                onPressed: _saveDepartamento,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF09C4A8),
                ),
                child: const Text('Guardar'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () =>
                    setState(() => _selected = _NominaSection.departamentos),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nuevoPuestoView() {
    return _formContainer(
      title: 'Nuevo puesto',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Nombre', _pNombre),
          _field('Nivel', _pNivel),
          _field('Salario base', _pSalario),
          Row(
            children: [
              FilledButton(
                onPressed: _savePuesto,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF09C4A8),
                ),
                child: const Text('Guardar'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () =>
                    setState(() => _selected = _NominaSection.puestos),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formContainer({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Card(
              child: Padding(padding: const EdgeInsets.all(14), child: child),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEmpleado() async {
    setState(() => _loading = true);
    try {
      await SigchSession.service.createEmpleado(
        firstName: _eNombre.text.trim(),
        lastName: _eApellidos.text.trim(),
        curp: _eCurp.text.trim(),
        hireDate: _eIngreso.text.trim(),
        dailySalary: _eSalario.text.trim(),
      );
      _eNombre.clear();
      _eApellidos.clear();
      _eCurp.clear();
      _eIngreso.clear();
      _eSalario.clear();
      if (!mounted) return;
      setState(() => _selected = _NominaSection.empleados);
      await _loadFor(_NominaSection.empleados);
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Error al guardar empleado: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveNomina() async {
    setState(() => _loading = true);
    try {
      await SigchSession.service.createPayroll(
        type: _nTipo.text.trim(),
        startDate: _nInicio.text.trim(),
        endDate: _nFin.text.trim(),
      );
      _nInicio.clear();
      _nFin.clear();
      if (!mounted) return;
      setState(() => _selected = _NominaSection.nomina);
      await _loadFor(_NominaSection.nomina);
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Error al guardar nómina: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveBono() async {
    setState(() => _loading = true);
    try {
      await SigchSession.service.createBono(
        name: _bNombre.text.trim(),
        amountType: _bTipoMonto,
        amount: _bMonto.text.trim(),
        active: _bActivo,
      );
      _bNombre.clear();
      _bMonto.clear();
      if (!mounted) return;
      setState(() => _selected = _NominaSection.bonos);
      await _loadFor(_NominaSection.bonos);
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Error al guardar bono: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveDepartamento() async {
    setState(() => _loading = true);
    try {
      await SigchSession.service.createDepartamento(
        name: _dNombre.text.trim(),
        code: _dCodigo.text.trim(),
      );
      _dNombre.clear();
      _dCodigo.clear();
      if (!mounted) return;
      setState(() => _selected = _NominaSection.departamentos);
      await _loadFor(_NominaSection.departamentos);
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Error al guardar departamento: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePuesto() async {
    setState(() => _loading = true);
    try {
      await SigchSession.service.createPuesto(
        name: _pNombre.text.trim(),
        level: _pNivel.text.trim(),
        baseSalary: _pSalario.text.trim(),
      );
      _pNombre.clear();
      _pNivel.clear();
      _pSalario.clear();
      if (!mounted) return;
      setState(() => _selected = _NominaSection.puestos);
      await _loadFor(_NominaSection.puestos);
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Error al guardar puesto: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _footer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: const Color(0xFFEFEFF1),
      child: const Column(
        children: [
          Text(
            'Práctica Nómina - Sistema de Gestión de Nómina',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text('© 2026 - Todos los derechos reservados'),
        ],
      ),
    );
  }
}

enum _NominaSection {
  inicio('Inicio', Icons.home),
  empleados('Empleados', Icons.groups),
  departamentos('Departamentos', Icons.apartment),
  puestos('Puestos', Icons.work),
  nomina('Nómina', Icons.request_page),
  bonos('Bonos', Icons.card_giftcard),
  bitacora('Bitácora', Icons.history),
  login('Login', Icons.lock),
  health('Health', Icons.health_and_safety),
  perfil('Perfil', Icons.person),
  nuevoEmpleado('Nuevo empleado', Icons.add),
  nuevoNomina('Nuevo nómina', Icons.add),
  nuevoBono('Nuevo bono', Icons.add),
  nuevoDepartamento('Nuevo departamento', Icons.add),
  nuevoPuesto('Nuevo puesto', Icons.add);

  const _NominaSection(this.label, this.icon);

  final String label;
  final IconData icon;
}
