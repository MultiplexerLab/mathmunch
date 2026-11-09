import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/router/app_router.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/shared/widgets/mascot_widget.dart';

/// SCR-11 — Gentle end-of-session screen shown once the parent-configured
/// daily time limit has been reached. FR-41.
class TimeLimitScreen extends ConsumerWidget {
  const TimeLimitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MascotWidget(mood: MascotMood.happy, size: 100)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  child != null
                      ? 'Great job today, ${child.name}! 🌟'
                      : 'Great job today! 🌟',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
                const SizedBox(height: 12),
                Text(
                  "You've reached today's play time. Come back tomorrow "
                  'for more math fun!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white70),
                ).animate().fadeIn(delay: 350.ms, duration: 350.ms),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.secondary,
                  ),
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('OK 👋'),
                ).animate().fadeIn(delay: 500.ms, duration: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
