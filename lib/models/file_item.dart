// =============================================================
// models/file_item.dart — Datamodell för filer och mappar
// =============================================================

import 'dart:io'; // Dart:io ger oss tillgång till filsystemet (File, Directory)

class FileItem {
  final String name; // Filens/mappens namn, t.ex. "rapport.pdf"
  final String path; // Hela sökvägen, t.ex. "/home/user/rapport.pdf"
  final bool isDirectory; // true = mapp, false = fil
  final int size; // Storlek i bytes (0 för mappar)
  final DateTime modified; // Senast ändrad

  const FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size = 0,
    required this.modified,
  });

  // =============================================================
  // Factory constructor — skapa FileItem från en FileSystemEntity
  // =============================================================
  factory FileItem.fromEntity(FileSystemEntity entity) {
    // stat() hämtar metadata (storlek, datum, etc.)
    final stat = entity.statSync();
    // Plocka ut bara filnamnet från hela sökvägen
    final name = entity.path.split(Platform.pathSeparator).last;

    return FileItem(
      name: name,
      path: entity.path,
      isDirectory: entity is Directory, // "is" kollar typen
      size: stat.size,
      modified: stat.modified,
    );
  }

  // =============================================================
  // Hjälpmetod — filens ändelse (extension)
  // =============================================================
  String get extension {
    if (isDirectory) return ''; // Mappar har ingen ändelse
    final parts = name.split('.');
    if (parts.length < 2) return ''; // Ingen punkt = ingen ändelse
    return parts.last.toLowerCase(); // T.ex. "pdf", "txt", "dart"
  }

  // =============================================================
  // toString() — för enkel debugging
  // =============================================================
  @override
  String toString() => 'FileItem($name, dir: $isDirectory)';
}
