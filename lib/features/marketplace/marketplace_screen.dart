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
import '../../services/tour_service.dart';
import '../auth/auth_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runFirstOpenPrompts();
    });
  }

  /// First open: app tour, then (only after it closes) the location explanation.
  Future<void> _runFirstOpenPrompts() async {
    await TourService.showIfFirstTime(context, ref.read(authProvider).role);
    if (!mounted) return;
    await _askLocationOnce();
  }

  /// Explains why location is useful, then asks once. Declining is fine —
  /// the app works without it and we never ask again.
  Future<void> _askLocationOnce() async {
    if (!await LocationService.needsPrompt() || !mounted) return;
    await LocationService.markPrompted();
    if (!mounted) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enable location?'),
        content: const Text(
          'Sharing your location lets us match you with nearby flash campaigns. '
          'It is optional — you can use Xeasify without it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    if (accepted == true && await LocationService.requestPermission()) {
      LocationService.checkInIfPermitted();
    }
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
            icon: const Icon(Icons.help_outline, size: 20),
            tooltip: 'How it works',
            onPressed: () => context.push('/tour/creator'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Onboarding banner — shown when creator hasn't completed verification
          _OnboardingBanner(ref: ref),
          // Category filter strip
          if (_categories.isNotEmpty)
            Container(
              height: 40,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: kFg, width: 1)),
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
                            color: kFg,
                            backgroundColor: kBg,
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
          color: selected ? kFg : kBg,
          border: Border.all(color: kFg, width: 1),
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: selected ? kBg : kFg,
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

class _OnboardingBanner extends StatelessWidget {
  final WidgetRef ref;
  const _OnboardingBanner({required this.ref});

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (auth.role != 'creator') return const SizedBox.shrink();
    if (auth.signupState == 'verified' || auth.signupState == null) {
      return const SizedBox.shrink();
    }

    final String message;
    if (auth.signupState == 'social_linked') {
      message = 'STEP 2 OF 3 — Grant metrics access so brands can see your reach stats.';
    } else {
      message = 'STEP 3 OF 3 — Verify your phone and email to start applying to campaigns.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: kFg,
      child: Row(children: [
        const Icon(Icons.info_outline, color: kBg, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: kBg,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
        ),
      ]),
    );
  }
}
