import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/dio_client.dart';

class MerchantDashboardScreen extends ConsumerStatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  ConsumerState<MerchantDashboardScreen> createState() => _State();
}

class _State extends ConsumerState<MerchantDashboardScreen> {
  Map<String, dynamic>? _me;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final res = await ref.read(dioProvider).get('/accounts/me/');
    if (mounted) setState(() => _me = res.data as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DASHBOARD')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kGray900, border: Border.all(color: kGray700), borderRadius: BorderRadius.circular(4)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('WALLET', style: TextStyle(color: kGray400, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text('₹${_me?['wallet_balance'] ?? '—'}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.go('/merchant/campaigns/new'), child: const Text('+ NEW CAMPAIGN')),
          ],
        ),
      ),
    );
  }
}
