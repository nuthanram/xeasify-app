import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'secure_storage.dart';

const String kBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: '$kBaseUrl/api/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(AuthInterceptor(ref));
  return dio;
});

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  bool _isRefreshing = false;

  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refresh = await SecureStorage.getRefreshToken();
        if (refresh == null) throw Exception('No refresh token');

        final refreshDio = Dio(BaseOptions(baseUrl: '$kBaseUrl/api/v1'));
        final res = await refreshDio.post('/auth/token/refresh/', data: {'refresh': refresh});
        final newAccess = res.data['access'] as String;

        await SecureStorage.saveAccessToken(newAccess);
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';

        final retryDio = Dio(BaseOptions(baseUrl: '$kBaseUrl/api/v1'));
        final retry = await retryDio.fetch(err.requestOptions);
        handler.resolve(retry);
      } catch (_) {
        await SecureStorage.clear();
        handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}
