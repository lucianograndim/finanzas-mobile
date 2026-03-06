import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../services/storage_service.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = true;
  bool _biometricEnabled = false;
  bool _biometricPassed = false;
  bool _biometricAvailable = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  User? get user => _user;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;
  bool get needsGroup => _user != null && !_user!.hasGroup;
  bool get biometricEnabled => _biometricEnabled;
  bool get biometricAvailable => _biometricAvailable;
  bool get needsBiometric =>
      _user != null && _biometricEnabled && !_biometricPassed;

  Future<void> init() async {
    _loading = true;
    notifyListeners();

    ApiClient.init(onUnauthorizedCallback: () {
      _user = null;
      _biometricPassed = false;
      notifyListeners();
    });

    try {
      _biometricAvailable = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (_) {
      _biometricAvailable = false;
    }

    _biometricEnabled = await StorageService.isBiometricEnabled();

    final token = await StorageService.getToken();
    if (token != null) {
      try {
        _user = await AuthService.getMe();
        if (!_biometricEnabled) {
          _biometricPassed = true;
        }
      } catch (_) {
        await StorageService.deleteToken();
        _user = null;
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> authenticateBiometric() async {
    try {
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Desbloquea Finanzas App',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (didAuth) {
        _biometricPassed = true;
        notifyListeners();
      }
      return didAuth;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleBiometric(bool enabled) async {
    if (enabled && _biometricAvailable) {
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Confirma para activar bloqueo biometrico',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (!didAuth) return;
    }
    _biometricEnabled = enabled;
    _biometricPassed = true;
    await StorageService.setBiometricEnabled(enabled);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final result = await AuthService.login(email, password);
    await StorageService.setToken(result.token);
    _user = result.user;
    _biometricPassed = true;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    final result = await AuthService.register(name, email, password);
    await StorageService.setToken(result.token);
    _user = result.user;
    _biometricPassed = true;
    notifyListeners();
  }

  Future<void> createGroup(String name) async {
    final result = await GroupService.createGroup(name);
    await StorageService.setToken(result.token);
    _user = await AuthService.getMe();
    notifyListeners();
  }

  Future<void> joinGroup(String code) async {
    final result = await GroupService.joinGroup(code);
    await StorageService.setToken(result.token);
    _user = await AuthService.getMe();
    notifyListeners();
  }

  Future<void> logout() async {
    await StorageService.deleteToken();
    _user = null;
    _biometricPassed = false;
    notifyListeners();
  }

  void forceLogout() {
    _user = null;
    _biometricPassed = false;
    notifyListeners();
  }

  String extractError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        return error.response?.data['message']?.toString() ??
            error.message ??
            'Error del servidor';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Tiempo de conexion agotado';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'No se pudo conectar al servidor';
      }
      return error.message ?? 'Error de conexion';
    }
    return error.toString();
  }
}
