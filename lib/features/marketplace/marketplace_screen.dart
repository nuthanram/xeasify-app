import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/campaigns_repository.dart';
import '../../widgets/campaign_card.dart';
import '../../services/location_service.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  List<Map<String, dynamic>> _campaigns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAndCheckin();
  }

  Future<void> _loadAndCheckin() async {
    // GPS check-in on screen open — triggers flash campaign matching
    LocationService.checkInIfPermitted();
    final repo = ref.read(campaignsRepoProvider);
    final data = await repo.getCampaigns();
    if (mounted) setState(() { _campaigns = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MARKETPLACE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            onPressed: () => context.go('/notifications'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kWhite, strokeWidth: 2))
          : _campaigns.isEmpty
              ? Center(child: Text('No active campaigns.', style: TextStyle(color: kGray400, fontSize: 13)))
              : RefreshIndicator(
                  onRefresh: _loadAndCheckin,
                  color: kWhite,
                  backgroundColor: kGray900,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _campaigns.length,
                    itemBuilder: (_, i) => CampaignCard(
                      campaign: _campaigns[i],
                      onTap: () => context.go('/marketplace/${_campaigns[i]['id']}'),
                    ),
                  ),
                ),
    );
  }
}
