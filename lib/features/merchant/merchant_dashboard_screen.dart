import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/accounts_repository.dart';
import '../../data/campaigns_repository.dart';
import '../../services/tour_service.dart';
import '../../widgets/xb_metric_tile.dart';
import '../../widgets/xb_section_header.dart';
import '../../widgets/xb_loader.dart';
import '../../widgets/xb_error.dart';

class MerchantDashboardScreen extends ConsumerStatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  ConsumerState<MerchantDashboardScreen> createState() => _State();
}

class _State extends ConsumerState<MerchantDashboardScreen> {
  Map<String, dynamic>? _me;
  List<Map<String, dynamic>> _campaigns = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) TourService.showIfFirstTime(context, 'merchant');
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ref.read(accountsRepoProvider).getMe(),
        ref.read(campaignsRepoProvider).getMerchantCampaigns(),
      ]);
      if (mounted) {
        setState(() {
          _me = results[0] as Map<String, dynamic>;
          _campaigns = results[1] as List<Map<String, dynamic>>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() { _error = 'Failed to load dashboard.'; _loading = false; });
    }
  }

  int get _activeCampaigns =>
      _campaigns.where((c) => c['status'] == 'active').length;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
          appBar: AppBar(title: const Text('COMMAND CENTER')),
          body: const XbLoader());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('COMMAND CENTER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, size: 20),
            tooltip: 'How it works',
            onPressed: () => context.push('/tour/merchant'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            onPressed: () => context.push('/merchant/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: kWhite,
        backgroundColor: kBlack,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                XbError(message: _error!),
                const SizedBox(height: 16),
              ],
              // Header
              const Text(
                'MERCHANT',
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 4),
              Text(
                _me?['email'] as String? ?? '',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 28),
              // Verification status badge
              _VerificationBadge(status: _me?['verification_status'] as String? ?? 'pending'),
              const SizedBox(height: 12),
              // Wallet balance — hero metric
              XbMetricTile(
                label: 'WALLET BALANCE',
                value:
                    '₹${double.tryParse(_me?['wallet_balance']?.toString() ?? '0')?.toStringAsFixed(0) ?? '—'}',
                inverted: true,
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: XbMetricTile(
                  label: 'ACTIVE CAMPAIGNS',
                  value: '$_activeCampaigns',
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: XbMetricTile(
                  label: 'TOTAL CAMPAIGNS',
                  value: '${_campaigns.length}',
                )),
              ]),
              const SizedBox(height: 32),
              Container(height: 1, color: kWhite),
              // Quick actions
              const XbSectionHeader(title: 'QUICK ACTIONS'),
              _ActionButton(
                label: '+ NEW CAMPAIGN',
                inverted: true,
                onTap: () => context.push('/merchant/campaigns/new'),
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'MY CAMPAIGNS',
                onTap: () => context.go('/merchant/campaigns'),
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'NOTIFICATIONS',
                onTap: () => context.push('/merchant/notifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final String status;
  const _VerificationBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final labels = {
      'pending': ('VERIFICATION PENDING', false),
      'identity_verified': ('IDENTITY VERIFIED', true),
      'fully_verified': ('FULLY VERIFIED', true),
      'rejected': ('VERIFICATION REJECTED', false),
    };
    final (label, ok) = labels[status] ?? ('UNKNOWN STATUS', false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ok ? kWhite : kBlack,
        border: Border.all(color: kWhite, width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ok ? Icons.verified_outlined : Icons.hourglass_empty,
            size: 12, color: ok ? kBlack : kWhite),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: ok ? kBlack : kWhite,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool inverted;

  const _ActionButton(
      {required this.label, required this.onTap, this.inverted = false});

  @override
  Widget build(BuildContext context) => Material(
        color: inverted ? kWhite : kBlack,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
                border: Border.all(color: kWhite, width: 1),
                color: inverted ? kWhite : kBlack),
            child: Text(
              label,
              style: TextStyle(
                color: inverted ? kBlack : kWhite,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      );
}
