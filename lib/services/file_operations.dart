// =============================================================
// services/file_operations.dart — Hanterar filsystemet
// =============================================================
// En "service" är en klass som utför arbete ÅT våra widgets.
//
// VARFÖR SEPARERA?
//   Widgets ska bara bry sig om att VISA saker.
//   Logik (läsa mappar, sortera filer) läggs i services.
//   Detta kallas "Separation of Concerns" och gör koden:
//   - Lättare att testa
//   - Lättare att återanvända
//   - Mindre rörig
//
// DART-KONCEPT HÄR:
//   - async/await — hantera saker som tar tid (disk-läsning)
//   - Future — ett "löfte" om ett värde som kommer senare
//   - try/catch — hantera fel elegant
//   - List-metoder — where(), sort(), map()
// =============================================================

import 'dart:io';
import '../models/file_item.dart';

/// FileOperations — Läser och hanterar filer/mappar på disken.
///
/// Alla metoder är "static" — vi behöver inte skapa en instans.
/// Anropas direkt: FileOperations.listDirectory(path)
class FileOperations {
  // =============================================================
  // listDirectory() — Hämta innehållet i en mapp
  // =============================================================
  // "async" = funktionen kan pausa och vänta på saker.
  // "Future<List<FileItem>>" = returnerar en lista av FileItems,
  //   men inte direkt — den kommer "i framtiden" (asynkront).
  //
  // VARFÖR ASYNC?
  //   Att läsa från disk kan ta tid. Om vi gör det synkront
  //   fryser hela appen. Med async fortsätter UI:t att vara responsivt.
  // =============================================================
  static Future<List<FileItem>> listDirectory(String path) async {
    try {
      final directory = Directory(path);

      // Kolla att mappen faktiskt existerar
      if (!await directory.exists()) {
        return []; // Tom lista om mappen inte finns
      }

      // list() hämtar alla filer och mappar i katalogen.
      // .toList() konverterar Stream till en vanlig lista.
      final entities = await directory.list().toList();

      // Konvertera varje FileSystemEntity till vår FileItem-modell.
      // .map() transformerar varje element i listan.
      // .where() filtrerar bort element vi inte vill ha.
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
          .where((item) => item != null) // Ta bort null-värden
          .cast<FileItem>() // Konvertera typen
          .toList();

      // Sortera: mappar först, sedan filer, alfabetiskt inom varje grupp
      items.sort((a, b) {
        // Om en är mapp och andra inte → mappen kommer först
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        // Samma typ → sortera på namn (case-insensitive)
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return items;
    } catch (e) {
      // Om något går fel (t.ex. permission denied), returnera tom lista
      // I en riktig app vill vi nog visa ett felmeddelande för användaren.
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
    // Platform.environment är en Map med alla miljövariabler.
    // På Windows heter den 'USERPROFILE', på Unix 'HOME'.
    if (Platform.isWindows) {
      return Platform.environment['USERPROFILE'] ?? 'C:\\';
    } else {
      return Platform.environment['HOME'] ?? '/';
    }
  }

  // =============================================================
  // getCommonDirectories() — Snabbåtkomst till vanliga mappar
  // =============================================================
  // Returnerar en lista med vanliga mappar (Dokument, Skrivbord, etc.)
  // som vi visar i sidopanelen.
  // =============================================================
  // =============================================================
  // openFile() — Öppna en fil med systemets standardprogram
  // =============================================================
  static Future<void> openFile(String path) async {
    await Process.run('cmd', ['/c', 'start', '', path]);
  }

  static List<Map<String, String>> getCommonDirectories() {
    final home = getHomeDirectory(); // = C:\Users\marti
    final sep = Platform.pathSeparator;

    // Provar sökvägarna i ordning och returnerar den första som existerar.
    // Fungerar oavsett om mapparna har svenska eller engelska namn,
    // eller om de ligger på icke-standardplatser.
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
        'path': resolve([
          '$home${sep}Dokument',
          '$home${sep}Documents',
        ]),
      },
      {
        'name': 'Nedladdningar',
        'path': resolve([
          '$home${sep}Nedladdningar',
          '$home${sep}Downloads',
        ]),
      },
      {
        'name': 'Bilder',
        'path': resolve([
          '$home${sep}Bilder',
          '$home${sep}Pictures',
        ]),
      },
      {
        'name': 'Musik',
        'path': resolve([
          '$home${sep}Musik',
          '$home${sep}Music',
        ]),
      },
    ];
  }
}
