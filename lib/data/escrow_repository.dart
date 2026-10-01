import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/dio_client.dart';
import 'dart:math';

class EscrowRepository {
  final Dio _dio;
  EscrowRepository(this._dio);

  Future<Map<String, dynamic>> submitDeliverable(
      String ledgerId, String submissionUrl) async {
    final idempotencyKey = _generateUuid();
    final res = await _dio.post(
      '/escrow/submit/$ledgerId/',
      data: {'submission_url': submissionUrl},
      options: Options(headers: {'X-Idempotency-Key': idempotencyKey}),
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fundCampaign(String campaignId,
      {String? proposalId}) async {
    final idempotencyKey = _generateUuid();
    final res = await _dio.post(
      '/escrow/fund/$campaignId/',
      data: {if (proposalId != null) 'proposal_id': proposalId},
      options: Options(headers: {'X-Idempotency-Key': idempotencyKey}),
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> topUpWallet(
      String amount, String gatewayPaymentId) async {
    final idempotencyKey = _generateUuid();
    final res = await _dio.post(
      '/escrow/wallet/topup/',
      data: {'amount': amount, 'gateway_payment_id': gatewayPaymentId},
      options: Options(headers: {'X-Idempotency-Key': idempotencyKey}),
    );
    return res.data as Map<String, dynamic>;
  }

  static String _generateUuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex =
        bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}

final escrowRepoProvider = Provider<EscrowRepository>(
  (ref) => EscrowRepository(ref.read(dioProvider)),
);
