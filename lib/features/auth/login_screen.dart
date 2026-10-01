import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .login(_emailCtrl.text.trim(), _passwordCtrl.text);
      final role = ref.read(authProvider).role;
      if (mounted) {
        context.go(role == 'merchant' ? '/merchant' : '/marketplace');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Invalid email or password.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 64),
                // Wordmark
                const Text(
                  'XEASIFY',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'B2B INFLUENCER MARKETPLACE',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
                // Divider
                Container(height: 1, color: kWhite),
                const SizedBox(height: 40),
                // Fields
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'EMAIL'),
                  validator: (v) =>
                      (v == null || !v.contains('@'))
                          ? 'Valid email required'
                          : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: !_showPassword,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'PASSWORD',
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _showPassword = !_showPassword),
                      child: Icon(
                        _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: kWhite,
                        size: 18,
                      ),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Password required' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration:
                        BoxDecoration(border: Border.all(color: kWhite, width: 1)),
                    child: Text(
                      '⚠ $_error',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kBlack))
                      : const Text('SIGN IN'),
                ),
                const SizedBox(height: 40),
                // Register links
                Container(height: 1, color: kWhite),
                const SizedBox(height: 24),
                const Text(
                  'NEW HERE?',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.go('/register/creator'),
                  child: const Text('JOIN AS CREATOR'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.go('/register/merchant'),
                  child: const Text('JOIN AS MERCHANT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
