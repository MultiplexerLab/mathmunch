import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mathmunch/data/repositories/auth_repository.dart';
import 'package:mathmunch/features/gameplay/gameplay_screen.dart';
import 'package:mathmunch/features/home/home_screen.dart';
import 'package:mathmunch/features/level_select/level_select_screen.dart';
import 'package:mathmunch/features/onboarding/child_setup_screen.dart';
import 'package:mathmunch/features/onboarding/onboarding_screen.dart';
import 'package:mathmunch/features/parent_dashboard/parent_dashboard_screen.dart';
import 'package:mathmunch/features/parent_dashboard/parent_pin_screen.dart';
import 'package:mathmunch/features/progress/progress_screen.dart';
import 'package:mathmunch/features/reward/reward_screen.dart';
import 'package:mathmunch/features/settings/settings_screen.dart';
import 'package:mathmunch/features/splash/splash_screen.dart';
import 'package:mathmunch/features/sticker_book/sticker_book_screen.dart';

// Route names
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const childSetup = '/onboarding/child-setup';
  static const home = '/home';
  static const levelSelect = '/level-select/:worldId';
  static const gameplay = '/gameplay/:levelId';
  static const reward = '/reward/:levelId';
  static const stickerBook = '/sticker-book';
  static const progress = '/progress';
  static const parentPin = '/parent-pin';
  static const parentDashboard = '/parent-dashboard';
  static const settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.hasParentAccount;
      final hasChildren =
          (authState.parentAccount?.childProfileIds ?? []).isNotEmpty;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.childSetup;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      if (isSplash) return null;
      if (!isLoggedIn && !isOnboarding) return AppRoutes.onboarding;
      if (isLoggedIn && !hasChildren &&
          state.matchedLocation != AppRoutes.childSetup) {
        return AppRoutes.childSetup;
      }
      if (isLoggedIn && hasChildren && isOnboarding) return AppRoutes.home;
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
        path: AppRoutes.childSetup,
        builder: (context, state) => const ChildSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.stickerBook,
            builder: (context, state) => const StickerBookScreen(),
          ),
          GoRoute(
            path: AppRoutes.progress,
            builder: (context, state) => const ProgressScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.levelSelect,
        builder: (context, state) => LevelSelectScreen(
          worldId: state.pathParameters['worldId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.gameplay,
        builder: (context, state) => GameplayScreen(
          levelId: state.pathParameters['levelId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.reward,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RewardScreen(
            levelId: state.pathParameters['levelId']!,
            starsEarned: extra?['stars'] as int? ?? 1,
            newStickerIds: (extra?['stickers'] as List<String>?) ?? [],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.parentPin,
        builder: (context, state) => const ParentPinScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentDashboard,
        builder: (context, state) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

// Bottom navigation shell
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int selectedIndex = 0;
    if (location == AppRoutes.stickerBook) selectedIndex = 1;
    if (location == AppRoutes.progress) selectedIndex = 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
            case 1:
              context.go(AppRoutes.stickerBook);
            case 2:
              context.go(AppRoutes.progress);
            case 3:
              context.go(AppRoutes.parentPin);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.auto_awesome), label: 'Stickers'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Progress'),
          NavigationDestination(
              icon: Icon(Icons.lock_outline), label: 'Parents'),
        ],
      ),
    );
  }
}
