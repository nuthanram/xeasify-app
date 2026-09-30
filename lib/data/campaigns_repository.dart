import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/dio_client.dart';

class CampaignsRepository {
  final Dio _dio;
  CampaignsRepository(this._dio);

  Future<List<Map<String, dynamic>>> getCampaigns({String? category, String? deliverableType}) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (deliverableType != null) params['deliverable_type'] = deliverableType;
    final res = await _dio.get('/marketplace/campaigns/', queryParameters: params);
    return List<Map<String, dynamic>>.from(res.data['results'] ?? []);
  }

  Future<Map<String, dynamic>> getCampaign(String id) async {
    final res = await _dio.get('/marketplace/campaigns/$id/');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createCampaign(Map<String, dynamic> payload) async {
    final res = await _dio.post('/marketplace/campaigns/', data: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await _dio.get('/marketplace/categories/');
    return List<Map<String, dynamic>>.from(res.data['results'] ?? []);
  }
}

final campaignsRepoProvider = Provider<CampaignsRepository>(
  (ref) => CampaignsRepository(ref.read(dioProvider)),
);
