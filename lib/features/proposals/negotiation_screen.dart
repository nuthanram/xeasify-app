import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/proposals_repository.dart';
import '../../widgets/xb_loader.dart';
import '../../widgets/xb_empty.dart';

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
  final _scrollCtrl = ScrollController();
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bodyCtrl.dispose();
    _priceCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ref
          .read(proposalsRepoProvider)
          .getNegotiationMessages(widget.proposalId);
      if (mounted) {
        setState(() {
          _messages = data;
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    if (_bodyCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(proposalsRepoProvider).sendCounter(
            widget.proposalId,
            _bodyCtrl.text.trim(),
            counterPrice: _priceCtrl.text.trim().isEmpty
                ? null
                : _priceCtrl.text.trim(),
          );
      _bodyCtrl.clear();
      _priceCtrl.clear();
      await _load();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send message.')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatTime(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NEGOTIATION')),
      body: _loading
          ? const XbLoader()
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: _messages.isEmpty
                      ? const XbEmpty(message: 'No messages yet. Start the negotiation.')
                      : ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) {
                            final m = _messages[i];
                            final isCreator = m['sender'] == 'creator';
                            return Align(
                              alignment: isCreator
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                constraints:
                                    const BoxConstraints(maxWidth: 290),
                                decoration: BoxDecoration(
                                  color: isCreator ? kWhite : kBlack,
                                  border:
                                      Border.all(color: kWhite, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isCreator ? 'YOU' : 'MERCHANT',
                                      style: TextStyle(
                                          color: isCreator ? kBlack : kWhite,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      m['body'] as String? ?? '',
                                      style: TextStyle(
                                          color: isCreator ? kBlack : kWhite,
                                          fontSize: 13,
                                          height: 1.5),
                                    ),
                                    if (m['counter_price'] != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'COUNTER: ₹${m['counter_price']}',
                                        style: TextStyle(
                                            color: isCreator
                                                ? kBlack
                                                : kWhite,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _formatTime(
                                            m['sent_at'] as String?),
                                        style: TextStyle(
                                            color: isCreator
                                                ? kBlack
                                                : kWhite,
                                            fontSize: 9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Input area
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: kWhite, width: 1)),
                  ),
                  child: Column(children: [
                    TextField(
                      controller: _bodyCtrl,
                      maxLines: 3,
                      minLines: 1,
                      style: const TextStyle(fontSize: 13),
                      decoration:
                          const InputDecoration(hintText: 'Your message...'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                          hintText: 'Counter price — optional (₹)',
                          prefixText: '₹ '),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _sending ? null : _send,
                      child: _sending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: kBlack))
                          : const Text('SEND'),
                    ),
                  ]),
                ),
              ],
            ),
    );
  }
}
