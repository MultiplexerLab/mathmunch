import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathmunch/features/parent_dashboard/providers/parent_dashboard_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('PinGateNotifier', () {
    test('initial state is locked (false)', () {
      expect(container.read(parentUnlockedProvider), false);
    });

    test('unlock() sets state to true', () {
      container.read(parentUnlockedProvider.notifier).unlock();
      expect(container.read(parentUnlockedProvider), true);
    });

    test('lock() resets state to false after unlock', () {
      container.read(parentUnlockedProvider.notifier).unlock();
      container.read(parentUnlockedProvider.notifier).lock();
      expect(container.read(parentUnlockedProvider), false);
    });

    test('multiple unlock() calls keep state true', () {
      container.read(parentUnlockedProvider.notifier).unlock();
      container.read(parentUnlockedProvider.notifier).unlock();
      expect(container.read(parentUnlockedProvider), true);
    });

    test('lock() on already locked state stays false', () {
      container.read(parentUnlockedProvider.notifier).lock();
      expect(container.read(parentUnlockedProvider), false);
    });
  });
}
