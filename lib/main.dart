import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mathmunch/app.dart';
import 'package:mathmunch/data/local/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive for offline-first local storage
  await Hive.initFlutter();
  await HiveService.registerAdapters();
  await HiveService.openBoxes();

  runApp(
    const ProviderScope(
      child: MathMunchApp(),
    ),
  );
}
