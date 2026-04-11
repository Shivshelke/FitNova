import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers/auth_provider.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/onboarding_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/signup_screen.dart';
import '../ui/screens/auth/profile_setup_screen.dart';
import '../ui/screens/workout/workout_detail_screen.dart';
import '../ui/screens/diet/food_search_screen.dart';
import '../ui/main_screen.dart';

// Route name constants
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String workoutDetail = '/workout/:id';
  static const String foodSearch = '/food-search';
}

/// App Router Provider
/// Handles auth-based redirects - unauthenticated users go to login
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.onboarding;

      // If user is not logged in and not on an auth route, redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }
      // If user is logged in and going to auth route, redirect to home
      if (isLoggedIn && (state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutDetail,
        builder: (context, state) {
          final workoutId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return WorkoutDetailScreen(workoutId: workoutId, workoutData: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.foodSearch,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return FoodSearchScreen(mealType: extra?['mealType'] ?? 'snack');
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.error}'),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
