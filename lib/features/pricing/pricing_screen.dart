import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/theme.dart';
import '../../core/dio_client.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _State();
}

class _State extends ConsumerState<PricingScreen> {
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  bool _loading = false;
  bool _success = false;
  String? _error;

  Future<void> _update() async {
    final min = double.tryParse(_minCtrl.text);
    final max = double.tryParse(_maxCtrl.text);
    if (min == null || max == null || max < min) { setState(() => _error = 'Invalid price range'); return; }
    setState(() { _loading = true; _error = null; _success = false; });
    try {
      await ref.read(dioProvider).patch('/accounts/creator/pricing/', data: {'price_min': _minCtrl.text, 'price_max': _maxCtrl.text});
      if (mounted) setState(() => _success = true);
    } catch (_) {
      setState(() => _error = 'Update failed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LIVE PRICING')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Changes take effect immediately. Historical invoices are unaffected.', style: TextStyle(color: kGray400, fontSize: 12)),
            const SizedBox(height: 24),
            Text('MIN PRICE (₹)', style: TextStyle(color: kGray400, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 6),
            TextField(controller: _minCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            Text('MAX PRICE (₹)', style: TextStyle(color: kGray400, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 6),
            TextField(controller: _maxCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 14)),
            if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: TextStyle(color: kGray400, fontSize: 12))],
            if (_success) ...[const SizedBox(height: 12), const Text('Pricing updated. Cache invalidated.', style: TextStyle(fontSize: 12))],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _update,
              child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: kBlack)) : const Text('UPDATE PRICING'),
            ),
          ],
        ),
      ),
    );
  }
}
