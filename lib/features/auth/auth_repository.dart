import 'package:dio/dio.dart';
import 'dart:convert';
import '../../core/secure_storage.dart';

const String kBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: '$kBaseUrl/api/v1'));

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/token/', data: {'email': email, 'password': password});
    final access = res.data['access'] as String;
    // Decode JWT payload to get role and user_id
    final payload = _decodeJwt(access);
    return {
      'access': access,
      'refresh': res.data['refresh'],
      'role': payload['role'] ?? 'creator',
      'user_id': payload['user_id'] ?? '',
    };
  }

  /// Creator-only. Posts the native SDK access_token to the backend social
  /// auth endpoint and returns the resulting JWT pair + metadata.
  ///
  /// [provider] — "instagram" | "facebook" | "youtube" | "tiktok"
  /// [accessToken] — short-lived token obtained from the native SDK on device
  Future<Map<String, dynamic>> socialAuth({
    required String provider,
    required String accessToken,
    String? displayName,
  }) async {
    final res = await _dio.post('/accounts/auth/social/', data: {
      'provider': provider,
      'access_token': accessToken,
      if (displayName != null) 'display_name': displayName,
    });
    final data = res.data as Map<String, dynamic>;
    final jwtPayload = _decodeJwt(data['access'] as String);
    return {
      'access': data['access'],
      'refresh': data['refresh'],
      'role': jwtPayload['role'] ?? 'creator',
      'user_id': jwtPayload['user_id'] ?? '',
      'signup_state': data['signup_state'] ?? '',
      'needs_metrics_grant': data['needs_metrics_grant'] ?? false,
      'needs_contact_verification': data['needs_contact_verification'] ?? false,
    };
  }

  Future<void> logout() async {
    final refresh = await SecureStorage.getRefreshToken();
    if (refresh != null) {
      try {
        await _dio.post('/auth/token/blacklist/', data: {'refresh': refresh});
      } catch (_) {}
    }
  }

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = base64.normalize(parts[1]);
    return jsonDecode(utf8.decode(base64.decode(payload))) as Map<String, dynamic>;
  }
}
