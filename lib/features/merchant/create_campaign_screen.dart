import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/campaigns_repository.dart';
import '../../widgets/xb_error.dart';

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
  final _flashRadiusCtrl = TextEditingController(text: '5');
  final _couponCtrl = TextEditingController();
  final _maxCreatorsCtrl = TextEditingController(text: '1');

  String _deliverable = 'reel';
  bool _isFlash = false;
  bool _loading = false;
  String? _error;
  String? _selectedCategory;
  DateTime? _applicationDeadline;
  DateTime? _campaignStart;
  DateTime? _campaignEnd;

  List<Map<String, dynamic>> _categories = [];

  static const _deliverables = [
    ('reel', 'INSTAGRAM REEL'),
    ('story', 'INSTAGRAM STORY'),
    ('youtube_video', 'YOUTUBE VIDEO'),
    ('youtube_short', 'YOUTUBE SHORT'),
    ('bundle', 'BUNDLE'),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    _perCreatorCtrl.dispose();
    _flashRadiusCtrl.dispose();
    _couponCtrl.dispose();
    _maxCreatorsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ref.read(campaignsRepoProvider).getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _pickDate(BuildContext context, String field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
              primary: kFg,
              onPrimary: kBg,
              surface: kBg,
              onSurface: kFg),
          dialogBackgroundColor: kBg,
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (field == 'deadline') _applicationDeadline = picked;
      if (field == 'start') _campaignStart = picked;
      if (field == 'end') _campaignEnd = picked;
    });
  }

  String _fmtDate(DateTime? d) =>
      d == null ? 'NOT SET' : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _create() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Title is required.');
      return;
    }
    if (_budgetCtrl.text.trim().isEmpty || _perCreatorCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Budget fields are required.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payload = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'budget_total': _budgetCtrl.text.trim(),
        'budget_per_creator': _perCreatorCtrl.text.trim(),
        'deliverable_type': _deliverable,
        'is_flash_campaign': _isFlash,
        'max_creators': int.tryParse(_maxCreatorsCtrl.text.trim()) ?? 1,
      };
      if (_isFlash) {
        payload['flash_radius_km'] =
            int.tryParse(_flashRadiusCtrl.text.trim()) ?? 5;
      }
      if (_applicationDeadline != null) {
        payload['application_deadline'] =
            _applicationDeadline!.toIso8601String();
      }
      if (_campaignStart != null) {
        payload['campaign_start'] = _campaignStart!.toIso8601String();
      }
      if (_campaignEnd != null) {
        payload['campaign_end'] = _campaignEnd!.toIso8601String();
      }
      if (_couponCtrl.text.trim().isNotEmpty) {
        payload['coupon_code'] = _couponCtrl.text.trim();
      }
      if (_selectedCategory != null) {
        payload['category'] = _selectedCategory;
      }

      final campaign =
          await ref.read(campaignsRepoProvider).createCampaign(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Campaign created successfully.')));
        context.go('/merchant/campaigns/${campaign['id']}/bids');
      }
    } catch (_) {
      if (mounted)
        setState(() => _error = 'Failed to create campaign. Check your inputs.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _deliverableBtn(String value, String label) {
    final sel = _deliverable == value;
    return GestureDetector(
      onTap: () => setState(() => _deliverable = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: sel ? kFg : kBg,
          border: Border.all(color: kFg, width: 1),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: sel ? kBg : kFg,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NEW CAMPAIGN')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Title
          _sectionLabel('CAMPAIGN TITLE'),
          const SizedBox(height: 10),
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(hintText: 'Summer Collection Launch'),
          ),
          const SizedBox(height: 20),
          // Description
          _sectionLabel('DESCRIPTION'),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            maxLines: 5,
            style: const TextStyle(fontSize: 13, height: 1.6),
            decoration: const InputDecoration(
                hintText: 'Describe the campaign goal, target audience, and content expectations...'),
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: kFg),
          const SizedBox(height: 20),
          // Budget
          _sectionLabel('BUDGET'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TOTAL (₹)',
                    style: TextStyle(fontSize: 9, letterSpacing: 2)),
                const SizedBox(height: 6),
                TextField(
                  controller: _budgetCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(prefixText: '₹ '),
                ),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('PER CREATOR (₹)',
                    style: TextStyle(fontSize: 9, letterSpacing: 2)),
                const SizedBox(height: 6),
                TextField(
                  controller: _perCreatorCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(prefixText: '₹ '),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 6),
          const Text(
            'Creators receive 90% of per-creator amount after platform fee.',
            style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, height: 1.5),
          ),
          const SizedBox(height: 20),
          // Max creators
          _sectionLabel('MAX CREATORS'),
          const SizedBox(height: 10),
          TextField(
            controller: _maxCreatorsCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(hintText: '1–50'),
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: kFg),
          const SizedBox(height: 20),
          // Deliverable type
          _sectionLabel('CONTENT FORMAT'),
          const SizedBox(height: 12),
          Column(children: [
            Row(children: _deliverables
                .take(3)
                .map((d) => Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _deliverableBtn(d.$1, d.$2))))
                .toList()),
            const SizedBox(height: 6),
            Row(children: [
              ..._deliverables
                  .skip(3)
                  .map((d) => Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _deliverableBtn(d.$1, d.$2))))
                  .toList(),
              const Expanded(child: SizedBox()), // balance
            ]),
          ]),
          const SizedBox(height: 24),
          Container(height: 1, color: kFg),
          const SizedBox(height: 20),
          // Flash campaign
          _sectionLabel('FLASH CAMPAIGN'),
          const SizedBox(height: 10),
          Row(children: [
            Switch(
              value: _isFlash,
              onChanged: (v) => setState(() => _isFlash = v),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Geo-targeted — only creators within radius see this campaign',
                style: TextStyle(fontSize: 11, height: 1.4),
              ),
            ),
          ]),
          if (_isFlash) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _flashRadiusCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                  labelText: 'RADIUS (KM)', suffixText: ' km'),
            ),
          ],
          const SizedBox(height: 24),
          Container(height: 1, color: kFg),
          const SizedBox(height: 20),
          // Dates
          _sectionLabel('TIMELINE'),
          const SizedBox(height: 12),
          _datePicker(context, 'APPLICATION DEADLINE', _applicationDeadline, 'deadline'),
          const SizedBox(height: 10),
          _datePicker(context, 'CAMPAIGN START', _campaignStart, 'start'),
          const SizedBox(height: 10),
          _datePicker(context, 'CAMPAIGN END', _campaignEnd, 'end'),
          const SizedBox(height: 24),
          Container(height: 1, color: kFg),
          const SizedBox(height: 20),
          // Optional fields
          _sectionLabel('OPTIONAL'),
          const SizedBox(height: 12),
          // Category
          if (_categories.isNotEmpty) ...[
            const Text('CATEGORY',
                style: TextStyle(fontSize: 9, letterSpacing: 2)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedCategory = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedCategory == null ? kFg : kBg,
                      border: Border.all(color: kFg, width: 1),
                    ),
                    child: Text(
                      'NONE',
                      style: TextStyle(
                        color: _selectedCategory == null ? kBg : kFg,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                ..._categories.map((cat) {
                  final slug = cat['slug'] as String? ?? '';
                  final sel = _selectedCategory == slug;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = slug),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? kFg : kBg,
                        border: Border.all(color: kFg, width: 1),
                      ),
                      child: Text(
                        (cat['name'] as String? ?? '').toUpperCase(),
                        style: TextStyle(
                          color: sel ? kBg : kFg,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // Coupon
          const Text('COUPON CODE',
              style: TextStyle(fontSize: 9, letterSpacing: 2)),
          const SizedBox(height: 8),
          TextField(
            controller: _couponCtrl,
            style: const TextStyle(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(hintText: 'SUMMER25 (optional)'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 20),
            XbError(message: _error!),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loading ? null : _create,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: kBg))
                : const Text('CREATE CAMPAIGN'),
          ),
        ]),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 10, letterSpacing: 2.5, fontWeight: FontWeight.w700),
      );

  Widget _datePicker(
      BuildContext context, String label, DateTime? value, String field) =>
      GestureDetector(
        onTap: () => _pickDate(context, field),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(border: Border.all(color: kFg, width: 1)),
          child: Row(children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(_fmtDate(value),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        value != null ? FontWeight.w700 : FontWeight.w400)),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today_outlined, color: kFg, size: 14),
          ]),
        ),
      );
}
