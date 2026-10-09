import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xeasify_app/features/auth/meta_sign_in.dart';

ClassicToken _classic(String token) => ClassicToken(
      declinedPermissions: const [],
      grantedPermissions: const [],
      userId: '42',
      expires: DateTime(2030),
      tokenString: token,
      applicationId: 'app',
    );

void main() {
  test('Instagram asks for what the backend metrics grant reads', () async {
    List<String>? asked;
    final token = await MetaSignIn.accessToken('instagram', login: (p) async {
      asked = p;
      return LoginResult(status: LoginStatus.success, accessToken: _classic('EAA-ig'));
    });
    expect(token, 'EAA-ig');
    expect(asked, containsAll(['pages_show_list', 'instagram_basic', 'instagram_manage_insights']));
  });

  test('Facebook asks for pages access and email', () async {
    List<String>? asked;
    await MetaSignIn.accessToken('facebook', login: (p) async {
      asked = p;
      return LoginResult(status: LoginStatus.success, accessToken: _classic('EAA-fb'));
    });
    expect(asked, containsAll(['email', 'pages_show_list', 'pages_read_engagement']));
  });

  test('cancelling returns null (no error shown)', () async {
    final token = await MetaSignIn.accessToken('facebook',
        login: (_) async => LoginResult(status: LoginStatus.cancelled));
    expect(token, isNull);
  });

  test('a failed login surfaces the SDK message', () async {
    expect(
      () => MetaSignIn.accessToken('instagram',
          login: (_) async => LoginResult(status: LoginStatus.failed, message: 'Invalid key hash')),
      throwsA(isA<MetaSignInException>()
          .having((e) => e.message, 'message', contains('Invalid key hash'))),
    );
  });

  test('a limited-login token is refused: the backend needs a classic token', () async {
    final limited = LimitedToken(
      userId: '42',
      userName: 'n',
      userEmail: null,
      nonce: 'x',
      tokenString: 'eyJhbGciOi.limited.jwt',
    );
    expect(
      () => MetaSignIn.accessToken('facebook',
          login: (_) async => LoginResult(status: LoginStatus.success, accessToken: limited)),
      throwsA(isA<MetaSignInException>()),
    );
  });

  test('without FACEBOOK_APP_ID the SDK is never called', () async {
    // Tests run without --dart-define, so this build is unconfigured.
    expect(MetaSignIn.isConfigured, isFalse);
    expect(() => MetaSignIn.accessToken('instagram'), throwsA(isA<MetaSignInException>()));
  });

  test('unknown providers are rejected', () {
    expect(() => MetaSignIn.accessToken('myspace', login: (_) async => LoginResult(status: LoginStatus.cancelled)),
        throwsA(isA<MetaSignInException>()));
  });
}
