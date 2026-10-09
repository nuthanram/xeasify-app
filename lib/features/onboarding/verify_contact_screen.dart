import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/accounts_repository.dart';
import '../../services/phone_otp.dart';
import '../auth/auth_provider.dart';

/// Creator onboarding step 3: a 6-digit code to the contact email (sent by the backend)
/// and an SMS code to the phone (sent by Firebase). Both are needed for `verified`.
class VerifyContactScreen extends ConsumerStatefulWidget {
  const VerifyContactScreen({super.key});

  @override
  ConsumerState<VerifyContactScreen> createState() => _VerifyContactScreenState();
}

class _VerifyContactScreenState extends ConsumerState<VerifyContactScreen> {
  static const _phoneResendSeconds = 60;

  bool _loading = true;
  String? _loadError;

  bool _emailVerified = false;
  final _emailCtrl = TextEditingController();
  final _emailCodeCtrl = TextEditingController();
  String? _emailSentTo;
  bool _emailBusy = false;
  String? _emailError;
  int _emailResendIn = 0;

  bool _phoneVerified = false;
  final _phoneCtrl = TextEditingController(text: '+91 ');
  final _phoneCodeCtrl = TextEditingController();
  final _otp = PhoneOtp();
  String? _phoneSentTo;
  bool _phoneBusy = false;
  String? _phoneError;
  int _phoneResendIn = 0;

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _load();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_emailResendIn > 0 || _phoneResendIn > 0) {
        setState(() {
          if (_emailResendIn > 0) _emailResendIn--;
          if (_phoneResendIn > 0) _phoneResendIn--;
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    for (final c in [_emailCtrl, _emailCodeCtrl, _phoneCtrl, _phoneCodeCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final me = await ref.read(accountsRepoProvider).getMe();
      if (!mounted) return;
      if (await _applySignupState(me['signup_state'] as String?)) return;
      setState(() {
        _emailVerified = me['contact_email_verified'] == true;
        _phoneVerified = me['phone_verified'] == true;
        if (_emailCtrl.text.isEmpty) _emailCtrl.text = (me['email'] as String?) ?? '';
      });
    } catch (_) {
      if (mounted) setState(() => _loadError = 'Could not load your verification status.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Saves the new state; when the creator is fully verified, leaves for the marketplace.
  Future<bool> _applySignupState(String? signupState) async {
    if (signupState == null) return false;
    await ref.read(authProvider.notifier).updateSignupState(signupState);
    if (signupState != 'verified' || !mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You are verified. Campaigns are open to you.')),
    );
    context.go('/marketplace');
    return true;
  }

  String _apiError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) return '${data['error']}';
    return '$fallback (${e.response?.statusCode ?? 'network error'}).';
  }

  // ── Email ──────────────────────────────────────────────────────────────────

  Future<void> _sendEmailCode() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      setState(() => _emailError = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _emailBusy = true;
      _emailError = null;
    });
    try {
      final res = await ref.read(accountsRepoProvider).startEmailVerification(email);
      setState(() {
        _emailSentTo = email;
        _emailCodeCtrl.clear();
        _emailResendIn = (res['resend_after'] as num?)?.toInt() ?? 60;
      });
    } on DioException catch (e) {
      final retry = (e.response?.data is Map) ? (e.response!.data['retry_after'] as num?)?.toInt() : null;
      setState(() {
        _emailError = _apiError(e, 'Could not send the code');
        if (retry != null) _emailResendIn = retry;
      });
    } finally {
      if (mounted) setState(() => _emailBusy = false);
    }
  }

  Future<void> _confirmEmailCode() async {
    final code = _emailCodeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _emailError = 'Enter the 6-digit code from the email.');
      return;
    }
    setState(() {
      _emailBusy = true;
      _emailError = null;
    });
    try {
      final res = await ref.read(accountsRepoProvider).confirmEmailCode(code);
      if (await _applySignupState(res['signup_state'] as String?)) return;
      setState(() => _emailVerified = true);
    } on DioException catch (e) {
      setState(() => _emailError = _apiError(e, 'Could not check the code'));
    } finally {
      if (mounted) setState(() => _emailBusy = false);
    }
  }

  // ── Phone ──────────────────────────────────────────────────────────────────

  Future<void> _sendPhoneCode() async {
    final phone = PhoneOtp.normalize(_phoneCtrl.text);
    if (phone == null) {
      setState(() => _phoneError = 'Enter your mobile number with the country code, e.g. +91 98123 45678.');
      return;
    }
    setState(() {
      _phoneBusy = true;
      _phoneError = null;
    });
    try {
      await _otp.sendCode(phone);
      setState(() {
        _phoneSentTo = phone;
        _phoneCodeCtrl.clear();
        _phoneResendIn = _phoneResendSeconds;
      });
    } on PhoneOtpException catch (e) {
      setState(() => _phoneError = e.message);
    } catch (_) {
      setState(() => _phoneError = 'Could not send the SMS. Try again.');
    } finally {
      if (mounted) setState(() => _phoneBusy = false);
    }
  }

  Future<void> _confirmPhoneCode() async {
    final code = _phoneCodeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _phoneError = 'Enter the 6-digit code from the SMS.');
      return;
    }
    setState(() {
      _phoneBusy = true;
      _phoneError = null;
    });
    try {
      final idToken = await _otp.confirm(code);
      final res = await ref.read(accountsRepoProvider).verifyPhone(idToken);
      if (await _applySignupState(res['signup_state'] as String?)) return;
      setState(() => _phoneVerified = true);
    } on PhoneOtpException catch (e) {
      setState(() => _phoneError = e.message);
    } on DioException catch (e) {
      setState(() => _phoneError = _apiError(e, 'Could not verify the phone number'));
    } catch (_) {
      setState(() => _phoneError = 'Could not verify the code. Try again.');
    } finally {
      if (mounted) setState(() => _phoneBusy = false);
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

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
                    const Text('STEP 3 OF 3',
                        style: TextStyle(fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text(
                      'Brands reach you through a verified email and mobile number. '
                      'Verify both to start applying to campaigns.',
                      style: TextStyle(fontSize: 12, height: 1.6),
                    ),
                    if (_loadError != null) ...[
                      const SizedBox(height: 16),
                      _errorBox(_loadError!),
                      const SizedBox(height: 8),
                      OutlinedButton(onPressed: _load, child: const Text('TRY AGAIN')),
                    ],
                    const SizedBox(height: 24),
                    Container(height: 1, color: kFg),
                    const SizedBox(height: 24),
                    _sectionTitle('EMAIL', _emailVerified),
                    const SizedBox(height: 12),
                    if (!_emailVerified) ..._emailSection(),
                    const SizedBox(height: 32),
                    _sectionTitle('MOBILE NUMBER', _phoneVerified),
                    const SizedBox(height: 12),
                    if (!_phoneVerified) ..._phoneSection(),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _emailSection() => [
        TextField(
          controller: _emailCtrl,
          enabled: _emailSentTo == null,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: kFg, fontSize: 14),
          decoration: const InputDecoration(labelText: 'CONTACT EMAIL'),
        ),
        const SizedBox(height: 16),
        if (_emailSentTo == null)
          _primaryButton('SEND CODE', _emailBusy ? null : _sendEmailCode, _emailBusy)
        else ...[
          _note('We emailed a 6-digit code to $_emailSentTo. It expires in 10 minutes. '
              'Check your spam folder if it doesn\'t arrive.'),
          const SizedBox(height: 12),
          _codeField(_emailCodeCtrl, 'EMAIL CODE'),
          const SizedBox(height: 16),
          _primaryButton('VERIFY EMAIL', _emailBusy ? null : _confirmEmailCode, _emailBusy),
          _resendRow(
            secondsLeft: _emailResendIn,
            onResend: _emailBusy ? null : _sendEmailCode,
            onChange: () => setState(() {
              _emailSentTo = null;
              _emailError = null;
            }),
            changeLabel: 'CHANGE EMAIL',
          ),
        ],
        if (_emailError != null) ...[const SizedBox(height: 12), _errorBox(_emailError!)],
      ];

  List<Widget> _phoneSection() {
    if (!PhoneOtp.isConfigured) {
      return [
        _note('Phone verification is not set up in this build yet: the Firebase settings '
            '(FIREBASE_* in config/dev.json) are missing.'),
      ];
    }
    return [
      TextField(
        controller: _phoneCtrl,
        enabled: _phoneSentTo == null,
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: kFg, fontSize: 14),
        decoration: const InputDecoration(labelText: 'MOBILE NUMBER (WITH COUNTRY CODE)'),
      ),
      const SizedBox(height: 16),
      if (_phoneSentTo == null)
        _primaryButton('SEND SMS CODE', _phoneBusy ? null : _sendPhoneCode, _phoneBusy)
      else ...[
        _note('We sent a 6-digit code by SMS to $_phoneSentTo.'),
        const SizedBox(height: 12),
        _codeField(_phoneCodeCtrl, 'SMS CODE'),
        const SizedBox(height: 16),
        _primaryButton('VERIFY MOBILE NUMBER', _phoneBusy ? null : _confirmPhoneCode, _phoneBusy),
        _resendRow(
          secondsLeft: _phoneResendIn,
          onResend: _phoneBusy ? null : _sendPhoneCode,
          onChange: () => setState(() {
            _phoneSentTo = null;
            _phoneError = null;
          }),
          changeLabel: 'CHANGE NUMBER',
        ),
      ],
      if (_phoneError != null) ...[const SizedBox(height: 12), _errorBox(_phoneError!)],
    ];
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

  Widget _codeField(TextEditingController ctrl, String label) => TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: kFg, fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.w700),
        decoration: InputDecoration(labelText: label, counterText: ''),
      );

  Widget _primaryButton(String label, VoidCallback? onPressed, bool busy) => ElevatedButton(
        onPressed: onPressed,
        child: busy
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kBg))
            : Text(label),
      );

  Widget _resendRow({
    required int secondsLeft,
    required VoidCallback? onResend,
    required VoidCallback onChange,
    required String changeLabel,
  }) =>
      Row(children: [
        TextButton(
          onPressed: secondsLeft > 0 ? null : onResend,
          child: Text(secondsLeft > 0 ? 'SEND AGAIN IN ${secondsLeft}s' : 'SEND AGAIN'),
        ),
        const Spacer(),
        TextButton(onPressed: onChange, child: Text(changeLabel)),
      ]);

  Widget _note(String text) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: kFg.withValues(alpha: 0.3))),
        child: Text(text, style: const TextStyle(fontSize: 11, height: 1.6)),
      );

  Widget _errorBox(String text) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: kFg, width: 1)),
        child: Text('⚠ $text', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
}
