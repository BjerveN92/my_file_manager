// =============================================================
// widgets/sidebar.dart — Sidopanel med snabbåtkomst
// =============================================================
import 'package:flutter/material.dart';
import '../models/color_tags.dart';
import '../services/file_operations.dart';

/// Sidebar — Snabbåtkomst till vanliga mappar + färgpalett.
///
/// [currentPath]          — Markerar vilken mapp som är aktiv i rotvyn.
/// [onFolderSelected]     — Callback när en mapp i listan klickas.
/// [selectedFolderPath]   — Sökvägen till den markerade mappen i
///                          ColumnBrowser (null = ingen mapp vald).
/// [folderColors]         — Karta med sparade färger per sökväg.
/// [onFolderColorChanged] — Callback när användaren väljer en färg.
class Sidebar extends StatelessWidget {
  final String currentPath;
  final void Function(String path) onFolderSelected;
  final String? selectedFolderPath;
  final Map<String, ColorTag> folderColors;
  final void Function(String path, ColorTag tag) onFolderColorChanged;

  const Sidebar({
    super.key,
    required this.currentPath,
    required this.onFolderSelected,
    required this.selectedFolderPath,
    required this.folderColors,
    required this.onFolderColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final directories = FileOperations.getCommonDirectories();

    return Container(
      width: 200,
      color: const Color(0xFF1E1E2E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----- Header -----
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Mina filer',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 194, 206, 25),
                letterSpacing: 1.2,
              ),
            ),
          ),

          // ----- Lista med mappar -----
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

          // ----- Spacer: pusha färgpaletten till botten -----
          const Spacer(),

          // ----- Färgpalett (visas när en mapp är markerad) -----
          if (selectedFolderPath != null) _buildColorPalette(),
        ],
      ),
    );
  }

  // =============================================================
  // _buildColorPalette() — Färgpalett för markerad mapp
  // =============================================================
  Widget _buildColorPalette() {
    final currentColor = folderColors[selectedFolderPath] ?? ColorTag.none;

    // Mappnamnet — bara filnamndelen, inte hela sökvägen
    final folderName = selectedFolderPath!.split(RegExp(r'[\\/]')).last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey.shade800, height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rubrik
              const Text(
                'MAPPFÄRG',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 194, 206, 25),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),

              // Mappnamn
              Text(
                folderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 10),

              // Färgcirklar
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ColorTag.values.map((tag) {
                  final isSelected = tag == currentColor;
                  return GestureDetector(
                    onTap: () => onFolderColorChanged(selectedFolderPath!, tag),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: tag == ColorTag.none
                            ? Colors.grey.shade800
                            : tag.color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2.5)
                            : Border.all(color: Colors.grey.shade700, width: 1),
                      ),
                      child: tag == ColorTag.none
                          ? Icon(
                              Icons.block,
                              size: 14,
                              color: Colors.grey.shade500,
                            )
                          : isSelected
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
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
