import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../core/secure_storage.dart';

const String kBaseUrl =
    String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handler — runs in isolate, minimal work only
}

class FCMService {
  /// Call this at startup. Wraps everything in try-catch so the app works
  /// without a google-services.json / GoogleService-Info.plist in dev builds.
  static Future<void> initializeIfAvailable() async {
    try {
      await initialize();
    } catch (_) {}
  }

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      // Foreground notification handling — post to local notification manager
    });

    // Register token with backend after login
    FirebaseMessaging.instance.onTokenRefresh
        .listen((token) => _registerToken(token));
  }

  static Future<void> registerTokenAfterLogin() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _registerToken(token);
    } catch (_) {}
  }

  static Future<void> _registerToken(String token) async {
    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) return;
    try {
      final dio = Dio(BaseOptions(baseUrl: '$kBaseUrl/api/v1'));
      await dio.patch(
        '/accounts/creator/fcm-token/',
        data: {'fcm_token': token},
        options:
            Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } catch (_) {}
  }
}
