import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../services/tour_service.dart';

class TourSlide {
  final IconData icon;
  final String title;
  final String body;
  final String? note;
  const TourSlide({
    required this.icon,
    required this.title,
    required this.body,
    this.note,
  });
}

const List<TourSlide> creatorTourSlides = [
  TourSlide(
    icon: Icons.storefront_outlined,
    title: 'FIND CAMPAIGNS',
    body:
        'Browse campaigns from brands in MARKET. Filter by category and open any campaign to read the brief before you apply.',
    note:
        'Optional: allow location to be matched with nearby flash campaigns. The app works without it.',
  ),
  TourSlide(
    icon: Icons.verified_user_outlined,
    title: 'GET VERIFIED FIRST',
    body:
        'Link your social account, grant metrics access, then verify your phone and email. Campaigns unlock once you are verified, and brands can see your reach stats.',
  ),
  TourSlide(
    icon: Icons.handshake_outlined,
    title: 'BID & NEGOTIATE',
    body:
        'Send a proposal with your price. Track every bid in BIDS and negotiate with the brand until you both agree.',
    note: 'ALERTS tells you when a brand replies.',
  ),
  TourSlide(
    icon: Icons.lock_outline,
    title: 'GET PAID SAFELY',
    body:
        'Brands fund campaigns into escrow. Submit your content link as a deliverable. The brand has 48 hours to verify it, then the funds are released to your wallet automatically.',
  ),
];

const List<TourSlide> merchantTourSlides = [
  TourSlide(
    icon: Icons.dashboard_outlined,
    title: 'YOUR COMMAND CENTER',
    body:
        'COMMAND shows your campaigns and key numbers at a glance. Pull down on any list to refresh it.',
  ),
  TourSlide(
    icon: Icons.campaign_outlined,
    title: 'CREATE CAMPAIGNS',
    body:
        'Open CAMPAIGNS and add a new one with your brief. Verified creators can find active campaigns in the marketplace and apply.',
  ),
  TourSlide(
    icon: Icons.groups_outlined,
    title: 'REVIEW BIDS',
    body:
        'Open a campaign to see the bids creators have sent. Negotiate the price and choose who you want to work with.',
    note: 'ALERTS tells you about new bids and updates.',
  ),
  TourSlide(
    icon: Icons.lock_outline,
    title: 'PAY SAFELY WITH ESCROW',
    body:
        'Campaign funds are held in escrow. When a creator submits their content you have 48 hours to verify it. After that, the funds are released to them automatically.',
  ),
];

List<TourSlide> tourSlidesFor(String role) =>
    TourService.normalizeRole(role) == 'merchant'
        ? merchantTourSlides
        : creatorTourSlides;

/// First-run walkthrough, tailored to the user's role. Reachable again via the
/// help icon on the marketplace / command-center screens.
class AppTourScreen extends StatefulWidget {
  final String role;
  const AppTourScreen({super.key, required this.role});

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  final _controller = PageController();
  late final List<TourSlide> _slides = tourSlidesFor(widget.role);
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  @override
  void initState() {
    super.initState();
    // Marked as soon as it opens: closing it any way (skip, back, app kill) counts as seen.
    TourService.markSeen(widget.role);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(TourService.normalizeRole(widget.role) == 'merchant'
          ? '/merchant'
          : '/marketplace');
    }
  }

  void _next() {
    if (_isLast) {
      _close();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: TextButton(
                  onPressed: _close,
                  child: const Text('SKIP'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) =>
                    _SlideView(slide: _slides[i], index: i, total: _slides.length),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _index ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _index ? kFg : kBg,
                            border: Border.all(color: kFg, width: 1),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(_isLast ? 'GET STARTED' : 'NEXT'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final TourSlide slide;
  final int index;
  final int total;
  const _SlideView(
      {required this.slide, required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration:
                BoxDecoration(border: Border.all(color: kFg, width: 1)),
            child: Icon(slide.icon, size: 40, color: kFg),
          ),
          const SizedBox(height: 32),
          Text(
            '${(index + 1).toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 11, letterSpacing: 3),
          ),
          const SizedBox(height: 12),
          Text(
            slide.title,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          Text(slide.body, style: const TextStyle(fontSize: 14, height: 1.6)),
          if (slide.note != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration:
                  BoxDecoration(border: Border.all(color: kFg, width: 1)),
              child: Text(slide.note!,
                  style: const TextStyle(fontSize: 12, height: 1.5)),
            ),
          ],
        ],
      ),
    );
  }
}
