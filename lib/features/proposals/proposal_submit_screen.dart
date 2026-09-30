import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/proposals_repository.dart';

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

  @override
  void dispose() { _pitchCtrl.dispose(); _bidCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_pitchCtrl.text.length < 20) { setState(() => _error = 'Pitch must be at least 20 characters'); return; }
    if (_bidCtrl.text.isEmpty) { setState(() => _error = 'Bid amount required'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(proposalsRepoProvider).submitProposal(widget.campaignId, _pitchCtrl.text.trim(), _bidCtrl.text.trim());
      if (mounted) context.go('/proposals');
    } catch (_) {
      setState(() => _error = 'Submission failed. Check your bid is within your price range.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SUBMIT PROPOSAL')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PITCH', style: TextStyle(color: kGray400, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _pitchCtrl,
              maxLines: 5,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Describe your content plan and why you are the right fit...'),
            ),
            const SizedBox(height: 16),
            Text('BID AMOUNT (₹)', style: TextStyle(color: kGray400, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _bidCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Must be within your listed price range'),
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
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: kBlack))
                  : const Text('SUBMIT PROPOSAL'),
            ),
          ],
        ),
      ),
    );
  }
}
