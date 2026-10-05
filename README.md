# Xeasify App

Mobile app for **Xeasify**, a B2B influencer marketplace. Built with Flutter (Dart).

Two kinds of users sign in to the same app and see different screens:

| Role | What they do |
|---|---|
| **Creator** (influencer) | Browse campaigns in the marketplace, send proposals, negotiate, submit deliverables, get notified. |
| **Merchant** (brand) | Create campaigns, review bids on them, track campaigns from a dashboard, get notified. |

The app has **no backend of its own**. It is a client for a REST API that you must run or point to (see [Connecting to the backend](#2-connecting-to-the-backend)).

---

## Contents

1. [Quick start](#1-quick-start)
2. [Connecting to the backend](#2-connecting-to-the-backend)
3. [Running the app](#3-running-the-app)
4. [Project layout](#4-project-layout)
5. [How the app works](#5-how-the-app-works)
6. [Permissions and optional features](#6-permissions-and-optional-features)
7. [Testing your changes](#7-testing-your-changes)
8. [Contribution rules](#8-contribution-rules)
9. [Known issues](#9-known-issues)

---

## 1. Quick start

### Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Flutter SDK | stable; Dart `>=3.3.0 <4.0.0` | Developed on Flutter 3.44 / Dart 3.12. |
| Android Studio | any recent | Provides the Android SDK and emulator. |
| JDK | 17 | Android Studio bundles one. |
| Git | any | Flutter needs `git` on your `PATH`. |
| A running backend | - | See section 2. |

You do **not** need Xcode. There is no `ios/` folder yet, so only Android is set up. Xcode only runs on macOS anyway.

### Steps

```bash
# 1. Clone and enter the repo
git clone git@github.com:nuthanram/xeasify-app.git
cd xeasify-app

# 2. Check your toolchain. Fix anything marked [X] for Android.
flutter doctor

# 3. Install dependencies
flutter pub get

# 4. Start an Android emulator (or plug in a phone with USB debugging), then:
flutter run
```

`flutter run` works with no extra flags if your backend runs on `localhost:8000` on your computer and you use the Android emulator. Otherwise read the next section.

> **Windows:** if `flutter` is "not recognized" or says "Unable to find git in your PATH", add both the Flutter `bin` folder and Git's `cmd` folder to your `PATH`.
> Android's `android/local.properties` (not committed) stores your Flutter SDK path, and Flutter creates it for you.

---

## 2. Connecting to the backend

The API address is set at build time with `--dart-define=API_BASE_URL=...`. The default is `http://10.0.2.2:8000`. All requests go to `<API_BASE_URL>/api/v1/...`.

| You run the app on | Use `API_BASE_URL` | Notes |
|---|---|---|
| Android **emulator**, backend on your computer | `http://10.0.2.2:8000` (the default, no flag needed) | `10.0.2.2` is the emulator's alias for your computer's `localhost`. |
| **Physical phone**, backend on your computer | `http://<your-computer-LAN-IP>:8000` | Phone and computer must be on the same Wi-Fi. Make sure the backend listens on `0.0.0.0`, not just `127.0.0.1`. |
| A **deployed/staging** backend | `https://your-host` | Use whatever URL the backend owner gives you. |
| **Chrome**, against the **dev** backend | `https://api.dev.xeasify.com` | Run `.\tool\run_web_dev.ps1` (see "Testing in Chrome against dev" below). |

```bash
# Example: physical phone
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8000
```

The flag applies to `flutter run`, `flutter build ...` and the debugger. If you launch from an IDE, add it in the run configuration's "Additional run args".

API endpoints the app calls include:

- `POST /auth/token/refresh/` for refreshing the login token
- `POST /geo/checkin/` for the optional location check-in
- `PATCH /accounts/creator/fcm-token/` for registering a push token

Other calls live in `lib/data/*_repository.dart`. Find the backend repository with your team (the Xeasify org also has `xeasify-core`, which is presumably the API) and get a test creator and merchant account from it.

If the app cannot reach the backend, screens show an error such as "Failed to load campaigns." Check that the backend is running and that `API_BASE_URL` is correct for your device before debugging the app.

### Testing in Chrome against dev

The dev backend runs at **https://api.dev.xeasify.com** (`xeasify-core`, deployed automatically from its `main`). From the repo root in PowerShell:

```powershell
.\tool\run_web_dev.ps1
# = flutter run -d chrome --web-port 5000 --dart-define=API_BASE_URL=https://api.dev.xeasify.com
```

- **Keep port 5000.** The dev API accepts browser calls only from `http://localhost:<port>` / `http://127.0.0.1:<port>` (CORS), and YouTube sign-in redirects back to `http://localhost:5000/oauth/youtube`.
- **Merchants** register with JOIN AS MERCHANT and sign in with email + password.
- **Creators** sign in on the web with **CONTINUE WITH YOUTUBE** only (Google's redirect flow through the backend; Instagram, Facebook and TikTok still need their mobile SDKs). This needs, once, on the backend side: `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` of a Google OAuth **web** client in the dev env secret, and `http://localhost:5000/oauth/youtube` in that client's **Authorized redirect URIs** (Google Cloud console → APIs & Services → Credentials).
- **Switching accounts:** there is no logout button yet. In Chrome: DevTools (F12) → Application → Storage → **Clear site data**, then reload.
- **Debugging a failed call:** every API response carries an `X-Request-ID` header (DevTools → Network → the request → Headers). Look it up in the backend's Cloud Logging (see `xeasify-core/docker/GCP.md`, "Dev: logs in Cloud Logging").
- Push notifications are off on the web (Firebase is mobile-only here); the location prompt is the browser's.

---

## 3. Running the app

| Goal | Command |
|---|---|
| Run in debug mode with hot reload | `flutter run` |
| Run against a specific backend | `flutter run --dart-define=API_BASE_URL=http://HOST:PORT` |
| Run in Chrome against dev | `.\tool\run_web_dev.ps1` |
| Build the web app | `flutter build web --dart-define=API_BASE_URL=https://HOST` (output in `build/web`) |
| Choose a device | `flutter devices`, then `flutter run -d <device-id>` |
| Build a debug APK | `flutter build apk --debug --dart-define=API_BASE_URL=http://HOST:PORT` |
| Find the APK | `build/app/outputs/flutter-apk/app-debug.apk` |

While `flutter run` is active: `r` = hot reload, `R` = hot restart, `q` = quit.

Release builds currently use the **debug signing key** (`android/app/build.gradle.kts`). Do not publish one to a store before adding a real signing config.

---

## 4. Project layout

```
lib/
├── main.dart                 App entry point (starts Riverpod, tries to start push notifications)
├── core/
│   ├── router.dart           All routes + login redirect rules (go_router)
│   ├── dio_client.dart       HTTP client, API base URL, automatic token refresh on 401
│   ├── secure_storage.dart   Stores tokens/role/user id securely on the device
│   └── theme.dart            Black and white light theme (white background, black text and borders)
├── data/                     One repository per API area (campaigns, proposals, escrow, ratings, ...)
├── features/                 One folder per area of the app, each holding its screens
│   ├── auth/                 Login, creator/merchant registration, auth state
│   ├── marketplace/          Campaign list and campaign detail (creator)
│   ├── proposals/            My proposals, submit proposal, negotiation (creator)
│   ├── deliverable/          Submit deliverable (creator)
│   ├── onboarding/           First-run app tour (separate slides for creators and merchants)
│   ├── pricing/              Pricing screen
│   ├── merchant/             Dashboard, campaigns list, create campaign, bids (merchant)
│   └── notifications/        Notification list
├── models/                   Data classes (campaign, proposal, notification)
├── services/
│   ├── fcm_service.dart      Firebase push notifications (optional)
│   ├── location_service.dart GPS check-in and the one-time permission prompt (optional)
│   └── tour_service.dart     Remembers whether the app tour was seen (per role) and opens it
└── widgets/                  Shared UI pieces (campaign card, status chip, loader, error, empty state, ...)

android/                      Android project (permissions live in app/src/main/AndroidManifest.xml)
test/                         Automated tests
.github/workflows/build.yml   CI: builds a debug APK on every push to main
.claude/skills/               Repo rules for AI-assisted work (see section 8)
CHANGELOG.md                  Log of every change, newest first
```

Where to start when changing something:

- **A screen's look or behaviour:** `lib/features/<area>/`
- **A new screen or route:** add the screen under `lib/features/`, then register it in `lib/core/router.dart`
- **A new API call:** add a method to the matching `lib/data/*_repository.dart`
- **A shared widget:** `lib/widgets/`
- **Colors and fonts:** `lib/core/theme.dart`

State management is **Riverpod**, navigation is **go_router**, and HTTP is **Dio**.

---

## 5. How the app works

**Starting up and logging in**

1. The app opens on `/login`.
2. After login, the access token, refresh token, role and user id are saved in secure storage. Next launch restores them automatically.
3. The router (`lib/core/router.dart`) redirects based on login state:
   - Not logged in → any page except login/registration sends you to `/login`.
   - Logged in, on a login/registration page → merchants go to `/merchant`, everyone else to `/marketplace`.
4. If an API call returns `401`, the HTTP client tries to refresh the token once and retries. If that fails, the saved session is cleared.

**Creator onboarding.** Creators progress through `social_linked` → `metrics_granted` → `verified` (`signupState` in `lib/features/auth/auth_provider.dart`). Only `verified` creators can see campaigns, and the marketplace shows an onboarding banner until then. To test the marketplace you need a creator account that is already verified on the backend.

**First-run app tour.** The first time a user opens their home screen (MARKET for creators, COMMAND CENTER for merchants) a short tour opens with 4 slides written for their role, with a SKIP button. It is shown once per role per install. The `?` icon in the top bar of both home screens replays it. On the marketplace the location explanation appears only after the tour is closed. Slide text lives in `lib/features/onboarding/app_tour_screen.dart`; update it when the flows change.

**Navigation.**

- Creators have three bottom tabs: **MARKET**, **BIDS**, **ALERTS**.
- Merchants have three bottom tabs: **COMMAND** (dashboard), **CAMPAIGNS**, **ALERTS**.

---

## 6. Permissions and optional features

Only the internet is required. Everything else is optional and the app is written to keep working if the user says no.

| Access | Required? | Behaviour |
|---|---|---|
| **Internet** | Yes | Needed for all data. |
| **Location** | No | On the first visit to the marketplace the app shows a short explanation, then asks for location. If allowed, it sends a GPS check-in on each marketplace open (used for nearby "flash campaign" matching). If declined, the app never asks again and works normally. Code: `lib/services/location_service.dart`. |
| **Push notifications** | No | Asked at startup. Needs Firebase config files (below). Without them the setup is skipped silently. Code: `lib/services/fcm_service.dart`. |

Android permissions are declared in `android/app/src/main/AndroidManifest.xml`. If you add a feature that needs a new permission, declare it there. For iOS, see the note in [Known issues](#9-known-issues).

**Firebase files are not in the repo.** `google-services.json`, `GoogleService-Info.plist` and `firebase_options.dart` are git-ignored because they are project secrets. You do not need them to develop. Ask the project owner if you must test push notifications.

**Re-testing the tour or the location prompt.** Both only show once per install. To see it again, uninstall the app or clear its storage (long-press the app icon → App info → Storage → Clear data), and make sure location permission is not already granted.

---

## 7. Testing your changes

Do these in order. Steps 1 and 2 take a minute. Step 3 is what proves your change works.

### Step 1: Static analysis (always)

```bash
flutter analyze
```

This must not report **new** errors or warnings caused by your change. Existing warnings are listed in [Known issues](#9-known-issues).

### Step 2: Automated tests

```bash
flutter test
```

All tests must pass. When you add tests, put them in `test/` and name files `*_test.dart`. `test/auth_test.dart` shows how to fake backend responses with a Dio `HttpClientAdapter`.

### Step 3: Try it on a device (manual test)

1. Start the backend and run the app (sections 2 and 3).
2. Log in with a **creator** account and run through the checks below.
3. Switch to a **merchant** account and repeat. The app has no logout button yet (`AuthNotifier.logout()` exists but no screen calls it), so clear the app's storage or reinstall it to sign in as someone else.
4. Always test the area you changed plus the **login → home** flow, since the router redirects affect everything.

**Creator checklist**

- [ ] First open shows the creator app tour (4 slides). SKIP and GET STARTED both close it, and it does not reappear. The `?` icon in the top bar replays it.
- [ ] After the tour closes, the location explanation dialog appears (first install only).
- [ ] Login lands on **MARKET** and the campaign list loads.
- [ ] Category filters change the list.
- [ ] Opening a campaign shows its detail; "apply" opens the proposal form.
- [ ] **BIDS** shows your proposals; opening one reaches negotiation.
- [ ] **ALERTS** loads notifications.
- [ ] Kill and reopen the app. You should still be logged in.

**Merchant checklist**

- [ ] First open shows the merchant app tour (4 slides) once. The `?` icon replays it.
- [ ] Login lands on **COMMAND** (dashboard).
- [ ] **CAMPAIGNS** lists campaigns; "new" opens the create-campaign form.
- [ ] Opening a campaign's bids works.
- [ ] **ALERTS** loads notifications.

**Failure checks (worth doing when you touch networking or screens)**

- [ ] Stop the backend and open a screen. You should see an error message with no crash.
- [ ] Deny location. The app should keep working.
- [ ] Clear the app's storage. You should land on `/login` and not be able to open other pages without signing in.

### Step 4: Check the CI build

Every push to `main` runs `.github/workflows/build.yml`, which builds a debug APK and uploads it as a workflow artifact (kept for 7 days). Open the **Actions** tab on GitHub after you push and confirm it is green. You can download the APK from the run to try the exact build.

---

## 8. Contribution rules

These rules are enforced through the skills in `.claude/skills/` and apply to humans and AI assistants alike.

1. **Read `CHANGELOG.md` first.** It shows what was already done and why.
2. **Work and push on `main` only.** Do not create or push other branches or open PRs from them. Never force-push. If a push is rejected: `git pull --rebase origin main`, then push again.
3. **Every change gets a `CHANGELOG.md` entry**, added at the **top** and committed together with the change:

   ```
   ## YYYY-MM-DD — <short title>
   - What changed: <files / behaviour>
   - Why: <reason>
   ```

4. **After any run (install, build, test, analyze, codegen):** run `git status --short`.
   - Needed files (source, config, lockfiles, tests, docs, changelog) → commit them.
   - Generated or machine-specific files (build output, caches, IDE files, logs) → do not commit them. Add them to `.gitignore`.
   - **Never commit secrets** (`.env`, keys, Firebase config files).
5. Commits use your own git identity, with no AI co-author trailer.

---

## 9. Known issues

These are documented so you don't waste time on them:

- **Creator sign-in needs native SDKs on mobile.** Instagram, Facebook, TikTok and (on Android) YouTube buttons show "sign-in SDK not yet configured". On the web, YouTube works through the backend's Google redirect flow (section 2).
- **Location check-in calls a removed endpoint.** `LocationService` still posts to `/geo/checkin/`, which the backend no longer has (it now uses a declared base, `/geo/base/`); the 404 is swallowed. The location prompt is therefore not needed until the base screen exists.
- **Two `unnecessary_cast` analyzer warnings** in `lib/features/marketplace/marketplace_screen.dart` (existing, harmless).
- **Push notifications probably never activate.** `FCMService` never calls `Firebase.initializeApp()`, and the Android Gradle files do not apply the Google Services plugin. The error is swallowed, so nothing visibly breaks, but no push token is registered. This needs fixing before push can work.
- **CI and local toolchains differ.** CI pins Flutter `3.24.x`, while the Android project uses a newer toolchain (Android Gradle Plugin 9.0.1, Kotlin 2.3.20). If the CI build fails with a Gradle or Kotlin version error, update the version in `build.yml` first.
- **No iOS project.** To add it: `flutter create --platforms=ios .` on a Mac with Xcode, then add `NSLocationWhenInUseUsageDescription` to `ios/Runner/Info.plist` (Apple rejects apps that use location without it).
- **No logout button.** `AuthNotifier.logout()` exists, but no screen calls it. To switch accounts, clear the app's storage or reinstall.
- **Release builds are debug-signed.** See section 3.
