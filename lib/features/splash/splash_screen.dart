import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/router/app_router.dart';
import 'package:mathmunch/data/repositories/auth_repository.dart';

/// SCR-01 — Splash screen with CTAs for child play and parent/new account.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAccount = ref.watch(authStateProvider).hasParentAccount;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              // Minimum height = viewport minus padding so mainAxisAlignment
              // works correctly; scroll kicks in only on very small devices.
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / mascot placeholder
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🍎', style: TextStyle(fontSize: 72)),
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  Text(
                    'MathMunch',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  Text(
                    'Fun maths for little learners!',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white70),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                  const SizedBox(height: 32),

                  // Primary CTA — child goes straight in
                  if (hasAccount) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => context.go(AppRoutes.home),
                      child: const Text("Let's Play! 🎮"),
                    ).animate().fadeIn(delay: 700.ms, duration: 300.ms),

                    const SizedBox(height: 16),
                  ],

                  // Parent / new account CTA
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => hasAccount
                        ? context.go(AppRoutes.parentPin)
                        : context.go(AppRoutes.onboarding),
                    child: Text(
                      hasAccount ? 'Parent Dashboard 🔒' : 'Set Up Account',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 300.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
