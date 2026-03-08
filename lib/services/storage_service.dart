import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _biometricKey = 'biometric_enabled';
  static const _activeGroupKey = 'active_group_id';

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> setToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  static Future<String?> getActiveGroupId() =>
      _storage.read(key: _activeGroupKey);

  static Future<void> setActiveGroupId(String id) =>
      _storage.write(key: _activeGroupKey, value: id);

  static Future<void> deleteActiveGroupId() =>
      _storage.delete(key: _activeGroupKey);

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricKey);
    return value == 'true';
  }

  static Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: _biometricKey, value: enabled.toString());

  static const _onboardingKey = 'onboarding_done';

  static Future<bool> isOnboardingDone() async {
    final value = await _storage.read(key: _onboardingKey);
    return value == 'true';
  }

  static Future<void> setOnboardingDone() =>
      _storage.write(key: _onboardingKey, value: 'true');
}
