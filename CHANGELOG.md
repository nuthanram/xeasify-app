# Changelog

Newest entries first. Read this file before every change and add an entry with every change (see `.claude/skills/xeasify-main-only/SKILL.md`).

## 2026-10-04 — Add Android permissions to main manifest
- What changed: `android/app/src/main/AndroidManifest.xml` now declares `INTERNET`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION` and `POST_NOTIFICATIONS`; `.gitignore` ignores `android/.kotlin/`; the Flutter-generated `android/` project, `test/`, `.metadata` and `analysis_options.yaml` are now tracked.
- Why: `INTERNET` was only declared in the debug/profile manifests, so release builds could not reach the API. Location and notification permissions are optional at runtime (the app works if the user denies them) but must be declared to be requested.

## 2026-10-04 — Add sync-after-run skill
- What changed: added `.claude/skills/xeasify-sync-after-run/SKILL.md`.
- Why: after any run, required diffs get pushed to `main`; files that aren't required in the repo go into `.gitignore` instead.

## 2026-10-04 — Add main-only push workflow and changelog
- What changed: added `.claude/skills/xeasify-main-only/SKILL.md` and this `CHANGELOG.md`.
- Why: all changes go to `main` only, and every change is logged here.
