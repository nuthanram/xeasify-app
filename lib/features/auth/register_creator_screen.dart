import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/accounts_repository.dart';

class RegisterCreatorScreen extends ConsumerStatefulWidget {
  const RegisterCreatorScreen({super.key});

  @override
  ConsumerState<RegisterCreatorScreen> createState() =>
      _RegisterCreatorScreenState();
}

class _RegisterCreatorScreenState
    extends ConsumerState<RegisterCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _displayCtrl = TextEditingController();
  String _platform = 'instagram';
  bool _loading = false;
  bool _showPass = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _displayCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(accountsRepoProvider).registerCreator(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            displayName: _displayCtrl.text.trim(),
            primaryPlatform: _platform,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Account created. Sign in to get started.')),
        );
        context.go('/login');
      }
    } catch (_) {
      setState(() => _error = 'Registration failed. Check your details.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _platformBtn(String value, String label) {
    final selected = _platform == value;
    return GestureDetector(
      onTap: () => setState(() => _platform = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? kWhite : kBlack,
          border: Border.all(color: kWhite, width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? kBlack : kWhite,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
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
          child: Form(
            key: _formKey,
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
                  'APPLY TO BRAND CAMPAIGNS',
                  style: TextStyle(fontSize: 11, letterSpacing: 2),
                ),
                const SizedBox(height: 32),
                Container(height: 1, color: kWhite),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _displayCtrl,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'DISPLAY NAME'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Display name required' : null,
                ),
                const SizedBox(height: 16),
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
                  controller: _passCtrl,
                  obscureText: !_showPass,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'PASSWORD',
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _showPass = !_showPass),
                      child: Icon(
                        _showPass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: kWhite,
                        size: 18,
                      ),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 8) ? 'Min 8 characters' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  decoration:
                      const InputDecoration(labelText: 'CONFIRM PASSWORD'),
                  validator: (v) =>
                      v != _passCtrl.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 32),
                const Text(
                  'PRIMARY PLATFORM',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _platformBtn('instagram', 'INSTAGRAM')),
                  const SizedBox(width: 8),
                  Expanded(child: _platformBtn('youtube', 'YOUTUBE')),
                  const SizedBox(width: 8),
                  Expanded(child: _platformBtn('both', 'BOTH')),
                ]),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        border: Border.all(color: kWhite, width: 1)),
                    child: Text('⚠ $_error',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kBlack))
                      : const Text('CREATE CREATOR ACCOUNT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
