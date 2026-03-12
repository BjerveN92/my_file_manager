// =============================================================
// models/file_item.dart — Datamodell för filer och mappar
// =============================================================
// En "modell" representerar DATA i vår app.
//
// VARFÖR MODELLER?
//   Istället för att skicka runt råa strängar och booleans överallt,
//   samlar vi ihop relaterad data i en klass. Det gör koden:
//   - Lättare att läsa (fileItem.name istället för someList[0])
//   - Säkrare (kompilatorn kollar typerna åt oss)
//   - Lättare att ändra (lägg till fält på ETT ställe)
//
// DART-KONCEPT HÄR:
//   - Klasser (class) — ritning för objekt
//   - Konstruktorer — hur vi skapar objekt
//   - final — värdet kan inte ändras efter skapande
//   - Namngivna parametrar med {} — tydligare kod
// =============================================================

import 'dart:io'; // Dart:io ger oss tillgång till filsystemet (File, Directory)

/// FileItem representerar EN fil eller mapp i vår filhanterare.
///
/// Exempel:
/// ```dart
/// final item = FileItem(
///   name: 'Dokument',
///   path: '/home/user/Dokument',
///   isDirectory: true,
/// );
/// ```
class FileItem {
  // "final" = värdet sätts EN gång (i konstruktorn) och kan sedan inte ändras.
  // Det kallas "immutable" och är bra praxis i Flutter.

  final String name;        // Filens/mappens namn, t.ex. "rapport.pdf"
  final String path;        // Hela sökvägen, t.ex. "/home/user/rapport.pdf"
  final bool isDirectory;   // true = mapp, false = fil
  final int size;           // Storlek i bytes (0 för mappar)
  final DateTime modified;  // Senast ändrad

  // ----- Konstruktor med namngivna parametrar -----
  // "required" = måste anges när vi skapar objektet.
  // Utan "required" kan parametern utelämnas (och behöver ett defaultvärde).
  const FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size = 0,              // Default: 0 bytes
    required this.modified,
  });

  // =============================================================
  // Factory constructor — skapa FileItem från en FileSystemEntity
  // =============================================================
  // "factory" = en speciell konstruktor som kan returnera ett redan
  // skapat objekt eller köra logik innan den skapar ett nytt.
  //
  // FileSystemEntity är Darts bastyp för filer och mappar.
  // Vi konverterar den till vår egen, mer lättanvända FileItem.
  // =============================================================
  factory FileItem.fromEntity(FileSystemEntity entity) {
    // stat() hämtar metadata (storlek, datum, etc.)
    final stat = entity.statSync();

    // Plocka ut bara filnamnet från hela sökvägen
    // T.ex. "/home/user/docs/rapport.pdf" → "rapport.pdf"
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
  // "get" = en getter, fungerar som en egenskap men beräknas dynamiskt.
  // Anropas utan paranteser: item.extension (inte item.extension())
  // =============================================================
  String get extension {
    if (isDirectory) return '';        // Mappar har ingen ändelse
    final parts = name.split('.');
    if (parts.length < 2) return '';   // Ingen punkt = ingen ändelse
    return parts.last.toLowerCase();   // T.ex. "pdf", "txt", "dart"
  }

  // =============================================================
  // toString() — för enkel debugging
  // =============================================================
  // Anropas automatiskt när du t.ex. gör print(fileItem).
  // @override = vi skriver över metoden från basklassen Object.
  // =============================================================
  @override
  String toString() => 'FileItem($name, dir: $isDirectory)';
}
