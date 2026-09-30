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
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).login(_emailCtrl.text.trim(), _passwordCtrl.text);
      final role = ref.read(authProvider).role;
      if (mounted) {
        context.go(role == 'merchant' ? '/merchant' : '/marketplace');
      }
    } catch (_) {
      setState(() => _error = 'Invalid email or password.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Text('XEASIFY', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text('B2B Influencer Marketplace', style: TextStyle(color: kGray400, fontSize: 13)),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'EMAIL'),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'PASSWORD'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Password required' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: kGray700), borderRadius: BorderRadius.circular(4)),
                    child: Text(_error!, style: TextStyle(color: kGray400, fontSize: 12)),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: kBlack))
                      : const Text('SIGN IN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
