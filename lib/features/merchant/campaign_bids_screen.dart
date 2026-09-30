import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/dio_client.dart';

class CampaignBidsScreen extends ConsumerStatefulWidget {
  final String campaignId;
  const CampaignBidsScreen({super.key, required this.campaignId});

  @override
  ConsumerState<CampaignBidsScreen> createState() => _State();
}

class _State extends ConsumerState<CampaignBidsScreen> {
  Map<String, dynamic>? _forecast;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final res = await ref.read(dioProvider).get('/bidding/roi-forecast/', queryParameters: {'campaign': widget.campaignId});
    final results = res.data['results'] as List?;
    if (mounted) setState(() { _forecast = results?.isNotEmpty == true ? results!.first : null; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final matrix = (_forecast?['forecast_matrix'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('ROI FORECAST')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kWhite, strokeWidth: 2))
          : matrix.isEmpty
              ? Center(child: Text('No proposals yet.', style: TextStyle(color: kGray400)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: matrix.length,
                  itemBuilder: (_, i) {
                    final row = matrix[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: kGray900, border: Border.all(color: kGray700), borderRadius: BorderRadius.circular(4)),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(row['creator_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('Reach: ${row['forecasted_reach']}  •  Bid: ₹${row['bid_amount']}', style: TextStyle(color: kGray400, fontSize: 12)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(row['roi_index'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text('ROI INDEX', style: TextStyle(color: kGray400, fontSize: 9, letterSpacing: 1)),
                        ]),
                      ]),
                    );
                  },
                ),
    );
  }
}
