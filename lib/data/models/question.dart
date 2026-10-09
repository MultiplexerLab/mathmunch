// Question is seed content served from ContentRepository — not stored in Hive.
class Question {
  final String id;
  final String type; // 'counting' | 'addition' | 'shapes' | 'subtraction'

  /// Spoken aloud by the mascot — no reading required (FR-22).
  final String audioPrompt;

  /// Optional visual asset path (object count image, shape, etc.)
  final String? visualAsset;

  /// Numeral or expression shown on screen alongside the visual.
  final String displaySymbol;

  /// Answer options shown as large tap targets (FR-17).
  final List<String> choices;

  /// Index into [choices] of the correct answer.
  final int correctIndex;

  final int difficulty;

  const Question({
    required this.id,
    required this.type,
    required this.audioPrompt,
    this.visualAsset,
    required this.displaySymbol,
    required this.choices,
    required this.correctIndex,
    required this.difficulty,
  });

  String get correctAnswer => choices[correctIndex];
}
