import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/data/models/session_result.dart';
import 'package:mathmunch/shared/widgets/star_rating.dart';

class ActivityFeedItem extends StatelessWidget {
  final SessionResult session;

  const ActivityFeedItem({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM').format(session.playedAt);
    final duration = '${session.durationSeconds ~/ 60}m ${session.durationSeconds % 60}s';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.worldName,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary, fontSize: 12),
                ),
                Text(
                  session.levelTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$dateStr · $duration · ${(session.accuracy * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          StarRating(stars: session.starsEarned, size: 20),
        ],
      ),
    );
  }
}
