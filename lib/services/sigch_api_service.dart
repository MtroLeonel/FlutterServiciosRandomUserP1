import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sigch_api_model.dart';

/// Servicio para consumir la API SIGCH.
class SigchApiService {
  final String baseUrl;
  final http.Client _client;
  String? _token;

  SigchApiService({this.baseUrl = 'http://localhost:3000', http.Client? client})
    : _client = client ?? http.Client();

  String? get token => _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/api/auth/login'),
      headers: _defaultHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final jsonMap = _decodeBody(response);
    _throwIfNotSuccess(response, jsonMap);

    final auth = AuthResponse.fromJson(jsonMap);
    if (auth.token.isNotEmpty) {
      _token = auth.token;
    }
    return auth;
  }

  Future<ApiMessageResponse> health() async {
    final response = await _client.get(
      _uri('/api/health'),
      headers: _defaultHeaders,
    );

    final jsonMap = _decodeBody(response);
    _throwIfNotSuccess(response, jsonMap);
    return ApiMessageResponse.fromJson(jsonMap);
  }

  Future<List<Employee>> getEmpleados() async {
    final jsonMap = await _getProtected('/api/empleados');
    return ApiListResponse<Employee>.fromJson(jsonMap, Employee.fromJson).data;
  }

  Future<Employee> createEmpleado({
    required String firstName,
    required String lastName,
    required String curp,
    required String hireDate,
    required String dailySalary,
    String status = 'activo',
  }) async {
    final jsonMap = await _postProtected('/api/empleados', {
      'firstName': firstName,
      'lastName': lastName,
      'curp': curp,
      'hireDate': hireDate,
      'dailySalary': dailySalary,
      'status': status,
    });
    return ApiDataResponse<Employee>.fromJson(jsonMap, Employee.fromJson).data;
  }

  Future<List<Department>> getDepartamentos() async {
    final jsonMap = await _getProtected('/api/departamentos');
    return ApiListResponse<Department>.fromJson(
      jsonMap,
      Department.fromJson,
    ).data;
  }

  Future<Department> createDepartamento({
    required String name,
    required String code,
    String status = 'activo',
  }) async {
    final jsonMap = await _postProtected('/api/departamentos', {
      'name': name,
      'code': code,
      'status': status,
    });
    return ApiDataResponse<Department>.fromJson(
      jsonMap,
      Department.fromJson,
    ).data;
  }

  Future<List<Position>> getPuestos() async {
    final jsonMap = await _getProtected('/api/puestos');
    return ApiListResponse<Position>.fromJson(jsonMap, Position.fromJson).data;
  }

  Future<Position> createPuesto({
    required String name,
    required String level,
    required String baseSalary,
    String status = 'activo',
  }) async {
    final jsonMap = await _postProtected('/api/puestos', {
      'name': name,
      'level': level,
      'baseSalary': baseSalary,
      'status': status,
    });
    return ApiDataResponse<Position>.fromJson(jsonMap, Position.fromJson).data;
  }

  Future<List<Payroll>> getPayroll() async {
    final jsonMap = await _getProtected('/api/payroll');
    return ApiListResponse<Payroll>.fromJson(jsonMap, Payroll.fromJson).data;
  }

  Future<Payroll> createPayroll({
    required String type,
    required String startDate,
    required String endDate,
    String status = 'abierto',
  }) async {
    final jsonMap = await _postProtected('/api/payroll', {
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
    });
    return ApiDataResponse<Payroll>.fromJson(jsonMap, Payroll.fromJson).data;
  }

  Future<List<Bono>> getBonos() async {
    final jsonMap = await _getProtected('/api/bonos');
    return ApiListResponse<Bono>.fromJson(jsonMap, Bono.fromJson).data;
  }

  Future<Bono> createBono({
    required String name,
    required String amountType,
    required String amount,
    bool active = true,
  }) async {
    final jsonMap = await _postProtected('/api/bonos', {
      'name': name,
      'amountType': amountType,
      'amount': amount,
      'active': active,
    });
    return ApiDataResponse<Bono>.fromJson(jsonMap, Bono.fromJson).data;
  }

  Future<List<BitacoraEntry>> getBitacora() async {
    final jsonMap = await _getProtected('/api/bitacora');
    return ApiListResponse<BitacoraEntry>.fromJson(
      jsonMap,
      BitacoraEntry.fromJson,
    ).data;
  }

  Future<Map<String, dynamic>> _getProtected(String path) async {
    _ensureToken();
    final response = await _client.get(_uri(path), headers: _protectedHeaders);
    final jsonMap = _decodeBody(response);
    _throwIfNotSuccess(response, jsonMap);
    return jsonMap;
  }

  Future<Map<String, dynamic>> _postProtected(
    String path,
    Map<String, dynamic> body,
  ) async {
    _ensureToken();
    final response = await _client.post(
      _uri(path),
      headers: _protectedHeaders,
      body: jsonEncode(body),
    );
    final jsonMap = _decodeBody(response);
    _throwIfNotSuccess(response, jsonMap);
    return jsonMap;
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _defaultHeaders => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> get _protectedHeaders {
    return {..._defaultHeaders, 'Authorization': 'Bearer $_token'};
  }

  void _ensureToken() {
    if (_token == null || _token!.isEmpty) {
      throw ApiException(
        'Token no proporcionado. Usa Authorization: Bearer <token>',
        statusCode: 401,
      );
    }
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw ApiException(
        'Formato de respuesta inválido',
        statusCode: response.statusCode,
      );
    } catch (_) {
      throw ApiException(
        'No se pudo interpretar la respuesta del servidor',
        statusCode: response.statusCode,
      );
    }
  }

  void _throwIfNotSuccess(http.Response response, Map<String, dynamic> body) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final message = (body['message'] ?? 'Error desconocido').toString();
    throw ApiException(message, statusCode: response.statusCode);
  }
}
