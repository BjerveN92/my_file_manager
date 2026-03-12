// =============================================================
// models/color_tags.dart — Fördefinierade färgtaggar för mappar
// =============================================================
// Här definierar vi vilka färger användaren kan välja mellan
// för att färglägga sina mappar, precis som macOS tags.
//
// DART-KONCEPT HÄR:
//   - enum — en uppsättning fasta, namngivna värden
//   - Enhanced enums (Dart 3) — enums med egna fält och metoder
//   - Color — Flutters färgklass (från material.dart)
// =============================================================

import 'package:flutter/material.dart';

/// ColorTag representerar en fördefinierad färg som kan sättas på mappar.
///
/// I Dart 3+ kan enums ha egna fält och metoder — superpraktiskt!
/// Varje värde (t.ex. ColorTag.red) har en label OCH en färg kopplad till sig.
enum ColorTag {
  // Varje enum-värde skapas med sina egna parametrar.
  // Format: namn(label, färg)
  red('Röd', Color(0xFFE74C3C)),
  orange('Orange', Color(0xFFF39C12)),
  yellow('Gul', Color(0xFFF1C40F)),
  green('Grön', Color(0xFF2ECC71)),
  blue('Blå', Color(0xFF3498DB)),
  purple('Lila', Color(0xFF9B59B6)),
  gray('Grå', Color(0xFF95A5A6)),
  none('Ingen', Colors.transparent); // Ingen färg = default

  // ----- Fält -----
  final String label;  // Visningsnamn, t.ex. "Röd"
  final Color color;   // Själva färgen

  // ----- Konstruktor -----
  // "const" eftersom enum-värden alltid är konstanta.
  const ColorTag(this.label, this.color);

  // =============================================================
  // Hjälpmetod: Hitta en ColorTag från dess namn (som String)
  // =============================================================
  // Användbart när vi laddar sparade färger från SharedPreferences.
  // T.ex: ColorTag.fromName('red') → ColorTag.red
  //
  // "static" = tillhör klassen, inte en specifik instans.
  //            Anropas: ColorTag.fromName('red')
  //            Inte:    someTag.fromName('red')
  // =============================================================
  static ColorTag fromName(String name) {
    // .firstWhere() letar igenom alla enum-värden.
    // "orElse" = vad som returneras om inget matchar.
    return ColorTag.values.firstWhere(
      (tag) => tag.name == name, // "name" är enum-värdets namn som sträng
      orElse: () => ColorTag.none,
    );
  }
}
