import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'services/fcm_service.dart';
import 'services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FCMService.initialize();
  runApp(const ProviderScope(child: XeasifyApp()));
}

class XeasifyApp extends ConsumerWidget {
  const XeasifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Xeasify',
      theme: xeasifyTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
