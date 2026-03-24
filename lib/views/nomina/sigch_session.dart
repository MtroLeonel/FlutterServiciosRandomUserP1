import '../../models/sigch_api_model.dart';
import '../../services/sigch_api_service.dart';

/// Estado global simple para compartir sesión y servicio en los catálogos de nómina.
class SigchSession {
  SigchSession._();

  static final SigchApiService service = SigchApiService();
  static AuthResponse? authResponse;

  static bool get isLoggedIn =>
      service.token != null && service.token!.isNotEmpty;

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await service.login(email: email, password: password);
    authResponse = response;
    return response;
  }

  static void logout() {
    authResponse = null;
    service.clearToken();
  }
}
