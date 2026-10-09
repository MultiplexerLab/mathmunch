import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathmunch/features/onboarding/providers/onboarding_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('OnboardingNotifier initial state', () {
    test('step starts at 0', () {
      expect(container.read(onboardingProvider).step, 0);
    });

    test('email starts empty', () {
      expect(container.read(onboardingProvider).email, '');
    });

    test('password starts empty', () {
      expect(container.read(onboardingProvider).password, '');
    });

    test('pin starts empty', () {
      expect(container.read(onboardingProvider).pin, '');
    });

    test('isLoading starts false', () {
      expect(container.read(onboardingProvider).isLoading, false);
    });

    test('error starts null', () {
      expect(container.read(onboardingProvider).error, isNull);
    });
  });

  group('OnboardingNotifier.setEmail', () {
    test('updates email field', () {
      container.read(onboardingProvider.notifier).setEmail('parent@example.com');
      expect(container.read(onboardingProvider).email, 'parent@example.com');
    });

    test('does not affect other fields', () {
      container.read(onboardingProvider.notifier).setPassword('pass123');
      container.read(onboardingProvider.notifier).setEmail('new@example.com');
      expect(container.read(onboardingProvider).password, 'pass123');
      expect(container.read(onboardingProvider).pin, '');
    });
  });

  group('OnboardingNotifier.setPassword', () {
    test('updates password field', () {
      container.read(onboardingProvider.notifier).setPassword('securepass');
      expect(container.read(onboardingProvider).password, 'securepass');
    });
  });

  group('OnboardingNotifier.setPin', () {
    test('updates pin field', () {
      container.read(onboardingProvider.notifier).setPin('1234');
      expect(container.read(onboardingProvider).pin, '1234');
    });
  });

  group('OnboardingNotifier.nextStep', () {
    test('increments step from 0 to 1', () {
      container.read(onboardingProvider.notifier).nextStep();
      expect(container.read(onboardingProvider).step, 1);
    });

    test('increments step twice to reach 2', () {
      container.read(onboardingProvider.notifier).nextStep();
      container.read(onboardingProvider.notifier).nextStep();
      expect(container.read(onboardingProvider).step, 2);
    });
  });

  group('OnboardingNotifier.setError', () {
    test('sets an error message', () {
      container.read(onboardingProvider.notifier).setError('Something went wrong');
      expect(container.read(onboardingProvider).error, 'Something went wrong');
    });

    test('clears error when set to null', () {
      container.read(onboardingProvider.notifier).setError('oops');
      container.read(onboardingProvider.notifier).setError(null);
      expect(container.read(onboardingProvider).error, isNull);
    });
  });

  group('OnboardingNotifier.setLoading', () {
    test('sets isLoading to true', () {
      container.read(onboardingProvider.notifier).setLoading(true);
      expect(container.read(onboardingProvider).isLoading, true);
    });

    test('sets isLoading back to false', () {
      container.read(onboardingProvider.notifier).setLoading(true);
      container.read(onboardingProvider.notifier).setLoading(false);
      expect(container.read(onboardingProvider).isLoading, false);
    });
  });

  group('OnboardingState.copyWith', () {
    test('null error clears the existing error', () {
      container.read(onboardingProvider.notifier).setError('error msg');
      final copy = container.read(onboardingProvider).copyWith(error: null);
      expect(copy.error, isNull);
    });

    test('preserves other fields when only step changes', () {
      container.read(onboardingProvider.notifier).setEmail('a@b.com');
      container.read(onboardingProvider.notifier).setPassword('pw');
      container.read(onboardingProvider.notifier).setPin('0000');
      final copy = container.read(onboardingProvider).copyWith(step: 1);
      expect(copy.email, 'a@b.com');
      expect(copy.password, 'pw');
      expect(copy.pin, '0000');
      expect(copy.step, 1);
    });
  });
}
