import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final authProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  bool get isLoggedIn => ApiService.token != null;
  String? get userName => ApiService.userName;
  String? get userEmail => ApiService.userEmail;

  Future<bool> login(String email, String password) async {
    return ApiService.login(email, password);
  }

  void logout() {
    ApiService.logout();
  }
}
