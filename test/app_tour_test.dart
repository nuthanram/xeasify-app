import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xeasify_app/features/onboarding/app_tour_screen.dart';
import 'package:xeasify_app/services/tour_service.dart';

Widget _app(String role) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, __) => Scaffold(
          body: Builder(
            builder: (ctx) => TextButton(
              onPressed: () => ctx.push('/tour/$role'),
              child: const Text('OPEN TOUR'),
            ),
          ),
        ),
      ),
      GoRoute(path: '/tour/:role', builder: (_, __) => AppTourScreen(role: role)),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('role normalisation defaults to creator', () {
    expect(TourService.normalizeRole('merchant'), 'merchant');
    expect(TourService.normalizeRole('creator'), 'creator');
    expect(TourService.normalizeRole(null), 'creator');
  });

  test('seen flag is tracked per role', () async {
    expect(await TourService.hasSeen('creator'), isFalse);
    await TourService.markSeen('creator');
    expect(await TourService.hasSeen('creator'), isTrue);
    expect(await TourService.hasSeen('merchant'), isFalse);
  });

  for (final role in ['creator', 'merchant']) {
    testWidgets('$role tour walks through every slide, then closes',
        (tester) async {
      final slides = tourSlidesFor(role);
      await tester.pumpWidget(_app(role));
      await tester.tap(find.text('OPEN TOUR'));
      await tester.pumpAndSettle();

      for (var i = 0; i < slides.length; i++) {
        expect(find.text(slides[i].title), findsOneWidget);
        await tester
            .tap(find.text(i == slides.length - 1 ? 'GET STARTED' : 'NEXT'));
        await tester.pumpAndSettle();
      }

      expect(find.text('OPEN TOUR'), findsOneWidget);
      expect(await TourService.hasSeen(role), isTrue);
    });

    testWidgets('$role tour can be skipped from the first slide',
        (tester) async {
      await tester.pumpWidget(_app(role));
      await tester.tap(find.text('OPEN TOUR'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SKIP'));
      await tester.pumpAndSettle();

      expect(find.text('OPEN TOUR'), findsOneWidget);
      expect(await TourService.hasSeen(role), isTrue);
    });
  }
}
