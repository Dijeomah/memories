import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final response = await _api.post(
      ApiConfig.authRegister,
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (phone != null) 'phone': phone,
      },
    );

    // Save token
    if (response['token'] != null) {
      await _api.saveToken(response['token']);
    }

    return response;
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      ApiConfig.authLogin,
      {
        'email': email,
        'password': password,
      },
    );

    // Save token
    if (response['token'] != null) {
      await _api.saveToken(response['token']);
    }

    return response;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.authLogout, {});
    } finally {
      // Clear token even if request fails
      await _api.clearToken();
    }
  }

  // Get current user
  Future<User> getCurrentUser() async {
    final response = await _api.get(ApiConfig.authMe);
    return User.fromJson(response['user']);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _api.getToken();
    return token != null && token.isNotEmpty;
  }
}
