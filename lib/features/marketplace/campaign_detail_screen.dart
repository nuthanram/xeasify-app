import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/campaigns_repository.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/true_data_badge.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  final String campaignId;
  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  ConsumerState<CampaignDetailScreen> createState() => _State();
}

class _State extends ConsumerState<CampaignDetailScreen> {
  Map<String, dynamic>? _campaign;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ref.read(campaignsRepoProvider).getCampaign(widget.campaignId);
    if (mounted) setState(() => _campaign = data);
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Text('$label  ', style: TextStyle(color: kGray400, fontSize: 12)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = _campaign;
    return Scaffold(
      appBar: AppBar(title: const Text('CAMPAIGN')),
      body: c == null
          ? const Center(child: CircularProgressIndicator(color: kWhite, strokeWidth: 2))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(children: [StatusChip(status: c['status'] ?? ''), const SizedBox(width: 8), if (c['is_flash_campaign'] == true) StatusChip(status: 'FLASH')]),
                  const Divider(height: 24),
                  _row('Budget/Creator', '₹${c['budget_per_creator']}'),
                  _row('Deliverable', c['deliverable_type'] ?? ''),
                  _row('Deadline', c['application_deadline'] ?? 'Open'),
                  const Divider(height: 24),
                  Text(c['description'] ?? '', style: TextStyle(color: kGray300, fontSize: 13, height: 1.6)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/proposals/new?campaign=${widget.campaignId}&budget=${c['budget_per_creator']}'),
                    child: const Text('APPLY TO CAMPAIGN'),
                  ),
                ],
              ),
            ),
    );
  }
}
