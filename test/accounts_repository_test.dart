import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xeasify_app/data/accounts_repository.dart';

class _FakeBackend implements HttpClientAdapter {
  final Map<String, Object> routes;
  final List<RequestOptions> seen = [];

  _FakeBackend(this.routes);

  @override
  Future<ResponseBody> fetch(
      RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    seen.add(options);
    final body = routes['${options.method} ${options.path}'];
    if (body == null) return ResponseBody.fromString('{"error":"not found"}', 404);
    return ResponseBody.fromString(jsonEncode(body), 200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }

  @override
  void close({bool force = false}) {}
}

AccountsRepository _repo(_FakeBackend backend) =>
    AccountsRepository(Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))..httpClientAdapter = backend);

void main() {
  test('grantMetricsAccess posts with no body and returns the new signup state', () async {
    final backend = _FakeBackend({
      'POST /accounts/creator/grant-metrics/': {'status': 'metrics_granted', 'signup_state': 'metrics_granted'},
    });
    final result = await _repo(backend).grantMetricsAccess();
    expect(result['signup_state'], 'metrics_granted');
    expect(backend.seen.single.data, isNull);
  });

  test('startEmailVerification posts the address to the initiate endpoint', () async {
    final backend = _FakeBackend({
      'POST /accounts/creator/verify-email/initiate/': {'status': 'verification_email_sent'},
    });
    await _repo(backend).startEmailVerification('me@creator.in');
    expect(backend.seen.single.path, '/accounts/creator/verify-email/initiate/');
    expect(backend.seen.single.data, {'email': 'me@creator.in'});
  });
}
