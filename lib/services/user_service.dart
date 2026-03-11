import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

/// Servicio para consumir la API de RandomUser
class UserService {
  static const String _baseUrl = 'https://randomuser.me/api/';

  /// Obtiene una lista de usuarios de la API
  ///
  /// [results] especifica cuántos usuarios obtener (por defecto 10)
  Future<List<User>> getUsers({int results = 10}) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?results=$results'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> usersList = data['results'];
        return usersList.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
