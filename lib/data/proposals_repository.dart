import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/dio_client.dart';

class ProposalsRepository {
  final Dio _dio;
  ProposalsRepository(this._dio);

  Future<List<Map<String, dynamic>>> getMyProposals() async {
    final res = await _dio.get('/bidding/proposals/');
    return List<Map<String, dynamic>>.from(res.data['results'] ?? []);
  }

  Future<Map<String, dynamic>> submitProposal(String campaignId, String pitch, String bidAmount) async {
    final res = await _dio.post('/bidding/proposals/', data: {
      'campaign_id': campaignId,
      'pitch': pitch,
      'bid_amount': bidAmount,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getNegotiationMessages(String proposalId) async {
    final res = await _dio.get('/bidding/proposals/$proposalId/negotiation_messages/');
    return List<Map<String, dynamic>>.from(res.data);
  }

  Future<void> sendCounter(String proposalId, String body, {String? counterPrice}) async {
    await _dio.patch('/bidding/proposals/$proposalId/counter/', data: {
      'body': body,
      if (counterPrice != null) 'counter_price': counterPrice,
    });
  }
}

final proposalsRepoProvider = Provider<ProposalsRepository>(
  (ref) => ProposalsRepository(ref.read(dioProvider)),
);
