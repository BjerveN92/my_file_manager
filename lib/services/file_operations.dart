// =============================================================
// services/file_operations.dart — Hanterar filsystemet
// =============================================================
// En "service" är en klass som utför arbete ÅT våra widgets.

import 'dart:io';
import '../models/file_item.dart';

class FileOperations {
  // =============================================================
  // listDirectory() — Hämta innehållet i en mapp
  // =============================================================
  static Future<List<FileItem>> listDirectory(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        return []; // Tom lista om mappen inte finns
      }
      // list() hämtar alla filer och mappar i katalogen.
      final entities = await directory.list().toList();
      // Konvertera varje FileSystemEntity till vår FileItem-modell.
      final items = entities
          .where((entity) {
            // Filtrera bort dolda filer (börjar med .)
            final name = entity.path.split(Platform.pathSeparator).last;
            return !name.startsWith('.');
          })
          .map((entity) {
            // Försök skapa FileItem, returnera null om det misslyckas
            try {
              return FileItem.fromEntity(entity);
            } catch (e) {
              return null; // Hoppa över filer vi inte kan läsa
            }
          })
          .where((item) => item != null)
          .cast<FileItem>()
          .toList();

      // Sortera: mappar först, sedan filer, alfabetiskt inom varje grupp
      items.sort((a, b) {
        // Om en är mapp och andra inte → mappen kommer först
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return items;
    } catch (e) {
      print('Fel vid läsning av mapp: $e');
      return [];
    }
  }

  // =============================================================
  // getHomeDirectory() — Hämta användarens hemkatalog
  // =============================================================
  // På Windows: C:\Users\DittNamn  (USERPROFILE)
  // På macOS:   /Users/DittNamn    (HOME)
  // På Linux:   /home/dittnamn     (HOME)
  // =============================================================
  static String getHomeDirectory() {
    if (Platform.isWindows) {
      return Platform.environment['USERPROFILE'] ?? 'C:\\';
    } else {
      return Platform.environment['HOME'] ?? '/';
    }
  }

  // =============================================================
  // getCommonDirectories() — Snabbåtkomst till vanliga mappar
  // =============================================================
  // openFile() — Öppna en fil med systemets standardprogram
  // =============================================================
  static Future<void> openFile(String path) async {
    await Process.run('cmd', ['/c', 'start', '', path]);
  }

  // =============================================================
  // deleteFile() — Ta bort en fil permanent
  // =============================================================
  static Future<void> deleteFile(String path) async {
    await File(path).delete();
  }

  // =============================================================
  // renameFile() — Byt namn på en fil
  // =============================================================
  static Future<void> renameFile(String path, String newName) async {
    final parent = File(path).parent.path;
    await File(path).rename('$parent\\$newName');
  }

  // =============================================================
  // copyFile() — Kopiera en fil till en annan mapp
  // =============================================================
  static Future<void> copyFile(
    String sourcePath,
    String destinationFolder,
  ) async {
    final name = sourcePath.split('\\').last;
    await File(sourcePath).copy('$destinationFolder\\$name');
  }

  static List<Map<String, String>> getCommonDirectories() {
    final home = getHomeDirectory(); // = C:\Users\marti
    final sep = Platform.pathSeparator;

    // Provar sökvägarna i ordning och returnerar den första som existerar.
    String resolve(List<String> candidates) {
      for (final path in candidates) {
        if (Directory(path).existsSync()) return path;
      }
      return candidates.first; // fallback om ingen hittas
    }

    return [
      {'name': 'Hem', 'path': home},
      {
        'name': 'Skrivbord',
        'path': resolve([
          'C:\\Skrivbord',
          '$home${sep}Skrivbord',
          '$home${sep}Desktop',
        ]),
      },
      {
        'name': 'Dokument',
        'path': resolve(['$home${sep}Dokument', '$home${sep}Documents']),
      },
      {
        'name': 'Nedladdningar',
        'path': resolve(['$home${sep}Nedladdningar', '$home${sep}Downloads']),
      },
      {
        'name': 'Bilder',
        'path': resolve(['$home${sep}Bilder', '$home${sep}Pictures']),
      },
      {
        'name': 'Musik',
        'path': resolve(['$home${sep}Musik', '$home${sep}Music']),
      },
    ];
  }
}
