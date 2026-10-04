import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the app tour was shown and opens it on first use.
/// Tracked per role, so a device used as both creator and merchant sees each tour once.
class TourService {
  static String normalizeRole(String? role) =>
      role == 'merchant' ? 'merchant' : 'creator';

  static String _key(String? role) => 'app_tour_seen_${normalizeRole(role)}';

  static Future<bool> hasSeen(String? role) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(role)) ?? false;
  }

  static Future<void> markSeen(String? role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(role), true);
  }

  /// Opens the tour if this role has not seen it yet. Completes when the tour is closed,
  /// so callers can show other prompts (e.g. the location dialog) afterwards.
  static Future<void> showIfFirstTime(BuildContext context, String? role) async {
    if (await hasSeen(role)) return;
    if (!context.mounted) return;
    await context.push<void>('/tour/${normalizeRole(role)}');
  }
}
