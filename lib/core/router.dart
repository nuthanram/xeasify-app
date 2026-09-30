import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/marketplace/marketplace_screen.dart';
import '../features/marketplace/campaign_detail_screen.dart';
import '../features/proposals/proposal_submit_screen.dart';
import '../features/proposals/my_proposals_screen.dart';
import '../features/proposals/negotiation_screen.dart';
import '../features/deliverable/submit_deliverable_screen.dart';
import '../features/pricing/pricing_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/merchant/merchant_dashboard_screen.dart';
import '../features/merchant/create_campaign_screen.dart';
import '../features/merchant/campaign_bids_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = auth.accessToken != null;
      final isLoginRoute = state.matchedLocation == '/login';
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) {
        return auth.role == 'merchant' ? '/merchant' : '/marketplace';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/marketplace', builder: (_, __) => const MarketplaceScreen()),
      GoRoute(path: '/marketplace/:id', builder: (_, s) => CampaignDetailScreen(campaignId: s.pathParameters['id']!)),
      GoRoute(path: '/proposals/new', builder: (_, s) => ProposalSubmitScreen(campaignId: s.uri.queryParameters['campaign'] ?? '')),
      GoRoute(path: '/proposals', builder: (_, __) => const MyProposalsScreen()),
      GoRoute(path: '/proposals/:id/negotiate', builder: (_, s) => NegotiationScreen(proposalId: s.pathParameters['id']!)),
      GoRoute(path: '/deliverable', builder: (_, __) => const SubmitDeliverableScreen()),
      GoRoute(path: '/pricing', builder: (_, __) => const PricingScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/merchant', builder: (_, __) => const MerchantDashboardScreen()),
      GoRoute(path: '/merchant/campaigns/new', builder: (_, __) => const CreateCampaignScreen()),
      GoRoute(path: '/merchant/campaigns/:id/bids', builder: (_, s) => CampaignBidsScreen(campaignId: s.pathParameters['id']!)),
    ],
  );
});
