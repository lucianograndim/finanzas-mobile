import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  static final Dio _dio = ApiClient.instance;

  static Future<({String token, User user})> login(
      String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    return (
      token: (data['access_token'] ?? '') as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  static Future<({String token, User user})> register(
      String name, String email, String password) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    return (
      token: (data['access_token'] ?? '') as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  static Future<User> getMe() async {
    final response = await _dio.get('/auth/me');
    return User.fromJson(response.data as Map<String, dynamic>);
  }
}
