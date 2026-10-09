/// Backend origin, chosen at build time with --dart-define, e.g. against dev in Chrome:
///
///   flutter run -d chrome --web-port 5000 --dart-define=API_BASE_URL=https://api.dev.xeasify.com
///
/// (tool/run_web_dev.ps1 runs exactly that). The default only works from the Android
/// emulator against a backend running on the host machine.
const String kBaseUrl =
    String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

/// Every API endpoint lives under /api/v1.
const String kApiUrl = '$kBaseUrl/api/v1';

/// Meta App ID for Instagram / Facebook sign-in (empty = not configured in this build).
/// Set it with --dart-define-from-file=config/dev.json (see config/dev.example.json);
/// the Android build reads the same value for the native SDK's manifest entries.
const String kFacebookAppId = String.fromEnvironment('FACEBOOK_APP_ID');

/// Firebase app settings for creator phone OTP (Firebase console → Project settings →
/// Your apps → the web app, or the Android app for an Android build). Not secrets: they
/// identify the app to Firebase. Empty = phone verification is off in this build.
const String kFirebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
const String kFirebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
const String kFirebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const String kFirebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
const String kFirebaseAuthDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
