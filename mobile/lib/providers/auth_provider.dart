import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));

      _token = 'dummy_token';
      _user = {'name': 'Test User', 'email': email};
      _isAuthenticated = true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(Map<String, String> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));

      _token = 'dummy_token';
      _user = data;
      _isAuthenticated = true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
