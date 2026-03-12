// =============================================================
// services/folder_color_store.dart — Sparar mappfärger lokalt
// =============================================================
// Den här servicen hanterar PERSISTENS — att spara data så den
// finns kvar även efter att appen stängs.
//
// Vi använder SharedPreferences, som är som en enkel databas
// med nyckel-värde-par (tänk: en Map som sparas till disk).
//
// T.ex: 'color:/home/user/Dokument' → 'blue'
//
// DART-KONCEPT HÄR:
//   - Singleton-mönster (en enda instans av klassen)
//   - Map<String, String> — nyckel-värde-par
//   - SharedPreferences — lokal lagring
// =============================================================

import 'package:shared_preferences/shared_preferences.dart';
import '../models/color_tags.dart';

/// FolderColorStore — Sparar och hämtar färgtaggar för mappar.
///
/// Använder SharedPreferences för att spara på disk.
/// Varje mapp identifieras av sin fulla sökväg (path).
class FolderColorStore {
  // Prefix för alla nycklar i SharedPreferences.
  // Gör det lättare att skilja våra värden från andra.
  static const String _prefix = 'folder_color:';

  // =============================================================
  // getColor() — Hämta färgen för en mapp
  // =============================================================
  // Returnerar ColorTag.none om ingen färg är sparad.
  // =============================================================
  static Future<ColorTag> getColor(String folderPath) async {
    final prefs = await SharedPreferences.getInstance();

    // getString returnerar null om nyckeln inte finns.
    // ?? = "om null, använd detta istället" (null-coalescing operator)
    final colorName = prefs.getString('$_prefix$folderPath') ?? 'none';

    return ColorTag.fromName(colorName);
  }

  // =============================================================
  // setColor() — Spara en färg för en mapp
  // =============================================================
  static Future<void> setColor(String folderPath, ColorTag tag) async {
    final prefs = await SharedPreferences.getInstance();

    if (tag == ColorTag.none) {
      // Om "ingen färg" → ta bort nyckeln helt
      await prefs.remove('$_prefix$folderPath');
    } else {
      // Spara enum-värdets namn som sträng (t.ex. 'red', 'blue')
      await prefs.setString('$_prefix$folderPath', tag.name);
    }
  }

  // =============================================================
  // getAllColors() — Hämta ALLA sparade mappfärger
  // =============================================================
  // Returnerar en Map: { mappPath → ColorTag }
  // Används för att visa färger i column view utan att ladda en i taget.
  // =============================================================
  static Future<Map<String, ColorTag>> getAllColors() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, ColorTag> colors = {};

    // Gå igenom alla sparade nycklar
    for (final key in prefs.getKeys()) {
      // Kolla om nyckeln börjar med vårt prefix
      if (key.startsWith(_prefix)) {
        // Plocka ut mapp-sökvägen (ta bort prefixet)
        final folderPath = key.substring(_prefix.length);
        final colorName = prefs.getString(key) ?? 'none';
        colors[folderPath] = ColorTag.fromName(colorName);
      }
    }

    return colors;
  }
}
