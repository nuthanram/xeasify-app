import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/dio_client.dart';

class RatingsRepository {
  final Dio _dio;
  RatingsRepository(this._dio);

  /// Merchant submits a 1–5 rating on each dimension after escrow is settled.
  /// [ledgerId] must reference an EscrowLedger in SETTLED state owned by this merchant.
  Future<Map<String, dynamic>> submitRating({
    required String ledgerId,
    required int reliability,
    required int contentQuality,
    required int roiDelivery,
    String feedbackText = '',
  }) async {
    final res = await _dio.post('/ratings/submit/', data: {
      'ledger_id': ledgerId,
      'reliability': reliability,
      'content_quality': contentQuality,
      'roi_delivery': roiDelivery,
      'feedback_text': feedbackText,
    });
    return res.data as Map<String, dynamic>;
  }
}

final ratingsRepoProvider = Provider<RatingsRepository>(
  (ref) => RatingsRepository(ref.read(dioProvider)),
);
