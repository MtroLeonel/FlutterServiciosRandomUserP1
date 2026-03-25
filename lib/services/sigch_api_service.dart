import 'dart:convert';
import 'dart:async'; // Para TimeoutException
import 'dart:io';    // Para SocketException
import 'package:http/http.dart' as http;
import '../models/sigch_api_model.dart';

class SigchApiService {
  final String baseUrl;
  final http.Client _client;
  String? _token;

  SigchApiService({this.baseUrl = 'https://nominasys.fly.dev', http.Client? client})
      : _client = client ?? http.Client();

  String? get token => _token;
  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  // --- HEADERS  ---
  
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Importante para evitar bloqueos de hosts como Fly.io/Cloudflare
    'User-Agent': 'SigchDesktopApp/1.0', 
  };

  Map<String, String> get _protectedHeaders {
    return {
      ..._defaultHeaders,
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // --- MÉTODOS PÚBLICOS ---

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    // Usamos la lógica centralizada para consistencia
    final jsonMap = await _postRaw('/api/auth/login', {
      'email': email.trim(), // Limpieza de datos básica
      'password': password,
    });

    final auth = AuthResponse.fromJson(jsonMap);
    if (auth.token.isNotEmpty) {
      _token = auth.token;
    }
    return auth;
  }

  Future<ApiMessageResponse> health() async {
    try {
      final response = await _client.get(
        _uri('/api/health'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 15));
      return ApiMessageResponse.fromJson(_processResponse(response));
    } on SocketException {
      throw ApiException('Error de red: No se pudo conectar al servidor.', statusCode: 503);
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder.', statusCode: 408);
    }
  }

  Future<List<Employee>> getEmpleados() async {
    final json = await _getProtected('/api/empleados');
    return ApiListResponse.fromJson(json, Employee.fromJson).data;
  }

  Future<void> createEmpleado({
    required String firstName,
    required String lastName,
    required String curp,
    required String hireDate,
    required String dailySalary,
    String status = 'activo',
  }) async {
    await _postProtected('/api/empleados', {
      'firstName': firstName,
      'lastName': lastName,
      'curp': curp,
      'hireDate': hireDate,
      'dailySalary': dailySalary,
      'status': status,
    });
  }

  Future<List<Department>> getDepartamentos() async {
    final json = await _getProtected('/api/departamentos');
    return ApiListResponse.fromJson(json, Department.fromJson).data;
  }

  Future<void> createDepartamento({
    required String name,
    required String code,
    String status = 'activo',
  }) async {
    await _postProtected('/api/departamentos', {
      'name': name,
      'code': code,
      'status': status,
    });
  }

  Future<List<Position>> getPuestos() async {
    final json = await _getProtected('/api/puestos');
    return ApiListResponse.fromJson(json, Position.fromJson).data;
  }

  Future<void> createPuesto({
    required String name,
    required String level,
    required String baseSalary,
    String status = 'activo',
  }) async {
    await _postProtected('/api/puestos', {
      'name': name,
      'level': level,
      'baseSalary': baseSalary,
      'status': status,
    });
  }

  Future<List<Payroll>> getPayroll() async {
    final json = await _getProtected('/api/payroll');
    return ApiListResponse.fromJson(json, Payroll.fromJson).data;
  }

  Future<void> createPayroll({
    required String type,
    required String startDate,
    required String endDate,
    String status = 'pendiente',
  }) async {
    await _postProtected('/api/payroll', {
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
    });
  }

  Future<List<Bono>> getBonos() async {
    final json = await _getProtected('/api/bonos');
    return ApiListResponse.fromJson(json, Bono.fromJson).data;
  }

  Future<void> createBono({
    required String name,
    required String amountType,
    required String amount,
    bool active = true,
  }) async {
    await _postProtected('/api/bonos', {
      'name': name,
      'amountType': amountType,
      'amount': amount,
      'active': active,
    });
  }

  Future<List<BitacoraEntry>> getBitacora() async {
    final json = await _getProtected('/api/bitacora');
    return ApiListResponse.fromJson(json, BitacoraEntry.fromJson).data;
  }

  // --- MÉTODOS PRIVADOS DE AYUDA---

  /// Petición POST sin necesidad de token previo (para Login)
  Future<Map<String, dynamic>> _postRaw(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client.post(
        _uri(path),
        headers: _defaultHeaders,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15)); // Timeout para Desktop

      return _processResponse(response);
    } on SocketException {
      throw ApiException('Error de red: No se pudo conectar al servidor.', statusCode: 503);
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder.', statusCode: 408);
    }
  }

  Future<Map<String, dynamic>> _getProtected(String path) async {
    _ensureToken();
    try {
      final response = await _client.get(
        _uri(path), 
        headers: _protectedHeaders
      ).timeout(const Duration(seconds: 15));
      
      return _processResponse(response);
    } on SocketException {
       throw ApiException('Error de red: Verifica tu conexión.', statusCode: 503);
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder.', statusCode: 408);
    }
  }

  Future<Map<String, dynamic>> _postProtected(String path, Map<String, dynamic> body) async {
    _ensureToken();
    try {
      final response = await _client.post(
        _uri(path),
        headers: _protectedHeaders,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      
      return _processResponse(response);
    } on SocketException {
       throw ApiException('Error de red: No se pudo enviar la información.', statusCode: 503);
    } on TimeoutException {
      throw ApiException('El servidor tardó demasiado en responder.', statusCode: 408);
    }
  }

  // --- LÓGICA DE PROCESAMIENTO CENTRALIZADA ---

  Map<String, dynamic> _processResponse(http.Response response) {
    final jsonMap = _decodeBody(response);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonMap;
    }
    
    // Si el servidor responde 401, el token probablemente expiró
    if (response.statusCode == 401) {
      clearToken();
      throw ApiException('Sesión expirada o credenciales inválidas.', statusCode: 401);
    }

    final message = jsonMap['message'] ?? 'Error inesperado (${response.statusCode})';
    throw ApiException(message.toString(), statusCode: response.statusCode);
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  void _ensureToken() {
    if (_token == null || _token!.isEmpty) {
      throw ApiException('No hay una sesión activa.', statusCode: 401);
    }
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      // La API devolvió un array raíz → lo envolvemos en {data: [...]}
      if (decoded is List) return {'success': true, 'data': decoded};
      throw ApiException('Formato de respuesta inesperado.', statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Error al leer respuesta del servidor.', statusCode: response.statusCode);
    }
  }
}