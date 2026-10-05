import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'auth_provider.dart';
import 'youtube_web_sign_in.dart';

// ── Platform descriptors ────────────────────────────────────────────────────
class _Platform {
  final String id;
  final String label;
  final String sublabel;
  final IconData icon;
  // TODO: when adding native SDK packages, implement this per platform:
  //   instagram → flutter_facebook_auth (instagram permissions)
  //   facebook  → flutter_facebook_auth
  //   youtube   → google_sign_in (youtube.readonly scope)
  //   tiktok    → tiktok_flutter_auth or webview-based flow
  const _Platform(this.id, this.label, this.sublabel, this.icon);
}

const _platforms = [
  _Platform('instagram', 'INSTAGRAM', 'Instagram Creator / Business account', Icons.camera_alt_outlined),
  _Platform('facebook', 'FACEBOOK', 'Facebook Page or Creator account', Icons.facebook_outlined),
  _Platform('tiktok', 'TIKTOK', 'TikTok Creator account', Icons.music_note_outlined),
  _Platform('youtube', 'YOUTUBE', 'YouTube Channel (Google account)', Icons.play_circle_outline),
];

// ── Screen ──────────────────────────────────────────────────────────────────
class RegisterCreatorScreen extends ConsumerStatefulWidget {
  const RegisterCreatorScreen({super.key});

  @override
  ConsumerState<RegisterCreatorScreen> createState() =>
      _RegisterCreatorScreenState();
}

class _RegisterCreatorScreenState extends ConsumerState<RegisterCreatorScreen> {
  String? _loadingPlatform;
  String? _error;

  Future<void> _socialLogin(String provider) async {
    setState(() {
      _loadingPlatform = provider;
      _error = null;
    });
    try {
      // Step 1: Obtain access token from the native social SDK.
      //
      // Each platform needs its own package wired up in pubspec.yaml.
      // Replace each TODO block below with the real SDK call.
      final String? accessToken = await _acquirePlatformToken(provider);
      if (accessToken == null) {
        // User cancelled the OAuth flow — silent exit.
        return;
      }

      // Step 2: Exchange token with Xeasify backend (POST /accounts/auth/social/).
      // On success the backend returns JWT pair + signup_state.
      await ref.read(authProvider.notifier).socialLogin(provider, accessToken);

      if (!mounted) return;

      // Step 3: Navigate. signup_state may be SOCIAL_LINKED (needs metrics grant)
      // or VERIFIED (full access). Both land in /marketplace for now; the
      // marketplace screen can surface onboarding banners based on signup_state.
      context.go('/marketplace');
    } on SocialAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Sign-up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loadingPlatform = null);
    }
  }

  /// Returns the provider access token obtained from the native SDK,
  /// or null if the user cancelled.
  ///
  /// Throws [SocialAuthException] on SDK errors.
  Future<String?> _acquirePlatformToken(String provider) async {
    switch (provider) {
      case 'instagram':
      case 'facebook':
        // TODO: Add flutter_facebook_auth to pubspec.yaml, then:
        //   final result = await FacebookAuth.instance.login(
        //     permissions: provider == 'instagram'
        //         ? ['instagram_basic', 'pages_show_list']
        //         : ['public_profile', 'email'],
        //   );
        //   if (result.status == LoginStatus.cancelled) return null;
        //   if (result.status != LoginStatus.success) {
        //     throw SocialAuthException('Facebook sign-in failed: ${result.message}');
        //   }
        //   return result.accessToken!.token;
        throw SocialAuthException(
          '${provider[0].toUpperCase()}${provider.substring(1)} sign-in SDK not yet configured.\n'
          'Add flutter_facebook_auth to pubspec.yaml.',
        );

      case 'youtube':
        if (kIsWeb) {
          // Browser: redirect through Google's consent page; YouTubeCallbackScreen
          // finishes the sign-in when Google sends the tab back.
          try {
            await YouTubeWebSignIn.start(ref.read(authRepositoryProvider));
          } on DioException catch (e) {
            final data = e.response?.data;
            throw SocialAuthException(data is Map && data['error'] != null
                ? 'YouTube sign-in unavailable: ${data['error']}'
                : 'Could not reach the server to start YouTube sign-in.');
          }
          return null; // the page is navigating to Google
        }
        // TODO: Add google_sign_in to pubspec.yaml, then:
        //   final googleUser = await GoogleSignIn(
        //     scopes: ['https://www.googleapis.com/auth/youtube.readonly'],
        //   ).signIn();
        //   if (googleUser == null) return null;
        //   final auth = await googleUser.authentication;
        //   return auth.accessToken;
        throw SocialAuthException(
          'YouTube (Google) sign-in SDK not yet configured.\n'
          'Add google_sign_in to pubspec.yaml.',
        );

      case 'tiktok':
        // TODO: Add tiktok_flutter_auth (or implement webview-based OAuth), then:
        //   final result = await TikTokAuth.instance.login(
        //     scopes: ['user.info.basic', 'user.info.stats'],
        //   );
        //   if (result == null) return null;
        //   return result.accessToken;
        throw SocialAuthException(
          'TikTok sign-in SDK not yet configured.\n'
          'Add tiktok_flutter_auth to pubspec.yaml.',
        );

      default:
        throw SocialAuthException('Unknown platform: $provider');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JOIN AS CREATOR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CREATOR',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              const Text(
                'SIGN UP WITH YOUR SOCIAL ACCOUNT',
                style: TextStyle(fontSize: 11, letterSpacing: 2),
              ),
              const SizedBox(height: 32),
              Container(height: 1, color: kFg),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    border: Border.all(color: kFg.withValues(alpha: 0.3), width: 1)),
                child: const Text(
                  'Creators sign up using an existing Instagram, Facebook, TikTok, or YouTube account. '
                  'No separate password is needed — your social identity is your login.',
                  style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.3,
                      height: 1.6,
                      color: kFg),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'CHOOSE YOUR PRIMARY PLATFORM',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ..._platforms.map((p) => _PlatformTile(
                    platform: p,
                    loading: _loadingPlatform == p.id,
                    disabled: _loadingPlatform != null,
                    onTap: () => _socialLogin(p.id),
                  )),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      border: Border.all(color: kFg, width: 1)),
                  child: Text(
                    '⚠ $_error',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Container(height: 1, color: kFg.withValues(alpha: 0.3)),
              const SizedBox(height: 20),
              const Text(
                'Already have an account? Sign in using the same social platform you registered with.',
                style: TextStyle(
                    fontSize: 11, letterSpacing: 0.3, height: 1.6, color: kFg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Platform tile widget ────────────────────────────────────────────────────
class _PlatformTile extends StatelessWidget {
  final _Platform platform;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _PlatformTile({
    required this.platform,
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: AnimatedOpacity(
          opacity: disabled && !loading ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: kBg,
              border: Border.all(color: kFg, width: 1),
            ),
            child: Row(
              children: [
                Icon(platform.icon, color: kFg, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONTINUE WITH ${platform.label}',
                        style: const TextStyle(
                          color: kFg,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        platform.sublabel,
                        style: TextStyle(
                          color: kFg.withValues(alpha: 0.5),
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: kFg),
                  )
                else
                  Icon(Icons.arrow_forward,
                      color: kFg.withValues(alpha: 0.6), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Exception type ──────────────────────────────────────────────────────────
class SocialAuthException implements Exception {
  final String message;
  const SocialAuthException(this.message);
}
