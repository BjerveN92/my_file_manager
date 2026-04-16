// =============================================================
// models/color_tags.dart — Fördefinierade färgtaggar för mappar
// =============================================================

import 'package:flutter/material.dart';

enum ColorTag {
  red('Röd', Color(0xFFE74C3C)),
  orange('Orange', Color(0xFFF39C12)),
  yellow('Gul', Color(0xFFF1C40F)),
  green('Grön', Color(0xFF2ECC71)),
  blue('Blå', Color(0xFF3498DB)),
  purple('Lila', Color(0xFF9B59B6)),
  gray('Grå', Color(0xFF95A5A6)),
  none('Ingen', Colors.transparent); // Ingen färg = default

  // ----- Fält -----
  final String label; // Visningsnamn, t.ex. "Röd"
  final Color color; // Själva färgen

  // ----- Konstruktor -----
  // "const" eftersom enum-värden alltid är konstanta.
  const ColorTag(this.label, this.color);

  // =============================================================
  // Hjälpmetod: Hitta en ColorTag från dess namn (som String)
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
