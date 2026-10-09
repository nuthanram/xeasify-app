import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/dio_client.dart';

class AccountsRepository {
  final Dio _dio;
  AccountsRepository(this._dio);

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/accounts/me/');
    return res.data as Map<String, dynamic>;
  }

  Future<void> registerMerchant({
    required String email,
    required String password,
    required String phone,
    required String businessName,
    required String gstin,
  }) async {
    await _dio.post('/accounts/register/merchant/', data: {
      'email': email,
      'password': password,
      'phone': phone,
      'business_name': businessName,
      'gstin': gstin,
    });
  }

  Future<Map<String, dynamic>> updatePricing(
      String priceMin, String priceMax) async {
    final res = await _dio.patch('/accounts/creator/pricing/',
        data: {'price_min': priceMin, 'price_max': priceMax});
    return res.data as Map<String, dynamic>;
  }

  /// Creator onboarding step 2: probes the provider token already stored
  /// from SSO and, if it carries the metrics scope, advances signup_state
  /// to METRICS_GRANTED. No body — the backend picks the token itself.
  Future<Map<String, dynamic>> grantMetricsAccess() async {
    final res = await _dio.post('/accounts/creator/grant-metrics/');
    return res.data as Map<String, dynamic>;
  }
}

final accountsRepoProvider = Provider<AccountsRepository>(
    (ref) => AccountsRepository(ref.read(dioProvider)));
