import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/campaigns_repository.dart';
import '../../widgets/campaign_card.dart';
import '../../widgets/xb_loader.dart';
import '../../widgets/xb_empty.dart';
import '../../widgets/xb_error.dart';
import '../../services/location_service.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  List<Map<String, dynamic>> _campaigns = [];
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;
  String? _error;
  String? _selectedCategory; // null = ALL

  @override
  void initState() {
    super.initState();
    _loadAndCheckin();
  }

  Future<void> _loadAndCheckin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // GPS check-in on screen open — triggers flash campaign matching
    LocationService.checkInIfPermitted();
    try {
      final repo = ref.read(campaignsRepoProvider);
      final results = await Future.wait([
        repo.getCampaigns(category: _selectedCategory),
        if (_categories.isEmpty) repo.getCategories(),
      ]);
      if (mounted) {
        setState(() {
          _campaigns = results[0] as List<Map<String, dynamic>>;
          if (_categories.isEmpty && results.length > 1) {
            _categories = results[1] as List<Map<String, dynamic>>;
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load campaigns.'; _loading = false; });
    }
  }

  Future<void> _filterByCategory(String? categorySlug) async {
    setState(() { _selectedCategory = categorySlug; });
    await _loadAndCheckin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MARKETPLACE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter strip
          if (_categories.isNotEmpty)
            Container(
              height: 40,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: kWhite, width: 1)),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _categoryPill(null, 'ALL'),
                  ..._categories.map((c) =>
                      _categoryPill(c['slug'] as String?, c['name'] as String? ?? '')),
                ],
              ),
            ),
          // Main content
          Expanded(
            child: _loading
                ? const XbLoader()
                : _error != null
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: XbError(message: _error!),
                      )
                    : _campaigns.isEmpty
                        ? const XbEmpty(message: 'No active campaigns match your filters.')
                        : RefreshIndicator(
                            onRefresh: _loadAndCheckin,
                            color: kWhite,
                            backgroundColor: kBlack,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                              itemCount: _campaigns.length,
                              itemBuilder: (_, i) => CampaignCard(
                                campaign: _campaigns[i],
                                onTap: () => context.push(
                                    '/marketplace/${_campaigns[i]['id']}'),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _categoryPill(String? slug, String label) {
    final selected = _selectedCategory == slug;
    return GestureDetector(
      onTap: () => _filterByCategory(slug),
      child: Container(
        margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? kWhite : kBlack,
          border: Border.all(color: kWhite, width: 1),
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: selected ? kBlack : kWhite,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
