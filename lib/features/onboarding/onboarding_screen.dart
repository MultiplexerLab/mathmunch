import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/router/app_router.dart';
import 'package:mathmunch/data/repositories/auth_repository.dart';
import 'package:mathmunch/features/onboarding/providers/onboarding_provider.dart';
import 'package:mathmunch/shared/widgets/pin_pad.dart';

/// SCR-02 — Parent account creation (email + password + PIN).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _pin = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            24, 24, 24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: state.step == 0
              ? _AccountStep(
                  formKey: _formKey,
                  emailCtrl: _emailCtrl,
                  passCtrl: _passCtrl,
                  error: state.error,
                  isLoading: state.isLoading,
                  onNext: () async {
                    if (!_formKey.currentState!.validate()) return;
                    notifier.setEmail(_emailCtrl.text);
                    notifier.setPassword(_passCtrl.text);
                    notifier.nextStep();
                  },
                )
              : _PinStep(
                  pin: _pin,
                  error: state.error,
                  isLoading: state.isLoading,
                  onDigit: (d) {
                    if (_pin.length < 4) setState(() => _pin += d);
                  },
                  onDelete: () {
                    if (_pin.isNotEmpty) {
                      setState(() => _pin = _pin.substring(0, _pin.length - 1));
                    }
                  },
                  onConfirm: () async {
                    if (_pin.length < 4) return;
                    notifier.setLoading(true);
                    try {
                      await ref.read(authStateProvider.notifier).register(
                            email: state.email,
                            password: state.password,
                            pin: _pin,
                          );
                      if (context.mounted) context.go(AppRoutes.childSetup);
                    } catch (e) {
                      notifier.setError(e.toString());
                    } finally {
                      notifier.setLoading(false);
                    }
                  },
                ),
        ),
      ),
    );
  }
}

class _AccountStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final String? error;
  final bool isLoading;
  final VoidCallback onNext;

  const _AccountStep({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    this.error,
    required this.isLoading,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Parent Account',
                  style: Theme.of(context).textTheme.displayMedium)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.15, end: 0, duration: 400.ms),
          const SizedBox(height: 8),
          Text('No social login — email and password only.',
                  style: Theme.of(context).textTheme.bodyMedium)
              .animate()
              .fadeIn(delay: 120.ms, duration: 350.ms),
          const SizedBox(height: 32),
          TextFormField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
          )
              .animate()
              .fadeIn(delay: 220.ms, duration: 380.ms)
              .slideY(begin: 0.1, end: 0, delay: 220.ms, duration: 380.ms),
          const SizedBox(height: 16),
          TextFormField(
            controller: passCtrl,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (v) =>
                v != null && v.length >= 8 ? null : 'Minimum 8 characters',
          )
              .animate()
              .fadeIn(delay: 320.ms, duration: 380.ms)
              .slideY(begin: 0.1, end: 0, delay: 320.ms, duration: 380.ms),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: AppColors.incorrect)),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: isLoading ? null : onNext,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Next: Set Parent PIN'),
          ).animate().fadeIn(delay: 450.ms, duration: 350.ms),
        ],
      ),
    );
  }
}

class _PinStep extends StatelessWidget {
  final String pin;
  final String? error;
  final bool isLoading;
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final VoidCallback onConfirm;

  const _PinStep({
    required this.pin,
    this.error,
    required this.isLoading,
    required this.onDigit,
    required this.onDelete,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Set Parent PIN',
                style: Theme.of(context).textTheme.displayMedium)
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.15, end: 0, duration: 400.ms),
        const SizedBox(height: 8),
        Text('A 4-digit PIN protects parent-only screens.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center)
            .animate()
            .fadeIn(delay: 120.ms, duration: 350.ms),
        const SizedBox(height: 32),
        PinPad(currentPin: pin, onDigit: onDigit, onDelete: onDelete)
            .animate()
            .fadeIn(delay: 220.ms, duration: 380.ms)
            .slideY(begin: 0.1, end: 0, delay: 220.ms, duration: 380.ms),
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(error!, style: const TextStyle(color: AppColors.incorrect)),
        ],
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: pin.length < 4 || isLoading ? null : onConfirm,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Create Account'),
        ).animate().fadeIn(delay: 350.ms, duration: 350.ms),
      ],
    );
  }
}
