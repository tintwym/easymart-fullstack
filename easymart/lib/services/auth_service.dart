import 'api_service.dart';

class AuthService {
  final ApiService api = ApiService();

  Future<dynamic> login(String email, String password) async {
    return api.post('/auth/login', {'email': email, 'password': password});
  }

  Future<dynamic> register(String email, String password, String displayName) async {
    return api.post('/auth/register', {
      'email': email,
      'password': password,
      'fullname': displayName, // Backend expects 'fullname'
    });
  }
}
