// Sticker is seed content served from ContentRepository — not stored in Hive.
class Sticker {
  final String id;
  final String worldId;
  final String name;
  final String imagePath;
  final String soundPath;
  final int sortOrder;

  const Sticker({
    required this.id,
    required this.worldId,
    required this.name,
    required this.imagePath,
    required this.soundPath,
    required this.sortOrder,
  });
}
