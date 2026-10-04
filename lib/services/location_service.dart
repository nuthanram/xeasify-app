import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/secure_storage.dart';

const String kBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

class LocationService {
  static Future<void> checkInIfPermitted() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      await _postCheckin(position.latitude, position.longitude);
    } catch (_) {}
  }

  static const _promptedKey = 'location_prompt_shown';

  /// True only if the user was never asked and the OS permission is still undecided.
  static Future<bool> needsPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_promptedKey) ?? false) return false;
    return await Geolocator.checkPermission() == LocationPermission.denied;
  }

  static Future<void> markPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promptedKey, true);
  }

  static Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  static Future<void> _postCheckin(double lat, double lng) async {
    final token = await SecureStorage.getAccessToken();
    if (token == null) return;
    try {
      final dio = Dio(BaseOptions(baseUrl: '$kBaseUrl/api/v1'));
      await dio.post(
        '/geo/checkin/',
        data: {'latitude': lat, 'longitude': lng},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (_) {}
  }
}
