import 'package:flutter/material.dart';
import 'package:mathmunch/core/constants/app_colors.dart';

class TopicProgressBar extends StatelessWidget {
  final String topic;
  final int completed;
  final int total;

  const TopicProgressBar({
    super.key,
    required this.topic,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Text(_topicEmoji(topic), style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        _topicLabel(topic),
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$completed/$total levels',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: AppColors.surfaceVariant,
                    color: _topicColor(topic),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _topicLabel(String t) => switch (t) {
        'counting' => 'Counting',
        'addition' => 'Addition',
        'shapes' => 'Shapes',
        'subtraction' => 'Subtraction',
        _ => t,
      };

  String _topicEmoji(String t) => switch (t) {
        'counting' => '🍎',
        'addition' => '➕',
        'shapes' => '🔷',
        'subtraction' => '➖',
        _ => '📚',
      };

  Color _topicColor(String t) => switch (t) {
        'counting' => AppColors.worldAppleFarm,
        'addition' => AppColors.worldOceanCount,
        'shapes' => AppColors.worldSpaceShapes,
        'subtraction' => AppColors.worldJungleMath,
        _ => AppColors.primary,
      };
}
