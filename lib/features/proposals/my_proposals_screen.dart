import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/proposals_repository.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/xb_loader.dart';
import '../../widgets/xb_empty.dart';
import '../../widgets/xb_error.dart';

class MyProposalsScreen extends ConsumerStatefulWidget {
  const MyProposalsScreen({super.key});

  @override
  ConsumerState<MyProposalsScreen> createState() => _State();
}

class _State extends ConsumerState<MyProposalsScreen> {
  List<Map<String, dynamic>> _proposals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ref.read(proposalsRepoProvider).getMyProposals();
      if (mounted) setState(() { _proposals = data; _loading = false; });
    } catch (_) {
      if (mounted)
        setState(() { _error = 'Failed to load proposals.'; _loading = false; });
    }
  }

  Future<void> _withdraw(String proposalId) async {
    try {
      await ref.read(proposalsRepoProvider).withdrawProposal(proposalId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proposal withdrawn.')));
        _load();
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to withdraw proposal.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MY PROPOSALS')),
      body: _loading
          ? const XbLoader()
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: XbError(message: _error!))
              : _proposals.isEmpty
                  ? const XbEmpty(message: 'No proposals submitted yet.\nApply to campaigns from the Marketplace.')
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: kWhite,
                      backgroundColor: kBlack,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        itemCount: _proposals.length,
                        itemBuilder: (_, i) => _ProposalCard(
                          proposal: _proposals[i],
                          onNegotiate: () => context.push(
                              '/proposals/${_proposals[i]['id']}/negotiate'),
                          onWithdraw: () => _withdraw(_proposals[i]['id'] as String),
                          onSubmitDeliverable: () =>
                              context.push('/deliverable'),
                        ),
                      ),
                    ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final VoidCallback onNegotiate;
  final VoidCallback onWithdraw;
  final VoidCallback onSubmitDeliverable;

  const _ProposalCard({
    required this.proposal,
    required this.onNegotiate,
    required this.onWithdraw,
    required this.onSubmitDeliverable,
  });

  @override
  Widget build(BuildContext context) {
    final status = proposal['status'] as String? ?? '';
    final bidAmount = double.tryParse(
            proposal['bid_amount']?.toString() ?? '0')
        ?.toStringAsFixed(0) ??
        '0';
    final reach = proposal['forecasted_reach'] as int? ?? 0;
    final roi = double.tryParse(
            proposal['forecasted_roi_index']?.toString() ?? '0')
        ?.toStringAsFixed(2) ??
        '0.00';

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(color: kWhite, width: 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(
              'Campaign ${(proposal['campaign'] as String? ?? '').substring(0, 8).toUpperCase()}...',
              style:
                  const TextStyle(fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600),
            ),
          ),
          StatusChip(status: status),
        ]),
        const SizedBox(height: 12),
        // Pitch excerpt
        Text(
          proposal['pitch'] as String? ?? '',
          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, height: 1.5),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),
        // Metrics row
        Row(children: [
          _MetricItem(label: 'BID', value: '₹$bidAmount'),
          const SizedBox(width: 20),
          _MetricItem(label: 'REACH', value: '$reach'),
          const SizedBox(width: 20),
          _MetricItem(label: 'ROI', value: roi),
        ]),
        // Action buttons
        if (status == 'counter_offered') ...[
          const SizedBox(height: 14),
          Container(height: 1, color: kWhite),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onNegotiate,
              child: const Text('VIEW NEGOTIATION'),
            ),
          ),
        ] else if (status == 'accepted') ...[
          const SizedBox(height: 14),
          Container(height: 1, color: kWhite),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmitDeliverable,
              child: const Text('SUBMIT DELIVERABLE'),
            ),
          ),
        ] else if (status == 'submitted') ...[
          const SizedBox(height: 14),
          Container(height: 1, color: kWhite),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onWithdraw,
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40)),
              child: const Text('WITHDRAW'),
            ),
          ),
        ],
      ]),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 9, letterSpacing: 1.5)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      );
}
