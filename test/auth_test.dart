import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xeasify_app/features/auth/auth_repository.dart';
import 'package:xeasify_app/features/auth/youtube_web_sign_in.dart';

/// Answers requests from a fixed table instead of the network and records them.
class _FakeBackend implements HttpClientAdapter {
  final Map<String, Object> routes;
  final List<RequestOptions> seen = [];

  _FakeBackend(this.routes);

  @override
  Future<ResponseBody> fetch(
      RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    seen.add(options);
    final body = routes['${options.method} ${options.path}'];
    if (body == null) return ResponseBody.fromString('{"detail":"not found"}', 404);
    return ResponseBody.fromString(jsonEncode(body), 200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }

  @override
  void close({bool force = false}) {}
}

String _jwt(Map<String, Object> claims) {
  String part(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part(claims)}.sig';
}

AuthRepository _repo(_FakeBackend backend) =>
    AuthRepository(Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))..httpClientAdapter = backend);

void main() {
  group('password login', () {
    test('takes the role from /accounts/me/, because the JWT carries none', () async {
      final access = _jwt({'user_id': 'u-1', 'token_type': 'access'});
      final backend = _FakeBackend({
        'POST /auth/token/': {'access': access, 'refresh': 'r-1'},
        'GET /accounts/me/': {'id': 'u-1', 'email': 'm@shop.in', 'role': 'merchant'},
      });

      final result = await _repo(backend).login('m@shop.in', 'pw');

      expect(result['role'], 'merchant');
      expect(result['user_id'], 'u-1');
      expect(result['refresh'], 'r-1');
      final meCall = backend.seen.firstWhere((o) => o.path == '/accounts/me/');
      expect(meCall.headers['Authorization'], 'Bearer $access');
    });

    test('carries a creator\'s signup state', () async {
      final backend = _FakeBackend({
        'POST /auth/token/': {'access': _jwt({'user_id': 'c-1'}), 'refresh': 'r'},
        'GET /accounts/me/': {'id': 'c-1', 'role': 'creator', 'signup_state': 'metrics_granted'},
      });
      final result = await _repo(backend).login('c@x.in', 'pw');
      expect(result['role'], 'creator');
      expect(result['signup_state'], 'metrics_granted');
    });
  });

  group('YouTube web sign-in', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('callback URL is this origin + /oauth/youtube', () {
      expect(YouTubeWebSignIn.redirectUri(Uri.parse('http://localhost:5000/register/creator?x=1')),
          'http://localhost:5000/oauth/youtube');
    });

    test('code login posts code, redirect and state and returns the JWT pair', () async {
      final backend = _FakeBackend({
        'POST /accounts/auth/youtube/': {
          'access': _jwt({'user_id': 'c-9'}),
          'refresh': 'r-9',
          'user_id': 'c-9',
          'role': 'creator',
          'signup_state': 'social_linked',
        },
      });
      final result = await _repo(backend).youtubeCodeLogin(
          code: '4/abc', redirectUri: 'http://localhost:5000/oauth/youtube', state: 's1');
      expect(result['user_id'], 'c-9');
      expect(result['signup_state'], 'social_linked');
      expect(backend.seen.single.data,
          {'code': '4/abc', 'redirect_uri': 'http://localhost:5000/oauth/youtube', 'state': 's1'});
    });

    test('a returned state must match the one this browser stored, once', () async {
      SharedPreferences.setMockInitialValues({'youtube_oauth_pending_state': 'signed-state'});
      expect(await YouTubeWebSignIn.takePendingState('signed-state'), isTrue);
      expect(await YouTubeWebSignIn.takePendingState('signed-state'), isFalse); // used up
    });

    test('a state this browser never issued is refused', () async {
      SharedPreferences.setMockInitialValues({'youtube_oauth_pending_state': 'mine'});
      expect(await YouTubeWebSignIn.takePendingState('someone-elses'), isFalse);
      SharedPreferences.setMockInitialValues({});
      expect(await YouTubeWebSignIn.takePendingState('anything'), isFalse);
      expect(await YouTubeWebSignIn.takePendingState(null), isFalse);
    });
  });
}
