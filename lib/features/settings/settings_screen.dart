import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/constants/app_constants.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/data/repositories/progress_repository.dart';
import 'package:mathmunch/features/settings/providers/settings_provider.dart';

/// SCR-10 — Settings: time limits, sound, avatar, account, reset. FR-40 to FR-45.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final child = ref.watch(activeChildProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ---- Child Profile ----
          const _Section('Child Profile'),
          if (child != null) ...[
            ListTile(
              title: const Text('Name'),
              subtitle: Text(child.name),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editName(context, ref, child.name),
            ),
            ListTile(
              title: const Text('Age'),
              subtitle: Text('${child.age} years old'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editAge(context, ref, child.age),
            ),
          ],

          // ---- Sound ----
          const _Section('Sound'),
          SwitchListTile(
            title: const Text('Sound Effects'),
            value: settings.sfxEnabled,
            onChanged: (v) => notifier.setSfx(v),
            secondary: const Icon(Icons.volume_up_outlined),
          ),
          SwitchListTile(
            title: const Text('Read Questions Aloud'),
            subtitle: const Text('Voice narrates each question and feedback'),
            value: settings.narrationEnabled,
            onChanged: (v) => notifier.setNarration(v),
            secondary: const Icon(Icons.record_voice_over_outlined),
          ),

          // ---- Gameplay ----
          const _Section('Gameplay'),
          SwitchListTile(
            title: const Text('Hints Always On'),
            subtitle: const Text(
                'Show mascot hints immediately after each question'),
            value: settings.hintsAlwaysOn,
            onChanged: (v) => notifier.setHintsAlwaysOn(v),
            secondary: const Icon(Icons.lightbulb_outline),
          ),

          // ---- Account ----
          const _Section('Account'),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email Address'),
            subtitle: const Text('Tap to update'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {}, // FR-45 — editable with re-verification
          ),

          // FR-44 — Reset progress
          const _Section('Danger Zone'),
          ListTile(
            leading: const Icon(Icons.restart_alt, color: AppColors.incorrect),
            title: const Text('Reset Progress',
                style: TextStyle(color: AppColors.incorrect)),
            subtitle: const Text('This cannot be undone'),
            onTap: () => _confirmReset(context, ref, child?.id),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(
      BuildContext context, WidgetRef ref, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit child's name"),
        content: SingleChildScrollView(child: TextField(controller: ctrl)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      final child = ref.read(activeChildProvider);
      if (child == null) return;
      ref.read(childListProvider.notifier).updateChild(
            child.copyWith(name: result.trim()),
          );
    }
    ctrl.dispose();
  }

  Future<void> _editAge(
      BuildContext context, WidgetRef ref, int current) async {
    int selected = current;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Edit child's age"),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              AppConstants.maxChildAge - AppConstants.minChildAge + 1,
              (i) {
                final age = AppConstants.minChildAge + i;
                return GestureDetector(
                  onTap: () => setState(() => selected = age),
                  child: CircleAvatar(
                    backgroundColor:
                        selected == age ? AppColors.primary : AppColors.surfaceVariant,
                    child: Text('$age',
                        style: TextStyle(
                            color: selected == age ? Colors.white : null)),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final child = ref.read(activeChildProvider);
                if (child != null) {
                  ref.read(childListProvider.notifier).updateChild(
                        child.copyWith(age: selected),
                      );
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(
      BuildContext context, WidgetRef ref, String? childId) async {
    if (childId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset all progress?'),
        content: const Text(
            'All stars, stickers, and session history will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.incorrect),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(progressRepositoryProvider).resetAllProgress(childId);
      await ref.read(childListProvider.notifier).resetProgress(childId);
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}
