import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/proposals_repository.dart';
import '../../data/campaigns_repository.dart';
import '../../data/escrow_repository.dart';
import '../../widgets/xb_loader.dart';
import '../../widgets/xb_empty.dart';
import '../../widgets/xb_error.dart';
import '../../widgets/xb_section_header.dart';
import '../../widgets/status_chip.dart';

class CampaignBidsScreen extends ConsumerStatefulWidget {
  final String campaignId;
  const CampaignBidsScreen({super.key, required this.campaignId});

  @override
  ConsumerState<CampaignBidsScreen> createState() => _State();
}

class _State extends ConsumerState<CampaignBidsScreen> {
  Map<String, dynamic>? _campaign;
  List<Map<String, dynamic>> _matrix = [];
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
      final results = await Future.wait([
        ref.read(campaignsRepoProvider).getCampaign(widget.campaignId),
        ref.read(proposalsRepoProvider).getRoiForecast(widget.campaignId),
      ]);
      final forecasts = results[1] as List<Map<String, dynamic>>;
      final matrix = forecasts.isNotEmpty
          ? (forecasts.first['forecast_matrix'] as List? ?? [])
              .cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];
      // Sort by roi_index descending
      matrix.sort((a, b) {
        final ai = double.tryParse(a['roi_index']?.toString() ?? '0') ?? 0;
        final bi = double.tryParse(b['roi_index']?.toString() ?? '0') ?? 0;
        return bi.compareTo(ai);
      });
      if (mounted) {
        setState(() {
          _campaign = results[0] as Map<String, dynamic>;
          _matrix = matrix;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() { _error = 'Failed to load bids.'; _loading = false; });
    }
  }

  Future<void> _accept(String proposalId) async {
    try {
      await ref.read(proposalsRepoProvider).acceptProposal(proposalId);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Proposal accepted.')));
        _load();
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to accept proposal.')));
    }
  }

  Future<void> _fundCampaign({String? proposalId}) async {
    try {
      await ref
          .read(escrowRepoProvider)
          .fundCampaign(widget.campaignId, proposalId: proposalId);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Campaign funded from wallet.')));
        _load();
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funding failed. Check wallet balance.')));
    }
  }

  void _showCounterDialog(String proposalId) {
    final bodyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kBlack,
        shape: const RoundedRectangleBorder(),
        title: const Text('COUNTER OFFER',
            style: TextStyle(
                color: kWhite,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 2)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: bodyCtrl,
            maxLines: 3,
            style: const TextStyle(color: kWhite, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Message to creator...',
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: kWhite, width: 1)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: kWhite, width: 2)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: kWhite, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Counter price (₹) — optional',
              prefixText: '₹ ',
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: kWhite, width: 1)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: kWhite, width: 2)),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCEL',
                  style: TextStyle(color: kWhite, fontSize: 11))),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(proposalsRepoProvider).sendCounter(
                      proposalId,
                      bodyCtrl.text.trim(),
                      counterPrice: priceCtrl.text.trim().isEmpty
                          ? null
                          : priceCtrl.text.trim(),
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Counter offer sent.')));
                  _load();
                }
              } catch (_) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to send counter.')));
              }
            },
            child: const Text('SEND'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _campaign?['status'] as String? ?? '';
    final escrowFunded = _campaign?['escrow_funded'] == true;

    return Scaffold(
      appBar: AppBar(title: const Text('ROI FORECAST')),
      body: _loading
          ? const XbLoader()
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: XbError(message: _error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: kWhite,
                  backgroundColor: kBlack,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campaign header
                        if (_campaign != null) ...[
                          Text(
                            _campaign!['title'] as String? ?? '',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                height: 1.2),
                          ),
                          const SizedBox(height: 8),
                          Row(children: [
                            StatusChip(status: status),
                            if (escrowFunded) ...[
                              const SizedBox(width: 8),
                              const StatusChip(status: 'funded'),
                            ],
                          ]),
                          const SizedBox(height: 16),
                          // Fund button
                          if (!escrowFunded)
                            OutlinedButton(
                              onPressed: () => _fundCampaign(),
                              child: const Text('FUND CAMPAIGN FROM WALLET'),
                            ),
                          const SizedBox(height: 8),
                        ],
                        // Bids table
                        const XbSectionHeader(title: 'CREATOR BIDS · RANKED BY ROI'),
                        if (_matrix.isEmpty)
                          const XbEmpty(message: 'No proposals yet. Share your campaign link to attract creators.')
                        else
                          ..._matrix.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final row = entry.value;
                            final roi = double.tryParse(
                                    row['roi_index']?.toString() ?? '0')
                                ?.toStringAsFixed(2) ??
                                '0.00';
                            final bid = double.tryParse(
                                    row['bid_amount']?.toString() ?? '0')
                                ?.toStringAsFixed(0) ??
                                '0';
                            final reach = row['forecasted_reach'] as int? ?? 0;
                            final quality = double.tryParse(
                                    row['quality_score']?.toString() ?? '0')
                                ?.toStringAsFixed(1) ??
                                '0.0';
                            final proposalId =
                                row['proposal_id'] as String? ?? '';
                            final isTop = idx == 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 1),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isTop ? kWhite : kBlack,
                                border: Border.all(color: kWhite, width: 1),
                              ),
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      if (isTop)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          color: kBlack,
                                          child: const Text(
                                            '#1 RECOMMENDED',
                                            style: TextStyle(
                                                color: kWhite,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1.5),
                                          ),
                                        ),
                                      if (!isTop)
                                        Text(
                                          '#${idx + 1}',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              letterSpacing: 1.5,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      const Spacer(),
                                      Text(
                                        'ROI ${roi}x',
                                        style: TextStyle(
                                            color: isTop ? kBlack : kWhite,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ]),
                                    const SizedBox(height: 10),
                                    Text(
                                      row['creator_name'] as String? ?? '',
                                      style: TextStyle(
                                          color: isTop ? kBlack : kWhite,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 10),
                                    // Metrics
                                    Row(children: [
                                      _Metric('BID', '₹$bid', isTop),
                                      const SizedBox(width: 20),
                                      _Metric('REACH', '$reach', isTop),
                                      const SizedBox(width: 20),
                                      _Metric('QUALITY', quality, isTop),
                                    ]),
                                    const SizedBox(height: 14),
                                    Row(children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              _showCounterDialog(proposalId),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: isTop ? kBlack : kWhite,
                                            side: BorderSide(
                                                color: isTop ? kBlack : kWhite,
                                                width: 1),
                                            minimumSize: const Size(0, 40),
                                          ),
                                          child: const Text('COUNTER'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _accept(proposalId),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                isTop ? kBlack : kWhite,
                                            foregroundColor:
                                                isTop ? kWhite : kBlack,
                                            minimumSize: const Size(0, 40),
                                            side: BorderSide(
                                                color: isTop ? kWhite : kBlack,
                                                width: 1),
                                          ),
                                          child: const Text('ACCEPT'),
                                        ),
                                      ),
                                    ]),
                                  ]),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final bool inverted;
  const _Metric(this.label, this.value, this.inverted);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: inverted ? kBlack : kWhite,
                  fontSize: 8,
                  letterSpacing: 1.5)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: inverted ? kBlack : kWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
        ],
      );
}
