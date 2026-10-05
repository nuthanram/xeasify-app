import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Web: /marketplace instead of /#/marketplace, so OAuth redirects back to
  // /oauth/youtube?code=… reach the router. No effect on mobile.
  usePathUrlStrategy();
  // Firebase not supported on web without web-specific config
  if (!kIsWeb) {
    await FCMService.initializeIfAvailable();
  }
  runApp(const ProviderScope(child: XeasifyApp()));
}

class XeasifyApp extends ConsumerWidget {
  const XeasifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Xeasify',
      theme: xeasifyTheme(),
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
