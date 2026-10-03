import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/accounts_repository.dart';

class RegisterMerchantScreen extends ConsumerStatefulWidget {
  const RegisterMerchantScreen({super.key});

  @override
  ConsumerState<RegisterMerchantScreen> createState() =>
      _RegisterMerchantScreenState();
}

class _RegisterMerchantScreenState
    extends ConsumerState<RegisterMerchantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();
  bool _loading = false;
  bool _showPass = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _businessCtrl.dispose();
    _phoneCtrl.dispose();
    _gstinCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(accountsRepoProvider).registerMerchant(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            phone: _phoneCtrl.text.trim(),
            businessName: _businessCtrl.text.trim(),
            gstin: _gstinCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created. Sign in to continue.')),
        );
        context.go('/login');
      }
    } catch (e) {
      setState(() => _error = 'Registration failed. Check your details.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JOIN AS MERCHANT'),
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
                  'MERCHANT',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'CREATE & FUND CAMPAIGNS',
                  style: TextStyle(fontSize: 11, letterSpacing: 2),
                ),
                const SizedBox(height: 32),
                Container(height: 1, color: kWhite),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      border: Border.all(color: kWhite, width: 1)),
                  child: const Text(
                    'GSTIN is optional. With a GSTIN or corporate email you get a Standard account '
                    '(verified badge, full marketplace access). Without one you get a Small '
                    'account (upfront payment, AI-matched creators only).',
                    style: TextStyle(fontSize: 11, letterSpacing: 0.3, height: 1.6),
                  ),
                ),
                const SizedBox(height: 24),
                _field('BUSINESS NAME', _businessCtrl,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Business name required'
                        : null),
                const SizedBox(height: 16),
                _field('EMAIL', _emailCtrl,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || !v.contains('@'))
                            ? 'Valid email required'
                            : null),
                const SizedBox(height: 16),
                _field('PHONE', _phoneCtrl,
                    keyboard: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.length < 10 ? 'Valid phone required' : null),
                const SizedBox(height: 16),
                _field('GSTIN (optional)', _gstinCtrl),
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
                  validator: (v) => (v == null || v.length < 8)
                      ? 'Min 8 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  style: const TextStyle(color: kWhite, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'CONFIRM PASSWORD'),
                  validator: (v) =>
                      v != _passCtrl.text ? 'Passwords do not match' : null,
                ),
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
                      : const Text('CREATE MERCHANT ACCOUNT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType keyboard = TextInputType.text,
      String? Function(String?)? validator}) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(color: kWhite, fontSize: 14),
        decoration: InputDecoration(labelText: label),
        validator: validator,
      );
}
