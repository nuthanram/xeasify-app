import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/campaigns_repository.dart';

class CreateCampaignScreen extends ConsumerStatefulWidget {
  const CreateCampaignScreen({super.key});
  @override
  ConsumerState<CreateCampaignScreen> createState() => _State();
}

class _State extends ConsumerState<CreateCampaignScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _perCreatorCtrl = TextEditingController();
  String _deliverable = 'reel';
  bool _isFlash = false;
  bool _loading = false;

  Future<void> _create() async {
    setState(() => _loading = true);
    try {
      final campaign = await ref.read(campaignsRepoProvider).createCampaign({
        'title': _titleCtrl.text, 'description': _descCtrl.text,
        'budget_total': _budgetCtrl.text, 'budget_per_creator': _perCreatorCtrl.text,
        'deliverable_type': _deliverable, 'is_flash_campaign': _isFlash, 'max_creators': 1,
      });
      if (mounted) context.go('/merchant/campaigns/${campaign['id']}/bids');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NEW CAMPAIGN')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _field('TITLE', _titleCtrl),
          const SizedBox(height: 12),
          _field('DESCRIPTION', _descCtrl, lines: 4),
          const SizedBox(height: 12),
          _field('TOTAL BUDGET (₹)', _budgetCtrl, numeric: true),
          const SizedBox(height: 12),
          _field('BUDGET PER CREATOR (₹)', _perCreatorCtrl, numeric: true),
          const SizedBox(height: 12),
          Text('DELIVERABLE', style: TextStyle(color: kGray400, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _deliverable,
            dropdownColor: kGray900,
            style: const TextStyle(color: kWhite, fontSize: 13),
            decoration: InputDecoration(),
            items: const [
              DropdownMenuItem(value: 'reel', child: Text('Instagram Reel')),
              DropdownMenuItem(value: 'story', child: Text('Instagram Story')),
              DropdownMenuItem(value: 'youtube_video', child: Text('YouTube Video')),
              DropdownMenuItem(value: 'youtube_short', child: Text('YouTube Short')),
              DropdownMenuItem(value: 'bundle', child: Text('Bundle')),
            ],
            onChanged: (v) => setState(() => _deliverable = v!),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Switch(value: _isFlash, onChanged: (v) => setState(() => _isFlash = v), activeColor: kWhite),
            const SizedBox(width: 8),
            Text('Flash Campaign (5km geo-targeted)', style: TextStyle(color: kGray300, fontSize: 13)),
          ]),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loading ? null : _create, child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: kBlack)) : const Text('CREATE CAMPAIGN')),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int lines = 1, bool numeric = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: kGray400, fontSize: 11, letterSpacing: 1)),
      const SizedBox(height: 6),
      TextField(controller: ctrl, maxLines: lines, keyboardType: numeric ? TextInputType.number : TextInputType.text, style: const TextStyle(fontSize: 13)),
    ],
  );
}
