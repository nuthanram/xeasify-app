import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_merchant_screen.dart';
import '../features/auth/register_creator_screen.dart';
import '../features/auth/youtube_callback_screen.dart';
import '../features/auth/youtube_web_sign_in.dart';
import '../features/marketplace/marketplace_screen.dart';
import '../features/marketplace/campaign_detail_screen.dart';
import '../features/proposals/proposal_submit_screen.dart';
import '../features/proposals/my_proposals_screen.dart';
import '../features/proposals/negotiation_screen.dart';
import '../features/deliverable/submit_deliverable_screen.dart';
import '../features/pricing/pricing_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/app_tour_screen.dart';
import '../features/onboarding/verify_contact_screen.dart';
import '../services/tour_service.dart';
import '../features/merchant/merchant_dashboard_screen.dart';
import '../features/merchant/create_campaign_screen.dart';
import '../features/merchant/campaign_bids_screen.dart';
import '../features/merchant/merchant_campaigns_screen.dart';
import 'theme.dart';

// ─── Creator Shell ──────────────────────────────────────────────────
class _CreatorShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _CreatorShell({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: kFg, width: 1))),
        child: BottomNavigationBar(
          currentIndex: shell.currentIndex,
          onTap: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined, size: 18),
              activeIcon: Icon(Icons.storefront, size: 18),
              label: 'MARKET',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox_outlined, size: 18),
              activeIcon: Icon(Icons.inbox, size: 18),
              label: 'BIDS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined, size: 18),
              activeIcon: Icon(Icons.notifications, size: 18),
              label: 'ALERTS',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Merchant Shell ─────────────────────────────────────────────────
class _MerchantShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _MerchantShell({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: kFg, width: 1))),
        child: BottomNavigationBar(
          currentIndex: shell.currentIndex,
          onTap: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined, size: 18),
              activeIcon: Icon(Icons.dashboard, size: 18),
              label: 'COMMAND',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined, size: 18),
              activeIcon: Icon(Icons.campaign, size: 18),
              label: 'CAMPAIGNS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined, size: 18),
              activeIcon: Icon(Icons.notifications, size: 18),
              label: 'ALERTS',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Router Provider ────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = auth.accessToken != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' ||
          loc == '/register/merchant' ||
          loc == '/register/creator' ||
          loc == YouTubeWebSignIn.callbackPath;
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) {
        return auth.role == 'merchant' ? '/merchant' : '/marketplace';
      }
      return null;
    },
    routes: [
      // ── Public auth routes ──────────────────────────────────────
      GoRoute(
          path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/register/merchant',
          builder: (_, __) => const RegisterMerchantScreen()),
      GoRoute(
          path: '/register/creator',
          builder: (_, __) => const RegisterCreatorScreen()),
      // Web YouTube sign-in: Google redirects here with ?code=…&state=…
      GoRoute(
          path: YouTubeWebSignIn.callbackPath,
          builder: (_, s) => YouTubeCallbackScreen(
                code: s.uri.queryParameters['code'],
                state: s.uri.queryParameters['state'],
                error: s.uri.queryParameters['error'],
              )),

      // ── App tour (first run + replay from the help icon) ────────
      GoRoute(
          path: '/tour/:role',
          builder: (_, s) => AppTourScreen(
              role: TourService.normalizeRole(s.pathParameters['role']))),

      // ── Creator onboarding step 3 (email + phone) ──────────────
      GoRoute(
          path: '/verify-contact',
          builder: (_, __) => const VerifyContactScreen()),

      // ── Creator shell (persistent bottom nav) ───────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => _CreatorShell(shell: shell),
        branches: [
          // Branch 0: Marketplace
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/marketplace',
              builder: (_, __) => const MarketplaceScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, s) => CampaignDetailScreen(
                      campaignId: s.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'apply',
                      builder: (_, s) => ProposalSubmitScreen(
                          campaignId: s.pathParameters['id']!),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          // Branch 1: Proposals / Bids
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/proposals',
              builder: (_, __) => const MyProposalsScreen(),
              routes: [
                GoRoute(
                  path: ':id/negotiate',
                  builder: (_, s) => NegotiationScreen(
                      proposalId: s.pathParameters['id']!),
                ),
              ],
            ),
            GoRoute(
                path: '/deliverable',
                builder: (_, __) => const SubmitDeliverableScreen()),
            GoRoute(
                path: '/pricing',
                builder: (_, __) => const PricingScreen()),
          ]),
          // Branch 2: Notifications
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/notifications',
                builder: (_, __) => const NotificationsScreen()),
          ]),
        ],
      ),

      // ── Merchant shell (persistent bottom nav) ──────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => _MerchantShell(shell: shell),
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/merchant',
                builder: (_, __) => const MerchantDashboardScreen()),
          ]),
          // Branch 1: Campaigns
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/merchant/campaigns',
              builder: (_, __) => const MerchantCampaignsScreen(),
              routes: [
                GoRoute(
                    path: 'new',
                    builder: (_, __) => const CreateCampaignScreen()),
                GoRoute(
                  path: ':id/bids',
                  builder: (_, s) => CampaignBidsScreen(
                      campaignId: s.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          // Branch 2: Merchant notifications
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/merchant/notifications',
                builder: (_, __) => const NotificationsScreen()),
          ]),
        ],
      ),
    ],
  );
});
