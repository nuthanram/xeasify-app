# Changelog

Newest entries first. Read this file before every change and add an entry with every change (see `.claude/skills/xeasify-main-only/SKILL.md`).

## 2026-10-04 — Invert theme: white background, black text
- What changed: the black-on-white UI is now white-on-black inverted to a light theme. Colour constants `kBlack`/`kWhite` were renamed to meaning-based `kBg`/`kFg` across all screens and widgets, with `kBg = white` and `kFg = black` (`lib/core/theme.dart`). The theme now uses `Brightness.light`, `ColorScheme.light`, dark status-bar icons and a light base text theme; the date-picker theme in `create_campaign_screen.dart` matches. `android/app/src/main/res/values-night/styles.xml` now uses the light launch theme so phones in dark mode do not flash black on startup. README theme note updated.
- Why: requested UI change. Screens were not restyled individually: every colour already came from the two constants, so flipping them inverts everything consistently.

## 2026-10-04 — Add first-run app tour for creators and merchants
- What changed: new `lib/features/onboarding/app_tour_screen.dart` (4 role-specific slides, SKIP / NEXT / GET STARTED), `lib/services/tour_service.dart` (per-role "seen" flag in `shared_preferences`), a `/tour/:role` route in `lib/core/router.dart`, auto-open on first visit to the marketplace and merchant dashboard, and a `?` replay icon in both app bars. On the marketplace the location dialog now waits until the tour closes. Added `test/app_tour_test.dart` (6 passing tests) and updated `README.md`.
- Why: new users did not know the creator verification steps, bidding/negotiation, or how escrow pays out. The tour is shown once per role, is skippable, and can be replayed.

## 2026-10-04 — Write full README
- What changed: replaced the placeholder `README.md` with setup, backend/`API_BASE_URL` configuration, run/build commands, project layout, app flow, permissions, a step-by-step testing guide, contribution rules and known issues.
- Why: new contributors had no instructions for running or testing the app. Known issues documented rather than fixed: broken template `test/widget_test.dart`, Firebase never initialised, no logout UI, CI/toolchain version mismatch.

## 2026-10-04 — Ask for location permission once on marketplace
- What changed: `LocationService` gained `needsPrompt()`/`markPrompted()` (a one-time flag in `shared_preferences`); `MarketplaceScreen` shows an explanatory dialog on first open and requests the OS location permission only if the user taps Allow.
- Why: `requestPermission()` existed but was never called, so GPS check-in could never run. Location stays optional: declining is remembered, the user is not asked again, and the app works without it.

## 2026-10-04 — Add Android permissions to main manifest
- What changed: `android/app/src/main/AndroidManifest.xml` now declares `INTERNET`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION` and `POST_NOTIFICATIONS`; `.gitignore` ignores `android/.kotlin/`; the Flutter-generated `android/` project, `test/`, `.metadata` and `analysis_options.yaml` are now tracked.
- Why: `INTERNET` was only declared in the debug/profile manifests, so release builds could not reach the API. Location and notification permissions are optional at runtime (the app works if the user denies them) but must be declared to be requested.

## 2026-10-04 — Add sync-after-run skill
- What changed: added `.claude/skills/xeasify-sync-after-run/SKILL.md`.
- Why: after any run, required diffs get pushed to `main`; files that aren't required in the repo go into `.gitignore` instead.

## 2026-10-04 — Add main-only push workflow and changelog
- What changed: added `.claude/skills/xeasify-main-only/SKILL.md` and this `CHANGELOG.md`.
- Why: all changes go to `main` only, and every change is logged here.
