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

  Future<List<Map<String, dynamic>>> getCampaignProposals(
      String campaignId) async {
    final res = await _dio.get('/bidding/proposals/',
        queryParameters: {'campaign': campaignId});
    return List<Map<String, dynamic>>.from(res.data['results'] ?? []);
  }

  Future<Map<String, dynamic>> submitProposal(
      String campaignId, String pitch, String bidAmount) async {
    final res = await _dio.post('/bidding/proposals/', data: {
      'campaign': campaignId,
      'pitch': pitch,
      'bid_amount': bidAmount,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getNegotiationMessages(
      String proposalId) async {
    final res = await _dio
        .get('/bidding/proposals/$proposalId/negotiation-messages/');
    return List<Map<String, dynamic>>.from(res.data);
  }

  /// Creator replies in the negotiation thread (can optionally propose a new price).
  Future<void> replyToNegotiation(String proposalId, String body,
      {String? counterPrice}) async {
    await _dio.patch('/bidding/proposals/$proposalId/reply/', data: {
      'body': body,
      if (counterPrice != null && counterPrice.isNotEmpty)
        'counter_price': counterPrice,
    });
  }

  /// Merchant sends a counter offer on a creator's proposal.
  Future<void> sendCounter(String proposalId, String body,
      {String? counterPrice}) async {
    await _dio.patch('/bidding/proposals/$proposalId/counter/', data: {
      'body': body,
      if (counterPrice != null && counterPrice.isNotEmpty)
        'counter_price': counterPrice,
    });
  }

  Future<void> acceptProposal(String proposalId) async {
    await _dio.patch('/bidding/proposals/$proposalId/accept/');
  }

  Future<void> withdrawProposal(String proposalId) async {
    await _dio.delete('/bidding/proposals/$proposalId/');
  }

  Future<List<Map<String, dynamic>>> getRoiForecast(
      String campaignId) async {
    final res = await _dio.get('/bidding/roi-forecast/',
        queryParameters: {'campaign': campaignId});
    return List<Map<String, dynamic>>.from(res.data['results'] ?? []);
  }
}

final proposalsRepoProvider = Provider<ProposalsRepository>(
  (ref) => ProposalsRepository(ref.read(dioProvider)),
);
