import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/router/app_router.dart';
import 'package:mathmunch/features/home/providers/home_provider.dart';

/// FR-07, FR-08 — World card with progress bar and lock state.
class WorldCard extends StatelessWidget {
  final WorldCardData data;

  const WorldCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final world = data.world;
    final locked = !data.isUnlocked;
    final color = Color(world.colorValue);

    return GestureDetector(
      onTap: locked
          ? null
          : () => context.push(
                AppRoutes.levelSelect.replaceFirst(':worldId', world.id),
              ),
      child: Opacity(
        opacity: locked ? 0.55 : 1.0,
        child: Container(
          constraints: const BoxConstraints(minHeight: 110),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            children: [
              // World icon area
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(18)),
                ),
                alignment: Alignment.center,
                child: locked
                    ? const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 36)
                    : Text(
                        _topicEmoji(world.topic),
                        style: const TextStyle(fontSize: 44),
                      ),
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        world.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        world.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: data.completionPercent,
                          backgroundColor: Colors.black12,
                          color: color,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(data.completionPercent * 100).toInt()}% complete',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              if (locked)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.lock_rounded,
                      color: AppColors.locked, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _topicEmoji(String topic) {
    return switch (topic) {
      'counting' => '🍎',
      'addition' => '🐟',
      'shapes' => '⭐',
      'subtraction' => '🐒',
      'multiplication' => '🚀',
      'division' => '💎',
      _ => '🎮',
    };
  }
}
