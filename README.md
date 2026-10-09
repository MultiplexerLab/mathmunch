# MathMunch

MathMunch — Kids Math Gaming App for Ages 3–6

## Project Summary

**MathMunch** is a Flutter mobile app — a math learning game for kids aged 3–6.

**Stack:** Flutter 3.x / Dart 3.11, Riverpod (state), go_router (navigation), Hive (offline local storage), audioplayers + flutter_tts (audio/narration), flutter_animate. No backend — fully offline, local-first.

**Core concept:** Kids progress through themed "worlds" (Apple Farm → Ocean Count → Space Shapes → Jungle Math → Star Factory → Treasure Island), each teaching a math topic (counting → addition → shapes → subtraction → multiplication → division) via short levels of 5–8 tap-to-answer questions. Everything is voiced by a mascot (no reading required) — fits the pre-literate 3–6 target age.

**Key mechanics:**
- World unlocking gated at 60% completion of the prerequisite world.
- Star rating per level: 90%+ accuracy = 3 stars, 70%+ = 2 stars.
- Adaptive difficulty: drops a level after 2 consecutive levels under 70% accuracy.
- Sticker collection rewards per world, streak tracking for consecutive play days.
- Parent-gated account layer: SHA-256 hashed password + 4-digit PIN, multiple child profiles (max 4) per parent, parent dashboard with weekly summaries and settings (time limits).

**App structure:** feature-first under `lib/features/` (onboarding, home, level_select, gameplay, reward, progress, sticker_book, parent_dashboard, settings, splash), each with its own Riverpod providers; shared `lib/data/` layer for models/repositories; routing centralized in `lib/core/router/app_router.dart` with a bottom-nav shell and redirect logic for onboarding/auth gating.

**Testing:** unit tests exist for gameplay state, streak logic, question/world models, onboarding, PIN gating, the adaptive engine, and app settings (`test/`). All 92 tests pass.

**State:** working MVP — content is seeded in-code (not a real CMS yet), platform scaffolding for Android/iOS/Windows is present.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
