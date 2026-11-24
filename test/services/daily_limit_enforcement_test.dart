import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mathmunch/core/router/app_router.dart';
import 'package:mathmunch/data/local/hive_service.dart';
import 'package:mathmunch/data/models/child_profile.dart';
import 'package:mathmunch/data/models/parent_account.dart';
import 'package:mathmunch/data/repositories/auth_repository.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/data/repositories/progress_repository.dart';
import 'package:mathmunch/features/gameplay/gameplay_screen.dart';
import 'package:mathmunch/features/gameplay/providers/gameplay_provider.dart';
import 'package:mathmunch/features/settings/providers/settings_provider.dart';
import 'package:mathmunch/shared/services/audio_service.dart';
import 'package:mathmunch/shared/services/narration_service.dart';

class _Auth extends AuthRepository {
  @override
  AuthState build() => AuthState(
        parentAccount: ParentAccount(
          id: 'parent',
          email: 'test@example.com',
          passwordHash: 'unused',
          parentPin: 'unused',
          childProfileIds: ['child'],
          createdAt: DateTime(2026),
        ),
      );
}

class _Child extends ActiveChildNotifier {
  @override
  ChildProfile build() => ChildProfile(
        id: 'child',
        name: 'Test',
        age: 4,
        avatarId: 'avatar_cat',
        parentAccountId: 'parent',
      );
}

class _Settings extends SettingsNotifier {
  @override
  AppSettings build() =>
      const AppSettings(dailyTimeLimitMinutes: 5, hintsAlwaysOn: true);
}

class _Narration extends NarrationService {
  @override
  Future<void> speak(String text) async {}
  @override
  Future<void> stop() async {}
}

class _DelayedFeedbackNarration extends _Narration {
  final feedback = Completer<void>();

  @override
  Future<void> speak(String text) =>
      text == 'Amazing! Well done!' ? feedback.future : Future.value();
}

class _Audio extends AudioService {
  @override
  Future<void> playCorrect() async {}
}

class _MemoryProgress extends ProgressRepository {
  int seconds = 0;
  @override
  int secondsPlayedToday(String childId, {DateTime? at}) => seconds;
  @override
  Future<void> recordPlaySecond(String childId, {DateTime? at}) async {
    seconds++;
  }
}

void main() {
  late Directory directory;
  late ProviderContainer container;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mathmunch-daily-limit-');
    Hive.init(directory.path);
    await HiveService.registerAdapters();
    await HiveService.openBoxes();
  });

  setUp(() {
    container = ProviderContainer(overrides: [
      authStateProvider.overrideWith(_Auth.new),
      activeChildProvider.overrideWith(_Child.new),
      settingsProvider.overrideWith(_Settings.new),
      narrationServiceProvider.overrideWithValue(_Narration()),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await HiveService.progressBox.clear();
    await HiveService.sessionsBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('daily usage survives reopening storage and resets on the next day',
      () async {
    final progress = container.read(progressRepositoryProvider);
    final beforeMidnight = DateTime(2026, 11, 10, 23, 59, 59);
    final nextDay = DateTime(2026, 11, 11);
    await progress.recordPlaySecond('child', at: beforeMidnight);
    await HiveService.progressBox.close();
    await HiveService.openBoxes();
    expect(progress.secondsPlayedToday('child', at: beforeMidnight), 1);
    expect(progress.secondsPlayedToday('child', at: nextDay), 0);
    await progress.recordPlaySecond('child', at: nextDay);
    expect(progress.secondsPlayedToday('child', at: nextDay), 1);
    expect(progress.secondsPlayedToday('child', at: beforeMidnight), 1);
    expect(progress.secondsPlayedToday('other', at: nextDay), 0);
    expect(progress.levelStarsForChild('child'), isEmpty);
    await progress.resetAllProgress('child');
    expect(progress.secondsPlayedToday('child', at: nextDay), 0);
  });

  test('completed sessions migrate once and are not double-counted', () async {
    final progress = container.read(progressRepositoryProvider);
    Future<void> save(int seconds) async {
      await progress.saveSession(
        childId: 'child',
        levelId: 'af_level_1',
        worldId: 'world_apple_farm',
        worldName: 'Apple Farm',
        levelTitle: 'Count to 3',
        accuracy: 1,
        starsEarned: 3,
        durationSeconds: seconds,
      );
    }

    await save(299);
    expect(progress.secondsPlayedToday('child'), 299);
    await progress.recordPlaySecond('child');
    await save(1);
    expect(progress.secondsPlayedToday('child'), 300);
  });

  testWidgets('route blocks at the boundary and refreshes cached usage',
      (tester) async {
    final router = container.read(appRouterProvider);
    addTearDown(router.dispose);
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (value) {
      context = value;
      return const SizedBox();
    })));
    Future<String> navigate(String location) async {
      router.go(location);
      final match = await router.routeInformationParser
          .parseRouteInformationWithDependencies(
              router.routeInformationProvider.value, context);
      return match.uri.path;
    }

    final progress = container.read(progressRepositoryProvider);
    await tester.runAsync(() async {
      for (var i = 0; i < 299; i++) {
        await progress.recordPlaySecond('child');
      }
    });
    expect(await navigate('/gameplay/af_level_1'), '/gameplay/af_level_1');
    await tester.runAsync(() => progress.recordPlaySecond('child'));
    expect(await navigate('/gameplay/af_level_1'), AppRoutes.timeLimit);
    expect(await navigate('/gameplay/af_level_2'), AppRoutes.timeLimit);
    expect(await navigate(AppRoutes.settings), AppRoutes.settings);
    await tester.runAsync(() => HiveService.progressBox.clear());
    expect(await navigate('/gameplay/af_level_1'), '/gameplay/af_level_1');
    await tester.pump();
  });

  testWidgets('unfinished play counts; paused and disposed play do not',
      (tester) async {
    final progress = _MemoryProgress();
    final container = ProviderContainer(overrides: [
      activeChildProvider.overrideWith(_Child.new),
      settingsProvider.overrideWith(_Settings.new),
      narrationServiceProvider.overrideWithValue(_Narration()),
      progressRepositoryProvider.overrideWithValue(progress),
    ]);
    addTearDown(container.dispose);
    final provider = gameplayProvider('af_level_1');
    final subscription = container.listen(provider, (_, __) {});
    final notifier = container.read(provider.notifier);
    notifier.startQuestion();
    await tester.pump(const Duration(seconds: 3));
    expect(progress.secondsPlayedToday('child'), 3);
    expect(container.read(provider).elapsedSeconds, 3);
    expect(HiveService.sessionsBox.isEmpty, true);
    notifier.pause();
    await tester.pump(const Duration(seconds: 10));
    expect(progress.secondsPlayedToday('child'), 3);
    notifier.resume();
    await tester.pump(const Duration(seconds: 2));
    expect(progress.secondsPlayedToday('child'), 5);
    subscription.close();
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(progress.secondsPlayedToday('child'), 5);
  });

  testWidgets('feedback finishes before advancing, even after the delay',
      (tester) async {
    final narration = _DelayedFeedbackNarration();
    final scope = ProviderContainer(overrides: [
      activeChildProvider.overrideWith(_Child.new),
      settingsProvider.overrideWith(_Settings.new),
      narrationServiceProvider.overrideWithValue(narration),
      audioServiceProvider.overrideWithValue(_Audio()),
      progressRepositoryProvider.overrideWithValue(_MemoryProgress()),
    ]);
    addTearDown(scope.dispose);
    final provider = gameplayProvider('af_level_1');
    final subscription = scope.listen(provider, (_, __) {});
    addTearDown(subscription.close);
    final notifier = scope.read(provider.notifier);
    notifier.startQuestion();
    final submitted =
        notifier.submitAnswer(scope.read(provider).currentQuestion!.correctIndex);
    await tester.pump(const Duration(seconds: 2));
    expect(scope.read(provider).currentIndex, 0);
    narration.feedback.complete();
    await tester.pump();
    await submitted;
    expect(scope.read(provider).currentIndex, 1);
    notifier.pause();
  });

  testWidgets('finishing feedback after disposal does not advance',
      (tester) async {
    final narration = _DelayedFeedbackNarration();
    final scope = ProviderContainer(overrides: [
      activeChildProvider.overrideWith(_Child.new),
      settingsProvider.overrideWith(_Settings.new),
      narrationServiceProvider.overrideWithValue(narration),
      audioServiceProvider.overrideWithValue(_Audio()),
      progressRepositoryProvider.overrideWithValue(_MemoryProgress()),
    ]);
    addTearDown(scope.dispose);
    final provider = gameplayProvider('af_level_1');
    final subscription = scope.listen(provider, (_, __) {});
    final notifier = scope.read(provider.notifier);
    notifier.startQuestion();
    final submitted =
        notifier.submitAnswer(scope.read(provider).currentQuestion!.correctIndex);
    subscription.close();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    narration.feedback.complete();
    await tester.pump();
    await submitted;
    expect(tester.takeException(), isNull);
  });

  testWidgets('gameplay screen pauses on background and resumes on foreground',
      (tester) async {
    final progress = _MemoryProgress();
    final scope = ProviderContainer(overrides: [
      activeChildProvider.overrideWith(_Child.new),
      settingsProvider.overrideWith(_Settings.new),
      narrationServiceProvider.overrideWithValue(_Narration()),
      progressRepositoryProvider.overrideWithValue(progress),
    ]);
    addTearDown(scope.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: scope,
      child: const MaterialApp(home: GameplayScreen(levelId: 'af_level_1')),
    ));
    await tester.pump(const Duration(seconds: 2));
    expect(progress.seconds, 2);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 30));
    expect(progress.seconds, 2);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 2));
    expect(progress.seconds, 4);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    expect(progress.seconds, 4);
  });
}
