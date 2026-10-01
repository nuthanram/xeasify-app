import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase optional — app works without google-services.json in dev
  await FCMService.initializeIfAvailable();
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
