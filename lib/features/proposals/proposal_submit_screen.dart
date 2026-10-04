import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/proposals_repository.dart';
import '../../data/campaigns_repository.dart';
import '../../widgets/xb_error.dart';
import '../../widgets/xb_metric_tile.dart';

class ProposalSubmitScreen extends ConsumerStatefulWidget {
  final String campaignId;
  const ProposalSubmitScreen({super.key, required this.campaignId});

  @override
  ConsumerState<ProposalSubmitScreen> createState() => _State();
}

class _State extends ConsumerState<ProposalSubmitScreen> {
  final _pitchCtrl = TextEditingController();
  final _bidCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _campaign;

  @override
  void initState() {
    super.initState();
    _loadCampaign();
  }

  @override
  void dispose() {
    _pitchCtrl.dispose();
    _bidCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCampaign() async {
    try {
      final data = await ref
          .read(campaignsRepoProvider)
          .getCampaign(widget.campaignId);
      if (mounted) setState(() => _campaign = data);
    } catch (_) {}
  }

  Future<void> _submit() async {
    final pitch = _pitchCtrl.text.trim();
    if (pitch.length < 20) {
      setState(() => _error = 'Pitch must be at least 20 characters.');
      return;
    }
    if (_bidCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Bid amount required.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(proposalsRepoProvider)
          .submitProposal(widget.campaignId, pitch, _bidCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proposal submitted successfully.')));
        context.go('/proposals');
      }
    } catch (_) {
      if (mounted)
        setState(() =>
            _error = 'Submission failed. Verify bid is within your price range.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetPerCreator = _campaign == null
        ? null
        : double.tryParse(
                _campaign!['budget_per_creator']?.toString() ?? '0')
            ?.toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(title: const Text('SUBMIT PROPOSAL')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign budget reference
            if (budgetPerCreator != null) ...[
              XbMetricTile(
                label: 'CAMPAIGN BUDGET PER CREATOR',
                value: '₹$budgetPerCreator',
                inverted: true,
              ),
              const SizedBox(height: 24),
            ],
            // Pitch
            const Text('YOUR PITCH',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _pitchCtrl,
              maxLines: 7,
              maxLength: 1000,
              style: const TextStyle(fontSize: 13, height: 1.6),
              decoration: const InputDecoration(
                hintText:
                    'Describe your content plan and why you are the right fit...',
                counterStyle:
                    TextStyle(color: kFg, fontSize: 10, letterSpacing: 1),
              ),
              onChanged: (_) => setState(() {}),
            ),
            // Character count hint
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_pitchCtrl.text.length} chars · min 20',
                style: const TextStyle(fontSize: 9, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 20),
            // Bid amount
            const Text('BID AMOUNT',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _bidCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: 'Must be within your listed price range',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              XbError(message: _error!),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kBg))
                  : const Text('SUBMIT PROPOSAL'),
            ),
          ],
        ),
      ),
    );
  }
}
