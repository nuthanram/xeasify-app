import 'package:dio/dio.dart';
import 'dart:convert';
import '../../core/config.dart';
import '../../core/secure_storage.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository([Dio? dio]) : _dio = dio ?? Dio(BaseOptions(baseUrl: kApiUrl));

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/token/', data: {'email': email, 'password': password});
    final access = res.data['access'] as String;
    // The JWT only carries user_id; the role (and a creator's signup state) come from
    // /accounts/me/. Defaulting the role sent merchants to the creator screens.
    final me = await _me(access);
    return {
      'access': access,
      'refresh': res.data['refresh'],
      'role': me['role'] ?? 'creator',
      'user_id': me['id'] ?? _decodeJwt(access)['user_id'] ?? '',
      'signup_state': me['signup_state'] ?? '',
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
    return _socialResult(res.data as Map<String, dynamic>);
  }

  /// YouTube sign-in, step 1 (web): the Google consent URL for [redirectUri] plus the
  /// signed `state` that has to come back with the authorization code.
  Future<({String authUrl, String state})> youtubeAuthUrl(String redirectUri) async {
    final res = await _dio.get('/accounts/auth/youtube/authorize/',
        queryParameters: {'redirect_uri': redirectUri});
    return (authUrl: res.data['auth_url'] as String, state: res.data['state'] as String);
  }

  /// YouTube sign-in, step 2: the server swaps Google's authorization [code] for tokens
  /// (the client secret never reaches the app) and logs the creator in.
  Future<Map<String, dynamic>> youtubeCodeLogin({
    required String code,
    required String redirectUri,
    required String state,
  }) async {
    final res = await _dio.post('/accounts/auth/youtube/', data: {
      'code': code,
      'redirect_uri': redirectUri,
      'state': state,
    });
    return _socialResult(res.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    final refresh = await SecureStorage.getRefreshToken();
    if (refresh != null) {
      try {
        await _dio.post('/auth/token/blacklist/', data: {'refresh': refresh});
      } catch (_) {}
    }
  }

  Future<Map<String, dynamic>> _me(String access) async {
    final res = await _dio.get('/accounts/me/',
        options: Options(headers: {'Authorization': 'Bearer $access'}));
    return res.data as Map<String, dynamic>;
  }

  Map<String, dynamic> _socialResult(Map<String, dynamic> data) {
    final jwtPayload = _decodeJwt(data['access'] as String);
    return {
      'access': data['access'],
      'refresh': data['refresh'],
      'role': data['role'] ?? jwtPayload['role'] ?? 'creator',
      'user_id': data['user_id'] ?? jwtPayload['user_id'] ?? '',
      'signup_state': data['signup_state'] ?? '',
      'needs_metrics_grant': data['needs_metrics_grant'] ?? false,
      'needs_contact_verification': data['needs_contact_verification'] ?? false,
    };
  }

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = base64.normalize(parts[1]);
    return jsonDecode(utf8.decode(base64.decode(payload))) as Map<String, dynamic>;
  }
}
