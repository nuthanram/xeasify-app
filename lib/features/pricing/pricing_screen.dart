import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/accounts_repository.dart';
import '../../widgets/xb_metric_tile.dart';
import '../../widgets/xb_error.dart';
import '../../widgets/xb_loader.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _State();
}

class _State extends ConsumerState<PricingScreen> {
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  bool _loading = false;
  bool _loadingMe = true;
  String? _error;
  Map<String, dynamic>? _me;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMe() async {
    try {
      final data = await ref.read(accountsRepoProvider).getMe();
      if (mounted) {
        setState(() {
          _me = data;
          _loadingMe = false;
          _minCtrl.text = data['price_min']?.toString() ?? '';
          _maxCtrl.text = data['price_max']?.toString() ?? '';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMe = false);
    }
  }

  Future<void> _update() async {
    final min = double.tryParse(_minCtrl.text.trim());
    final max = double.tryParse(_maxCtrl.text.trim());
    if (min == null || max == null) {
      setState(() => _error = 'Enter valid numeric prices.');
      return;
    }
    if (max < min) {
      setState(() => _error = 'Max price must be >= min price.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(accountsRepoProvider).updatePricing(
            _minCtrl.text.trim(),
            _maxCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pricing updated successfully.')));
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Update failed. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingMe) return Scaffold(appBar: AppBar(title: const Text('LIVE PRICING')), body: const XbLoader());

    return Scaffold(
      appBar: AppBar(title: const Text('LIVE PRICING')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CREATOR PRICING',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Changes take effect immediately. Historical invoices are unaffected.',
              style: TextStyle(
                  fontSize: 12, fontStyle: FontStyle.italic, height: 1.5),
            ),
            const SizedBox(height: 24),
            // Current range tiles
            if (_me != null)
              Row(children: [
                Expanded(
                    child: XbMetricTile(
                  label: 'CURRENT MIN',
                  value: '₹${_me!['price_min'] ?? '—'}',
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: XbMetricTile(
                  label: 'CURRENT MAX',
                  value: '₹${_me!['price_max'] ?? '—'}',
                  inverted: true,
                )),
              ]),
            const SizedBox(height: 28),
            Container(height: 1, color: kFg),
            const SizedBox(height: 24),
            const Text('NEW MIN PRICE',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _minCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              decoration:
                  const InputDecoration(prefixText: '₹ ', hintText: '5000'),
            ),
            const SizedBox(height: 20),
            const Text('NEW MAX PRICE',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _maxCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              decoration:
                  const InputDecoration(prefixText: '₹ ', hintText: '25000'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              XbError(message: _error!),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _update,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kBg))
                  : const Text('UPDATE PRICING'),
            ),
          ],
        ),
      ),
    );
  }
}
