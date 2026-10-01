import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/campaigns_repository.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/xb_loader.dart';
import '../../widgets/xb_empty.dart';
import '../../widgets/xb_error.dart';

class MerchantCampaignsScreen extends ConsumerStatefulWidget {
  const MerchantCampaignsScreen({super.key});

  @override
  ConsumerState<MerchantCampaignsScreen> createState() => _State();
}

class _State extends ConsumerState<MerchantCampaignsScreen> {
  List<Map<String, dynamic>> _campaigns = [];
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
      final data =
          await ref.read(campaignsRepoProvider).getMerchantCampaigns();
      if (mounted) setState(() { _campaigns = data; _loading = false; });
    } catch (_) {
      if (mounted)
        setState(() { _error = 'Failed to load campaigns.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CAMPAIGNS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 22),
            onPressed: () => context.push('/merchant/campaigns/new'),
          ),
        ],
      ),
      body: _loading
          ? const XbLoader()
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: XbError(message: _error!))
              : _campaigns.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const XbEmpty(message: 'No campaigns yet.\nCreate your first campaign to get started.'),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: ElevatedButton(
                            onPressed: () => context.push('/merchant/campaigns/new'),
                            child: const Text('+ CREATE CAMPAIGN'),
                          ),
                        ),
                      ],
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: kWhite,
                      backgroundColor: kBlack,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        itemCount: _campaigns.length,
                        itemBuilder: (_, i) {
                          final c = _campaigns[i];
                          final budget = double.tryParse(
                                  c['budget_per_creator']?.toString() ?? '0')
                              ?.toStringAsFixed(0) ??
                              '0';
                          final status = c['status'] as String? ?? '';
                          return Material(
                            color: kBlack,
                            child: InkWell(
                              onTap: () => context.push(
                                  '/merchant/campaigns/${c['id']}/bids'),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 1),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: kWhite, width: 1)),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                        child: Text(
                                          c['title'] as String? ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              height: 1.2),
                                        ),
                                      ),
                                      if (status.isNotEmpty)
                                        StatusChip(status: status),
                                    ]),
                                    const SizedBox(height: 12),
                                    Row(children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('PER CREATOR',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    letterSpacing: 1.5)),
                                            Text('₹$budget',
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w900)),
                                          ]),
                                      const Spacer(),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text('FORMAT',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    letterSpacing: 1.5)),
                                            Text(
                                              (c['deliverable_type']
                                                          as String? ??
                                                      '')
                                                  .toUpperCase()
                                                  .replaceAll('_', ' '),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  letterSpacing: 1),
                                            ),
                                          ]),
                                    ]),
                                    const SizedBox(height: 10),
                                    const Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'VIEW BIDS →',
                                        style: TextStyle(
                                            fontSize: 10,
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
