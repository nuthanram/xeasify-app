import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/escrow_repository.dart';
import '../../widgets/xb_error.dart';

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

  @override
  void dispose() {
    _ledgerCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_ledgerCtrl.text.trim().isEmpty || _urlCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Both ledger ID and content URL are required.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ref
          .read(escrowRepoProvider)
          .submitDeliverable(_ledgerCtrl.text.trim(), _urlCtrl.text.trim());
      if (mounted) setState(() => _result = data);
    } catch (_) {
      if (mounted)
        setState(() => _error = 'Submission failed. Verify ledger ID and URL.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatExpiry(String? raw) {
    if (raw == null) return 'unknown';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Success state
    if (_result != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('SUBMITTED')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: kWhite,
                    border: Border.all(color: kWhite, width: 1)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DELIVERABLE SUBMITTED',
                        style: TextStyle(
                            color: kBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Awaiting verification',
                        style: TextStyle(
                            color: kBlack, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ]),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border.all(color: kWhite, width: 1)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '48H VERIFICATION WINDOW',
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'The merchant has 48 hours to verify your content. Once the window closes, funds are automatically released to your wallet.',
                        style: TextStyle(
                            fontSize: 12, height: 1.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'COOLING EXPIRES',
                        style: const TextStyle(
                            fontSize: 9,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatExpiry(
                            _result!['cooling_expires_at'] as String?),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('SUBMIT DELIVERABLE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTENT SUBMISSION',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            const Text(
              'Submit your live content link for verification',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 32),
            Container(height: 1, color: kWhite),
            const SizedBox(height: 24),
            // Ledger ID
            const Text('ESCROW LEDGER ID',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _ledgerCtrl,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                  hintText: 'UUID from your accepted proposal'),
            ),
            const SizedBox(height: 20),
            // Content URL
            const Text('CONTENT URL',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _urlCtrl,
              keyboardType: TextInputType.url,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                  hintText: 'https://www.instagram.com/reel/...'),
            ),
            const SizedBox(height: 16),
            // Note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  border: Border.all(color: kWhite, width: 1)),
              child: const Text(
                'Your content must be live and publicly accessible. The merchant has 48 hours to verify.',
                style: TextStyle(fontSize: 11, height: 1.6),
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
                          strokeWidth: 2, color: kBlack))
                  : const Text('SUBMIT DELIVERABLE'),
            ),
          ],
        ),
      ),
    );
  }
}
