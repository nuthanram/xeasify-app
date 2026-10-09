import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../core/config.dart';

/// Creator sign-in with Instagram or Facebook through Meta's SDK (flutter_facebook_auth):
/// native Facebook Login on Android, Meta's JavaScript SDK on the web.
///
/// Instagram sign-in *is* Facebook Login with the Instagram permissions: the backend
/// validates the Facebook user token (debug_token, issued for our app), then the
/// metrics grant resolves the Instagram business account through the user's Pages.
///
/// Needs the Meta App ID (and on Android the client token) at build time, see
/// config/dev.example.json; without it [isConfigured] is false and no SDK call is made.
class MetaSignIn {
  /// What the backend's metrics grant reads for each provider
  /// (apps/accounts/views.py: _probe_instagram_graph / _probe_facebook).
  static const permissions = {
    'instagram': [
      'public_profile',
      'pages_show_list',
      'pages_read_engagement',
      'instagram_basic',
      'instagram_manage_insights',
    ],
    'facebook': ['public_profile', 'email', 'pages_show_list', 'pages_read_engagement'],
  };

  /// Graph API version the backend calls; the web SDK is pinned to the same one.
  static const graphVersion = 'v19.0';

  static bool get isConfigured => kFacebookAppId.isNotEmpty;

  /// Runs the Meta login for [provider] ("instagram" | "facebook") and returns the user
  /// access token for POST /accounts/auth/social/, or null if the user cancelled.
  /// [login] is injectable for tests; it defaults to the real SDK.
  static Future<String?> accessToken(
    String provider, {
    Future<LoginResult> Function(List<String> permissions)? login,
  }) async {
    final wanted = permissions[provider];
    if (wanted == null) throw MetaSignInException('Unknown Meta provider: $provider');
    if (login == null && !isConfigured) {
      throw const MetaSignInException(
          'Instagram / Facebook sign-in is not configured in this build (no FACEBOOK_APP_ID).');
    }
    final result = await (login ?? _sdkLogin)(wanted);

    switch (result.status) {
      case LoginStatus.cancelled:
        return null;
      case LoginStatus.operationInProgress:
        throw const MetaSignInException('A Facebook sign-in is already in progress.');
      case LoginStatus.failed:
        throw MetaSignInException('Facebook sign-in failed: ${result.message ?? 'unknown error'}');
      case LoginStatus.success:
        final token = result.accessToken;
        if (token == null || token.tokenString.isEmpty) {
          throw const MetaSignInException('Facebook did not return an access token.');
        }
        // A "limited login" token (iOS without tracking consent) is an OpenID token the
        // Graph API rejects; the backend needs the classic user access token.
        if (token.type != AccessTokenType.classic) {
          throw const MetaSignInException(
              'Facebook returned a limited-login token. Allow tracking for this app and try again.');
        }
        return token.tokenString;
    }
  }

  static Future<LoginResult> _sdkLogin(List<String> wanted) async {
    if (kIsWeb && !FacebookAuth.i.isWebSdkInitialized) {
      await FacebookAuth.i.webAndDesktopInitialize(
        appId: kFacebookAppId,
        cookie: false,
        xfbml: false,
        version: graphVersion,
      );
    }
    return FacebookAuth.i.login(
      permissions: wanted,
      // Classic user token on every platform (limited login only exists on iOS).
      loginTracking: LoginTracking.enabled,
    );
  }
}

class MetaSignInException implements Exception {
  final String message;
  const MetaSignInException(this.message);

  @override
  String toString() => message;
}
