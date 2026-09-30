import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/proposals_repository.dart';

class NegotiationScreen extends ConsumerStatefulWidget {
  final String proposalId;
  const NegotiationScreen({super.key, required this.proposalId});

  @override
  ConsumerState<NegotiationScreen> createState() => _State();
}

class _State extends ConsumerState<NegotiationScreen> {
  List<Map<String, dynamic>> _messages = [];
  final _bodyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await ref.read(proposalsRepoProvider).getNegotiationMessages(widget.proposalId);
    if (mounted) setState(() { _messages = data; _loading = false; });
  }

  Future<void> _sendCounter() async {
    if (_bodyCtrl.text.isEmpty) return;
    await ref.read(proposalsRepoProvider).sendCounter(widget.proposalId, _bodyCtrl.text, counterPrice: _priceCtrl.text.isEmpty ? null : _priceCtrl.text);
    _bodyCtrl.clear(); _priceCtrl.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NEGOTIATION')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kWhite, strokeWidth: 2))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      final isCreator = m['sender'] == 'creator';
                      return Align(
                        alignment: isCreator ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: isCreator ? kGray700 : kGray900,
                            border: Border.all(color: kGray600),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m['body'] ?? '', style: const TextStyle(fontSize: 13)),
                              if (m['counter_price'] != null)
                                Text('Counter: ₹${m['counter_price']}', style: TextStyle(color: kGray300, fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: kGray800))),
                  child: Column(
                    children: [
                      TextField(controller: _bodyCtrl, style: const TextStyle(fontSize: 13), decoration: const InputDecoration(hintText: 'Your message...')),
                      const SizedBox(height: 8),
                      TextField(controller: _priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 13), decoration: const InputDecoration(hintText: 'Counter price (optional)')),
                      const SizedBox(height: 10),
                      ElevatedButton(onPressed: _sendCounter, child: const Text('SEND')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
