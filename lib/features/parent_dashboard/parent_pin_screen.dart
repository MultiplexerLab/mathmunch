import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/router/app_router.dart';
import 'package:mathmunch/data/repositories/auth_repository.dart';
import 'package:mathmunch/features/parent_dashboard/providers/parent_dashboard_provider.dart';
import 'package:mathmunch/shared/widgets/pin_pad.dart';

/// FR-35 — Parent PIN entry gate before any parent-facing screen.
class ParentPinScreen extends ConsumerStatefulWidget {
  const ParentPinScreen({super.key});

  @override
  ConsumerState<ParentPinScreen> createState() => _ParentPinScreenState();
}

class _ParentPinScreenState extends ConsumerState<ParentPinScreen> {
  String _pin = '';
  bool _error = false;

  void _onDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = false;
    });
    if (_pin.length == 4) _verify();
  }

  void _verify() {
    final correct = ref.read(authStateProvider.notifier).verifyPin(_pin);
    if (correct) {
      ref.read(parentUnlockedProvider.notifier).unlock();
      context.go(AppRoutes.parentDashboard);
    } else {
      setState(() {
        _pin = '';
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Area')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              // minHeight gives the Column real bounds so mainAxisAlignment
              // .center actually centres; scroll only activates on tiny screens.
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded,
                      size: 56, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Enter your PIN',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_error)
                    const Text(
                      'Incorrect PIN. Please try again.',
                      style: TextStyle(color: AppColors.incorrect),
                    ),
                  const SizedBox(height: 32),
                  PinPad(
                    currentPin: _pin,
                    onDigit: _onDigit,
                    onDelete: () {
                      if (_pin.isNotEmpty) {
                        setState(
                            () => _pin = _pin.substring(0, _pin.length - 1));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
