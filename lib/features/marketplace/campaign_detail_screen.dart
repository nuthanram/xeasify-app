import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/campaigns_repository.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/xb_loader.dart';
import '../../widgets/xb_metric_tile.dart';
import '../../widgets/xb_error.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  final String campaignId;
  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  ConsumerState<CampaignDetailScreen> createState() => _State();
}

class _State extends ConsumerState<CampaignDetailScreen> {
  Map<String, dynamic>? _campaign;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ref
          .read(campaignsRepoProvider)
          .getCampaign(widget.campaignId);
      if (mounted) setState(() => _campaign = data);
    } catch (_) {
      if (mounted) setState(() => _error = 'Failed to load campaign.');
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'OPEN';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _campaign;
    return Scaffold(
      appBar: AppBar(title: const Text('CAMPAIGN')),
      body: _error != null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: XbError(message: _error!),
            )
          : c == null
              ? const XbLoader()
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            c['title'] ?? '',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1.15),
                          ),
                          const SizedBox(height: 12),
                          // Status row
                          Row(children: [
                            StatusChip(status: c['status'] ?? ''),
                            if (c['is_flash_campaign'] == true) ...[
                              const SizedBox(width: 8),
                              const StatusChip(status: 'flash'),
                            ],
                            if (c['escrow_funded'] == true) ...[
                              const SizedBox(width: 8),
                              const StatusChip(status: 'funded'),
                            ],
                          ]),
                          const SizedBox(height: 24),
                          // Key metrics
                          Row(children: [
                            Expanded(
                              child: XbMetricTile(
                                label: 'PER CREATOR',
                                value:
                                    '₹${double.tryParse(c['budget_per_creator']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}',
                                inverted: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: XbMetricTile(
                                label: 'MAX CREATORS',
                                value: '${c['max_creators'] ?? 1}',
                              ),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                              child: XbMetricTile(
                                label: 'DEADLINE',
                                value: _formatDate(
                                    c['application_deadline'] as String?),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: XbMetricTile(
                                label: 'TOTAL BUDGET',
                                value:
                                    '₹${double.tryParse(c['budget_total']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}',
                              ),
                            ),
                          ]),
                          const SizedBox(height: 24),
                          // Deliverable
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                border: Border.all(color: kWhite, width: 1)),
                            child: Row(children: [
                              const Text('FORMAT',
                                  style: TextStyle(
                                      fontSize: 9, letterSpacing: 2)),
                              const Spacer(),
                              Text(
                                (c['deliverable_type'] as String? ?? '')
                                    .toUpperCase()
                                    .replaceAll('_', ' '),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 1),
                              ),
                            ]),
                          ),
                          if (c['coupon_code'] != null &&
                              (c['coupon_code'] as String).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                  border: Border.all(color: kWhite, width: 1)),
                              child: Row(children: [
                                const Text('COUPON',
                                    style: TextStyle(
                                        fontSize: 9, letterSpacing: 2)),
                                const Spacer(),
                                Text(
                                  c['coupon_code'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 2),
                                ),
                              ]),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Container(height: 1, color: kWhite),
                          const SizedBox(height: 20),
                          // Description
                          Text(
                            c['description'] ?? '',
                            style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                height: 1.7),
                          ),
                          if (c['campaign_start'] != null ||
                              c['campaign_end'] != null) ...[
                            const SizedBox(height: 20),
                            Container(height: 1, color: kWhite),
                            const SizedBox(height: 16),
                            const Text('CAMPAIGN WINDOW',
                                style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text(
                              '${_formatDate(c['campaign_start'] as String?)} — ${_formatDate(c['campaign_end'] as String?)}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Sticky CTA
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        color: kBlack,
                        child: ElevatedButton(
                          onPressed: () => context.push(
                              '/marketplace/${widget.campaignId}/apply'),
                          child: const Text('APPLY NOW'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
