import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/proposals_repository.dart';
import '../../widgets/status_chip.dart';

class MyProposalsScreen extends ConsumerStatefulWidget {
  const MyProposalsScreen({super.key});

  @override
  ConsumerState<MyProposalsScreen> createState() => _State();
}

class _State extends ConsumerState<MyProposalsScreen> {
  List<Map<String, dynamic>> _proposals = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await ref.read(proposalsRepoProvider).getMyProposals();
    if (mounted) setState(() { _proposals = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MY PROPOSALS')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kWhite, strokeWidth: 2))
          : _proposals.isEmpty
              ? Center(child: Text('No proposals submitted yet.', style: TextStyle(color: kGray400, fontSize: 13)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _proposals.length,
                  itemBuilder: (_, i) {
                    final p = _proposals[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: kGray900, border: Border.all(color: kGray700), borderRadius: BorderRadius.circular(4)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text('Campaign: ${p['campaign']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                              StatusChip(status: p['status'] ?? ''),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Bid: ₹${p['bid_amount']}', style: TextStyle(color: kGray300, fontSize: 12)),
                          if (p['status'] == 'counter_offered')
                            TextButton(
                              onPressed: () => context.go('/proposals/${p['id']}/negotiate'),
                              child: const Text('VIEW NEGOTIATION', style: TextStyle(color: kWhite, fontSize: 11, letterSpacing: 0.8)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
