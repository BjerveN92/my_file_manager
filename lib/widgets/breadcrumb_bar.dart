// =============================================================
// widgets/breadcrumb_bar.dart — Sökvägs-navigator (breadcrumbs)
// =============================================================
// Breadcrumbs visar var du är i filsystemet, t.ex:
//   Hem > Dokument > Projekt > min_app
//
// Varje del är klickbar så du snabbt kan hoppa tillbaka.
//
// FLUTTER-KONCEPT HÄR:
//   - Callback-funktioner som parametrar
//   - Listor och .asMap() för index
//   - Horisontell scrollning med SingleChildScrollView
// =============================================================

import 'dart:io';
import 'package:flutter/material.dart';

/// BreadcrumbBar visar den aktuella sökvägen som klickbara delar.
///
/// [currentPath] — Hela sökvägen, t.ex. "/home/user/Dokument"
/// [onPathTapped] — Callback som anropas med den klickade delens fulla sökväg
class BreadcrumbBar extends StatelessWidget {
  final String currentPath;
  final void Function(String path) onPathTapped;

  const BreadcrumbBar({
    super.key,
    required this.currentPath,
    required this.onPathTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Dela upp sökvägen i delar
    // T.ex. "/home/user/docs" → ["home", "user", "docs"]
    final parts = currentPath
        .split(Platform.pathSeparator)
        .where((part) => part.isNotEmpty) // Filtrera bort tomma strängar
        .toList();

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // .asMap() ger oss index + värde (som enumerate i Python)
            // .entries ger oss MapEntry med .key (index) och .value (värdet)
            ...parts.asMap().entries.map((entry) {
              final index = entry.key;
              final part = entry.value;
              final isLast = index == parts.length - 1;

              // Bygg upp sökvägen till denna del
              // T.ex. index 1 → "/home/user"
              final pathUpToHere = Platform.isWindows
                  ? parts.sublist(0, index + 1).join(Platform.pathSeparator)
                  : Platform.pathSeparator +
                        parts
                            .sublist(0, index + 1)
                            .join(Platform.pathSeparator);

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Klickbar text
                  InkWell(
                    onTap: isLast ? null : () => onPathTapped(pathUpToHere),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Text(
                        part,
                        style: TextStyle(
                          fontSize: 13,
                          // Sista delen (nuvarande mapp) är ljusare
                          color: isLast ? Colors.white : Colors.grey.shade400,
                          fontWeight: isLast
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),

                  // Separator-pil (inte efter sista delen)
                  if (!isLast)
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: const Color.fromARGB(255, 35, 145, 62),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
