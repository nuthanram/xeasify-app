import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/dio_client.dart';
import 'dart:math';

class EscrowRepository {
  final Dio _dio;
  EscrowRepository(this._dio);

  Future<Map<String, dynamic>> submitDeliverable(String ledgerId, String submissionUrl) async {
    final idempotencyKey = _generateUuid();
    final res = await _dio.post(
      '/escrow/submit/$ledgerId/',
      data: {'submission_url': submissionUrl},
      options: Options(headers: {'X-Idempotency-Key': idempotencyKey}),
    );
    return res.data as Map<String, dynamic>;
  }

  String _generateUuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()
      ..replaceRange(8, 8, '-')..replaceRange(13, 13, '-')..replaceRange(18, 18, '-')..replaceRange(23, 23, '-');
  }
}

final escrowRepoProvider = Provider<EscrowRepository>(
  (ref) => EscrowRepository(ref.read(dioProvider)),
);
