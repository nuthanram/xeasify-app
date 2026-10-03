import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveAccessToken(String token) =>
      _storage.write(key: 'access_token', value: token);

  static Future<void> saveRefreshToken(String token) =>
      _storage.write(key: 'refresh_token', value: token);

  static Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  static Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');

  static Future<void> saveRole(String role) => _storage.write(key: 'role', value: role);
  static Future<String?> getRole() => _storage.read(key: 'role');

  static Future<void> saveUserId(String id) => _storage.write(key: 'user_id', value: id);
  static Future<String?> getUserId() => _storage.read(key: 'user_id');

  static Future<void> saveSignupState(String s) => _storage.write(key: 'signup_state', value: s);
  static Future<String?> getSignupState() => _storage.read(key: 'signup_state');

  static Future<void> clear() => _storage.deleteAll();
}
