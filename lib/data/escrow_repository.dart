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

  /// Merchant wallet top-up via Razorpay.
  /// Flutter receives all three Razorpay fields from the Razorpay SDK callback
  /// after the user completes payment, then posts them here for server-side
  /// signature verification before the wallet is credited.
  Future<Map<String, dynamic>> topUpWallet({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    required String amount,
  }) async {
    final idempotencyKey = _generateUuid();
    final res = await _dio.post(
      '/escrow/wallet/topup/',
      data: {
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_signature': razorpaySignature,
        'amount': amount,
      },
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
