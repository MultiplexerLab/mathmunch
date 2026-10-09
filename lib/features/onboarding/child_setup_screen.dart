import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/constants/app_constants.dart';
import 'package:mathmunch/core/router/app_router.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';

/// SCR-02 — Child profile creation (name, age, avatar). FR-03, FR-04.
class ChildSetupScreen extends ConsumerStatefulWidget {
  const ChildSetupScreen({super.key});

  @override
  ConsumerState<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends ConsumerState<ChildSetupScreen> {
  final _nameCtrl = TextEditingController();
  int _selectedAge = 4;
  String _selectedAvatar = 'avatar_cat';
  bool _isLoading = false;

  static const _avatars = [
    ('avatar_cat', '🐱'),
    ('avatar_dog', '🐶'),
    ('avatar_bunny', '🐰'),
    ('avatar_bear', '🐻'),
    ('avatar_fox', '🦊'),
    ('avatar_penguin', '🐧'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(childListProvider.notifier).createChild(
            name: _nameCtrl.text,
            age: _selectedAge,
            avatarId: _selectedAvatar,
          );
      if (mounted) context.go(AppRoutes.home);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Who's playing?")),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            24, 24, 24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Child's Name",
                      style: Theme.of(context).textTheme.titleMedium)
                  .animate()
                  .fadeIn(duration: 350.ms),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Lily',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ).animate().fadeIn(delay: 100.ms, duration: 350.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    delay: 100.ms,
                    duration: 350.ms,
                  ),

              const SizedBox(height: 24),
              Text('Age', style: Theme.of(context).textTheme.titleMedium)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 350.ms),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(
                  AppConstants.maxChildAge - AppConstants.minChildAge + 1,
                  (i) {
                    final age = AppConstants.minChildAge + i;
                    final selected = age == _selectedAge;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAge = age),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$age',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (220 + i * 55).ms, duration: 300.ms)
                        .scaleXY(
                          begin: 0.6,
                          end: 1.0,
                          delay: (220 + i * 55).ms,
                          duration: 400.ms,
                          curve: Curves.elasticOut,
                        );
                  },
                ),
              ),

              const SizedBox(height: 24),
              Text('Pick an Avatar',
                      style: Theme.of(context).textTheme.titleMedium)
                  .animate()
                  .fadeIn(delay: 450.ms, duration: 350.ms),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: _avatars.asMap().entries.map((e) {
                  final i = e.key;
                  final (id, emoji) = e.value;
                  final selected = id == _selectedAvatar;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = id),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.surfaceVariant,
                        border: selected
                            ? Border.all(color: AppColors.primary, width: 3)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 40)),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (500 + i * 70).ms, duration: 300.ms)
                      .scaleXY(
                        begin: 0.6,
                        end: 1.0,
                        delay: (500 + i * 70).ms,
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      );
                }).toList(),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Let's Go! 🚀"),
              ).animate().fadeIn(delay: 750.ms, duration: 350.ms).slideY(
                    begin: 0.15,
                    end: 0,
                    delay: 750.ms,
                    duration: 350.ms,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
