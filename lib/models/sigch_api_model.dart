/// Excepción para errores controlados de la API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }
    return 'HTTP $statusCode: $message';
  }
}

/// Respuesta simple con indicador de éxito y mensaje.
class ApiMessageResponse {
  final bool success;
  final String message;

  ApiMessageResponse({required this.success, required this.message});

  factory ApiMessageResponse.fromJson(Map<String, dynamic> json) {
    return ApiMessageResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }
}

/// Respuesta con una lista de elementos tipados.
class ApiListResponse<T> {
  final bool success;
  final List<T> data;

  ApiListResponse({required this.success, required this.data});

  factory ApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawData = json['data'];
    final list = rawData is List
        ? rawData
              .whereType<Map<String, dynamic>>()
              .map(fromJson)
              .toList(growable: false)
        : <T>[];

    return ApiListResponse<T>(success: json['success'] == true, data: list);
  }
}

/// Respuesta con un objeto tipado.
class ApiDataResponse<T> {
  final bool success;
  final T data;

  ApiDataResponse({required this.success, required this.data});

  factory ApiDataResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawData = json['data'];
    if (rawData is! Map<String, dynamic>) {
      throw ApiException(
        'Formato de respuesta inválido: se esperaba un objeto en data',
      );
    }

    return ApiDataResponse<T>(
      success: json['success'] == true,
      data: fromJson(rawData),
    );
  }
}

/// Usuario devuelto durante autenticación.
class AuthUser {
  final int id;
  final String email;
  final String role;

  AuthUser({required this.id, required this.email, required this.role});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: _toInt(json['id']),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }
}

/// Respuesta de login.
class AuthResponse {
  final bool success;
  final String message;
  final String token;
  final AuthUser user;

  AuthResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    if (rawUser is! Map<String, dynamic>) {
      throw ApiException(
        'Formato de respuesta inválido: se esperaba un objeto user',
      );
    }

    return AuthResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      user: AuthUser.fromJson(rawUser),
    );
  }
}

class Employee {
  final int id;
  final String firstName;
  final String lastName;
  final String curp;
  final String hireDate;
  final String dailySalary;
  final String status;
  final List<Map<String, dynamic>> assignments;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.curp,
    required this.hireDate,
    required this.dailySalary,
    required this.status,
    required this.assignments,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    final rawAssignments = json['Assignments'];
    final parsedAssignments = rawAssignments is List
        ? rawAssignments.whereType<Map<String, dynamic>>().toList(
            growable: false,
          )
        : <Map<String, dynamic>>[];

    return Employee(
      id: _toInt(json['id']),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      curp: (json['curp'] ?? '').toString(),
      hireDate: (json['hireDate'] ?? '').toString(),
      dailySalary: (json['dailySalary'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      assignments: parsedAssignments,
    );
  }
}

class Department {
  final int id;
  final String name;
  final String code;
  final String status;

  Department({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class Position {
  final int id;
  final String name;
  final String level;
  final String baseSalary;
  final String status;

  Position({
    required this.id,
    required this.name,
    required this.level,
    required this.baseSalary,
    required this.status,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      baseSalary: (json['baseSalary'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class Payroll {
  final int id;
  final String type;
  final String startDate;
  final String endDate;
  final String status;

  Payroll({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: _toInt(json['id']),
      type: (json['type'] ?? '').toString(),
      startDate: (json['startDate'] ?? '').toString(),
      endDate: (json['endDate'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class Bono {
  final int id;
  final String name;
  final String amountType;
  final String amount;
  final bool active;

  Bono({
    required this.id,
    required this.name,
    required this.amountType,
    required this.amount,
    required this.active,
  });

  factory Bono.fromJson(Map<String, dynamic> json) {
    return Bono(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      amountType: (json['amountType'] ?? '').toString(),
      amount: (json['amount'] ?? '').toString(),
      active: _toBool(json['active']),
    );
  }
}

class BitacoraEntry {
  final int id;
  final int employeeId;
  final int changedBy;
  final String changeType;
  final String previousValue;
  final String newValue;
  final String reason;

  BitacoraEntry({
    required this.id,
    required this.employeeId,
    required this.changedBy,
    required this.changeType,
    required this.previousValue,
    required this.newValue,
    required this.reason,
  });

  factory BitacoraEntry.fromJson(Map<String, dynamic> json) {
    return BitacoraEntry(
      id: _toInt(json['id']),
      employeeId: _toInt(json['employeeId']),
      changedBy: _toInt(json['changedBy']),
      changeType: (json['changeType'] ?? '').toString(),
      previousValue: (json['previousValue'] ?? '').toString(),
      newValue: (json['newValue'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final normalized = (value ?? '').toString().toLowerCase();
  return normalized == 'true' || normalized == '1';
}
