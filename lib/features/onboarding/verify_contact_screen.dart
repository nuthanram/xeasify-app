import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/accounts_repository.dart';
import '../auth/auth_provider.dart';

/// Creator onboarding step 3: verify a contact email (link sent by the backend) and a
/// phone number. Phone verification needs Firebase Phone Auth, which is not wired yet.
class VerifyContactScreen extends ConsumerStatefulWidget {
  const VerifyContactScreen({super.key});

  @override
  ConsumerState<VerifyContactScreen> createState() => _VerifyContactScreenState();
}

class _VerifyContactScreenState extends ConsumerState<VerifyContactScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = true;
  bool _sending = false;
  bool _emailVerified = false;
  bool _phoneVerified = false;
  String? _sentTo;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  /// Re-reads the creator's flags from /accounts/me/ and syncs signup_state.
  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final me = await ref.read(accountsRepoProvider).getMe();
      final signupState = me['signup_state'] as String?;
      if (signupState != null) {
        await ref.read(authProvider.notifier).updateSignupState(signupState);
      }
      if (!mounted) return;
      if (signupState == 'verified') {
        context.go('/marketplace');
        return;
      }
      setState(() {
        _emailVerified = me['contact_email_verified'] == true;
        _phoneVerified = me['phone_verified'] == true;
        if (_emailCtrl.text.isEmpty) _emailCtrl.text = (me['email'] as String?) ?? '';
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load your verification status.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendLink() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(accountsRepoProvider).startEmailVerification(email);
      if (mounted) setState(() => _sentTo = email);
    } on DioException catch (e) {
      final data = e.response?.data;
      setState(() => _error = data is Map && data['error'] != null
          ? '${data['error']}'
          : 'Could not send the link (${e.response?.statusCode ?? 'network error'}).');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VERIFY CONTACT DETAILS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/marketplace'),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: kFg))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'STEP 3 OF 3',
                      style: TextStyle(fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Brands contact you through a verified email and phone number. '
                      'Both are needed before you can apply to campaigns.',
                      style: TextStyle(fontSize: 12, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    Container(height: 1, color: kFg),
                    const SizedBox(height: 24),
                    _sectionTitle('EMAIL', _emailVerified),
                    const SizedBox(height: 12),
                    if (!_emailVerified) ..._emailForm(),
                    const SizedBox(height: 32),
                    _sectionTitle('PHONE', _phoneVerified),
                    const SizedBox(height: 12),
                    if (!_phoneVerified)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(border: Border.all(color: kFg.withValues(alpha: 0.3))),
                        child: const Text(
                          'Phone verification is not available in the app yet. '
                          'It needs SMS sign-in through Firebase, which is still being set up.',
                          style: TextStyle(fontSize: 11, height: 1.6),
                        ),
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(border: Border.all(color: kFg, width: 1)),
                        child: Text('⚠ $_error',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(String label, bool verified) => Row(children: [
        Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 2.5, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(verified ? 'VERIFIED ✓' : 'NOT VERIFIED',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              color: verified ? kFg : kFg.withValues(alpha: 0.5),
            )),
      ]);

  List<Widget> _emailForm() => [
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: kFg, fontSize: 14),
          decoration: const InputDecoration(labelText: 'CONTACT EMAIL'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _sending ? null : _sendLink,
          child: _sending
              ? const SizedBox(
                  height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kBg))
              : Text(_sentTo == null ? 'SEND VERIFICATION LINK' : 'SEND AGAIN'),
        ),
        if (_sentTo != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: kFg, width: 1)),
            child: Text(
              'Link sent to $_sentTo. Open it within 24 hours, then tap I\'VE OPENED THE LINK.',
              style: const TextStyle(fontSize: 11, height: 1.6),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _refresh, child: const Text('I\'VE OPENED THE LINK')),
        ],
      ];
}
