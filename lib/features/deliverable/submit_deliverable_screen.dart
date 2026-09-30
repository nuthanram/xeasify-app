import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/escrow_repository.dart';

class SubmitDeliverableScreen extends ConsumerStatefulWidget {
  const SubmitDeliverableScreen({super.key});

  @override
  ConsumerState<SubmitDeliverableScreen> createState() => _State();
}

class _State extends ConsumerState<SubmitDeliverableScreen> {
  final _ledgerCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  Future<void> _submit() async {
    if (_ledgerCtrl.text.isEmpty || _urlCtrl.text.isEmpty) { setState(() => _error = 'Both fields required'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ref.read(escrowRepoProvider).submitDeliverable(_ledgerCtrl.text.trim(), _urlCtrl.text.trim());
      if (mounted) setState(() => _result = data);
    } catch (_) {
      setState(() => _error = 'Submission failed. Check ledger ID and URL.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) return Scaffold(
      appBar: AppBar(title: const Text('SUBMITTED')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: kGray700), borderRadius: BorderRadius.circular(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Deliverable submitted.', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('48-hour verification window started.', style: TextStyle(color: kGray400, fontSize: 13)),
              Text('Cooling expires: ${_result!['cooling_expires_at']}', style: TextStyle(color: kGray400, fontSize: 12)),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('SUBMIT DELIVERABLE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ESCROW LEDGER ID', style: TextStyle(color: kGray400, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 6),
            TextField(controller: _ledgerCtrl, style: const TextStyle(fontSize: 13), decoration: const InputDecoration(hintText: 'UUID from your accepted proposal')),
            const SizedBox(height: 16),
            Text('CONTENT URL', style: TextStyle(color: kGray400, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 6),
            TextField(controller: _urlCtrl, keyboardType: TextInputType.url, style: const TextStyle(fontSize: 13), decoration: const InputDecoration(hintText: 'https://www.instagram.com/reel/...')),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: kGray700), borderRadius: BorderRadius.circular(4)), child: Text(_error!, style: TextStyle(color: kGray400, fontSize: 12))),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: kBlack)) : const Text('SUBMIT DELIVERABLE'),
            ),
          ],
        ),
      ),
    );
  }
}
