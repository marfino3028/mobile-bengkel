import 'package:flutter/foundation.dart';

import '../models.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final _api = ApiClient.instance;

  User? _user;
  bool _loading = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;

  Future<void> loadUser() async {
    if (_api.token == null) return;
    try {
      final res = await _api.dio.get('/auth/me');
      _user = User.fromJson(Map<String, dynamic>.from(res.data['user']));
      notifyListeners();
    } catch (_) {
      await _api.setToken(null);
      _user = null;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final res = await _api.dio.post('/auth/login', data: {'email': email, 'password': password});
      await _api.setToken(res.data['token']);
      _user = User.fromJson(Map<String, dynamic>.from(res.data['user']));
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    try {
      final res = await _api.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      await _api.setToken(res.data['token']);
      _user = User.fromJson(Map<String, dynamic>.from(res.data['user']));
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    final res = await _api.dio.put('/auth/profile', data: {
      'name': name,
      'phone': phone,
    });
    _user = User.fromJson(Map<String, dynamic>.from(res.data['user']));
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (_) {}
    await _api.setToken(null);
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
