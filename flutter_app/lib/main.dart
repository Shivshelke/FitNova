import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style (for dark mode status bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // ProviderScope is required for Riverpod
    const ProviderScope(
      child: FitNovaApp(),
    ),
  );
}

/// Root application widget
class FitNovaApp extends ConsumerWidget {
  const FitNovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the app router (handles auth-based routing)
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FitNova',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode

      // Router config (go_router)
      routerConfig: router,
    );
  }
}
