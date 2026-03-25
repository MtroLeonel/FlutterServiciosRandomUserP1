import '../../models/sigch_api_model.dart';
import '../../services/sigch_api_service.dart';

/// Estado global simple para compartir sesión y servicio en los catálogos de nómina.
class SigchSession {
  SigchSession._();

  static final SigchApiService service = SigchApiService();
  static AuthResponse? authResponse;

  static const String email = 'admin@sigch.local';
  static const String password = '123456';

  static bool get isLoggedIn =>
      service.token != null && service.token!.isNotEmpty;

  static Future<AuthResponse> login({String? email, String? password}) async {
    final response = await service.login(
      email: email ?? SigchSession.email,
      password: password ?? SigchSession.password,
    );
    authResponse = response;
    return response;
  }

  static void logout() {
    authResponse = null;
    service.clearToken();
  }
}
