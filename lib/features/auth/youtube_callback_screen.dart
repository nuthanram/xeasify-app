import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import 'auth_provider.dart';
import 'youtube_web_sign_in.dart';

/// Landing page of the web YouTube sign-in redirect (see [YouTubeWebSignIn]).
class YouTubeCallbackScreen extends ConsumerStatefulWidget {
  final String? code;
  final String? state;
  final String? error;

  const YouTubeCallbackScreen({super.key, this.code, this.state, this.error});

  @override
  ConsumerState<YouTubeCallbackScreen> createState() => _YouTubeCallbackScreenState();
}

class _YouTubeCallbackScreenState extends ConsumerState<YouTubeCallbackScreen> {
  String? _failure;

  @override
  void initState() {
    super.initState();
    _finish();
  }

  Future<void> _finish() async {
    if (widget.error != null) {
      // e.g. access_denied when the user cancels on Google's consent screen
      return _fail(widget.error == 'access_denied'
          ? 'YouTube sign-in was cancelled.'
          : 'Google returned an error: ${widget.error}');
    }
    if (!await YouTubeWebSignIn.takePendingState(widget.state)) {
      return _fail('This sign-in link was not started in this browser or was already used. '
          'Start again from JOIN AS CREATOR.');
    }
    if (widget.code == null) return _fail('Google did not return an authorization code.');
    try {
      await ref.read(authProvider.notifier).youtubeCodeLogin(
            code: widget.code!,
            redirectUri: YouTubeWebSignIn.redirectUri(),
            state: widget.state!,
          );
      if (mounted) context.go('/marketplace');
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map && data['error'] != null ? '${data['error']}' : null;
      _fail(message ?? 'Sign-in failed (${e.response?.statusCode ?? 'network error'}).');
    } catch (_) {
      _fail('Sign-in failed. Please try again.');
    }
  }

  void _fail(String message) {
    if (mounted) setState(() => _failure = message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: _failure == null
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(strokeWidth: 2, color: kFg),
                      SizedBox(height: 16),
                      Text('SIGNING IN WITH YOUTUBE…',
                          style: TextStyle(fontSize: 11, letterSpacing: 2)),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(border: Border.all(color: kFg, width: 1)),
                        child: Text('⚠ $_failure',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.go('/register/creator'),
                        child: const Text('BACK'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
