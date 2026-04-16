// =============================================================
// services/folder_color_store.dart — Sparar mappfärger lokalt
// =============================================================

import 'package:shared_preferences/shared_preferences.dart';
import '../models/color_tags.dart';

/// FolderColorStore — Sparar och hämtar färgtaggar för mappar.
class FolderColorStore {
  static const String _prefix = 'folder_color:';
  // =============================================================
  // getColor() — Hämta färgen för en mapp
  // =============================================================
  static Future<ColorTag> getColor(String folderPath) async {
    final prefs = await SharedPreferences.getInstance();
    final colorName = prefs.getString('$_prefix$folderPath') ?? 'none';

    return ColorTag.fromName(colorName);
  }

  // =============================================================
  // setColor() — Spara en färg för en mapp
  // =============================================================
  static Future<void> setColor(String folderPath, ColorTag tag) async {
    final prefs = await SharedPreferences.getInstance();

    if (tag == ColorTag.none) {
      await prefs.remove('$_prefix$folderPath');
    } else {
      await prefs.setString('$_prefix$folderPath', tag.name);
    }
  }

  // =============================================================
  // getAllColors() — Hämta ALLA sparade mappfärger
  // =============================================================
  static Future<Map<String, ColorTag>> getAllColors() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, ColorTag> colors = {};

    // Gå igenom alla sparade nycklar
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_prefix)) {
        final folderPath = key.substring(_prefix.length);
        final colorName = prefs.getString(key) ?? 'none';
        colors[folderPath] = ColorTag.fromName(colorName);
      }
    }

    return colors;
  }
}
