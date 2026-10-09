import 'package:hive_flutter/hive_flutter.dart';
import 'package:mathmunch/core/constants/app_constants.dart';
import 'package:mathmunch/data/models/child_profile.dart';
import 'package:mathmunch/data/models/parent_account.dart';
import 'package:mathmunch/data/models/session_result.dart';

class HiveService {
  HiveService._();

  static Future<void> registerAdapters() async {
    // Only register adapters for models that are actually persisted in Hive.
    // World, Level, Question, Sticker are seed content — never stored in boxes.
    Hive.registerAdapter(ParentAccountAdapter());
    Hive.registerAdapter(ChildProfileAdapter());
    Hive.registerAdapter(SessionResultAdapter());
  }

  static Future<void> openBoxes() async {
    await Future.wait([
      Hive.openBox<ParentAccount>(AppConstants.parentBoxName),
      Hive.openBox<ChildProfile>(AppConstants.childBoxName),
      Hive.openBox<SessionResult>(AppConstants.sessionsBoxName),
      Hive.openBox(AppConstants.progressBoxName),
      Hive.openBox(AppConstants.settingsBoxName),
    ]);
  }

  static Box<ParentAccount> get parentBox =>
      Hive.box<ParentAccount>(AppConstants.parentBoxName);

  static Box<ChildProfile> get childBox =>
      Hive.box<ChildProfile>(AppConstants.childBoxName);

  static Box<SessionResult> get sessionsBox =>
      Hive.box<SessionResult>(AppConstants.sessionsBoxName);

  static Box get progressBox => Hive.box(AppConstants.progressBoxName);

  static Box get settingsBox => Hive.box(AppConstants.settingsBoxName);
}
