// =============================================================
// widgets/sidebar.dart — Sidopanel med snabbåtkomst
// =============================================================
// Visar en lista med vanliga mappar (Hem, Dokument, etc.)
// som användaren snabbt kan klicka på för att navigera dit.
//
// Liknar sidopanelen i macOS Finder eller Windows Utforskaren.
//
// FLUTTER-KONCEPT HÄR:
//   - StatelessWidget med callbacks
//   - Ikon-mappning
//   - Container och dekorationer
// =============================================================

import 'package:flutter/material.dart';
import '../services/file_operations.dart';

/// Sidebar — Snabbåtkomst till vanliga mappar.
///
/// [currentPath] — Markerar vilken mapp som är aktiv.
/// [onFolderSelected] — Callback när en mapp klickas.
class Sidebar extends StatelessWidget {
  final String currentPath;
  final void Function(String path) onFolderSelected;

  const Sidebar({
    super.key,
    required this.currentPath,
    required this.onFolderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final directories = FileOperations.getCommonDirectories();

    return Container(
      width: 200,
      color: const Color(0xFF1E1E2E), // Mörk sidopanel
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----- Header -----
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Platser',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 69, 138, 63),
                letterSpacing: 1.2,
              ),
            ),
          ),

          // ----- Lista med mappar -----
          // "..." (spread-operatorn) packar upp en lista in i en annan.
          // Istället för en lista-i-lista får vi alla items direkt i Column.
          ...directories.map((dir) {
            final isActive = currentPath.startsWith(dir['path']!);

            return InkWell(
              onTap: () => onFolderSelected(dir['path']!),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: isActive ? Colors.white.withValues(alpha: 0.08) : null,
                child: Row(
                  children: [
                    Icon(
                      _getIcon(dir['name']!),
                      size: 18,
                      color: isActive
                          ? const Color(0xFF4A90D9)
                          : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dir['name']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isActive ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Välj ikon baserat på mappnamn
  IconData _getIcon(String name) {
    switch (name) {
      case 'Hem':
        return Icons.home;
      case 'Skrivbord':
        return Icons.desktop_windows;
      case 'Dokument':
        return Icons.folder_special;
      case 'Nedladdningar':
        return Icons.download;
      case 'Bilder':
        return Icons.photo_library;
      case 'Musik':
        return Icons.library_music;
      default:
        return Icons.folder;
    }
  }
}
