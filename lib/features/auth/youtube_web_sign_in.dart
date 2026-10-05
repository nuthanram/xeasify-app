import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_repository.dart';

/// YouTube creator sign-in in the browser, through the backend's Google
/// authorization-code flow (no Google SDK in the app, no client secret on the device):
///
///   1. [start]: the backend builds the Google consent URL for our callback page and a
///      signed `state`; the app remembers the state and sends the tab to Google.
///   2. Google redirects back to [callbackPath] with `?code=…&state=…`.
///   3. YouTubeCallbackScreen checks the state with [takePendingState] and the backend
///      swaps the code for tokens (POST /accounts/auth/youtube/).
///
/// The callback URL must be listed under "Authorized redirect URIs" of the Google OAuth
/// web client, e.g. http://localhost:5000/oauth/youtube for `flutter run --web-port 5000`.
class YouTubeWebSignIn {
  static const callbackPath = '/oauth/youtube';
  static const _pendingStateKey = 'youtube_oauth_pending_state';

  /// The page Google sends the browser back to: this app's origin + [callbackPath].
  static String redirectUri([Uri? base]) => '${(base ?? Uri.base).origin}$callbackPath';

  static Future<void> start(AuthRepository repo) async {
    final redirect = redirectUri();
    final consent = await repo.youtubeAuthUrl(redirect);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingStateKey, consent.state);
    // Same tab: Google comes back to the callback route of this app.
    await launchUrl(Uri.parse(consent.authUrl), webOnlyWindowName: '_self');
  }

  /// True only if [returned] is the state this browser stored in [start]. The stored
  /// state is cleared either way, so a callback can be used once. This stops someone
  /// from finishing *their* Google sign-in in your browser (login CSRF); the backend
  /// separately checks the state's signature and age.
  static Future<bool> takePendingState(String? returned) async {
    final prefs = await SharedPreferences.getInstance();
    final expected = prefs.getString(_pendingStateKey);
    await prefs.remove(_pendingStateKey);
    return expected != null && returned != null && returned == expected;
  }
}
