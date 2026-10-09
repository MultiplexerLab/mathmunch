import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/data/models/sticker.dart';
import 'package:mathmunch/shared/services/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FR-29, FR-30 — Sticker item: full colour if earned, silhouette if locked.
class StickerItem extends ConsumerWidget {
  final Sticker sticker;
  final bool isEarned;

  const StickerItem({super.key, required this.sticker, required this.isEarned});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: isEarned
          ? () => ref.read(audioServiceProvider).playStickerPop()
          : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isEarned
              ? AppColors.surfaceVariant
              : Colors.black.withValues(alpha: 0.06),
        ),
        child: isEarned
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 32))
                      .animate()
                      .fadeIn(duration: 300.ms),
                  Text(
                    sticker.name,
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : const Center(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black26,
                    BlendMode.srcIn,
                  ),
                  child: Text('⭐', style: TextStyle(fontSize: 32)),
                ),
              ),
      ),
    );
  }
}
