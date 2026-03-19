// =============================================================
// widgets/column_browser.dart — Miller Columns (kolumnbaserad vy)
// =============================================================
// DET HÄR ÄR HJÄRTAT AV APPEN!
//
// Miller Columns = Varje mapp du klickar på öppnar en ny kolumn
// till höger, precis som macOS Finder i Column View.
//
// HUR DET FUNGERAR:
//   1. Vi har en lista med "kolumner" (List<ColumnData>)
//   2. Varje kolumn representerar en mapp och dess innehåll
//   3. När du klickar på en mapp → lägg till en ny kolumn
//   4. Alla kolumner visas i en horisontellt scrollbar Row
//
// FLUTTER-KONCEPT HÄR:
//   - StatefulWidget — widget med föränderligt state
//   - setState() — säg till Flutter att rita om widgeten
//   - ListView.builder — effektiv lista (bygger bara synliga items)
//   - ScrollController — kontrollera scroll-position
//   - Callback-funktioner — kommunikation mellan widgets
// =============================================================

import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../models/color_tags.dart';
import '../services/file_operations.dart';
import '../services/folder_color_store.dart';

// =============================================================
// ColumnData — Hjälpklass som håller data för EN kolumn
// =============================================================
// Varje kolumn har:
//   - path: vilken mapp den visar
//   - items: filerna/mapparna i den mappen
//   - selectedIndex: vilken rad som är markerad (eller -1)
// =============================================================
class ColumnData {
  final String path;
  final List<FileItem> items;
  int selectedIndex;

  ColumnData({
    required this.path,
    required this.items,
    this.selectedIndex = -1,
  });
}

// =============================================================
// ColumnBrowser — Vår Miller Columns-widget
// =============================================================
// StatefulWidget består av TVÅ klasser:
//   1. Widgeten själv (ColumnBrowser) — konfigurationen
//   2. State-klassen (_ColumnBrowserState) — logik och state
//
// VARFÖR TVÅ KLASSER?
//   Widgeten kan byggas om av Flutter, men state-klassen lever kvar.
//   Det betyder att data (våra kolumner) inte försvinner vid omritning.
// =============================================================
class ColumnBrowser extends StatefulWidget {
  // initialPath = mappen vi börjar visa
  final String initialPath;

  const ColumnBrowser({
    super.key,
    required this.initialPath,
  });

  // createState() skapar state-klassen. Anropas EN gång.
  @override
  State<ColumnBrowser> createState() => _ColumnBrowserState();
}

// Understreck (_) i namnet gör klassen PRIVAT — bara denna fil kan använda den.
class _ColumnBrowserState extends State<ColumnBrowser> {
  // ----- State-variabler -----
  // Dessa ÄR saker som kan ändras och trigga omritning.

  List<ColumnData> _columns = [];               // Alla aktiva kolumner
  Map<String, ColorTag> _folderColors = {};      // Sparade mappfärger
  bool _isLoading = true;                        // Visar laddningsindikator
  final ScrollController _scrollController =     // Kontrollerar horisontell scroll
      ScrollController();

  // =============================================================
  // initState() — Körs EN gång när widgeten skapas
  // =============================================================
  // Perfekt ställe att ladda initial data.
  // Tänk på det som "konstruktorn" för state.
  // =============================================================
  @override
  void initState() {
    super.initState(); // Alltid anropa super först!
    _loadInitialData();
  }

  // =============================================================
  // dispose() — Körs när widgeten tas bort
  // =============================================================
  // Rensa upp resurser (controllers, listeners, etc.)
  // Annars får vi minnesläckor!
  // =============================================================
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose(); // Alltid anropa super sist!
  }

  // =============================================================
  // _loadInitialData() — Ladda första kolumnen + sparade färger
  // =============================================================
  Future<void> _loadInitialData() async {
    // Ladda mappfärger och första mappens innehåll parallellt
    final colors = await FolderColorStore.getAllColors();
    final items = await FileOperations.listDirectory(widget.initialPath);

    // setState() säger till Flutter: "Data har ändrats, rita om!"
    // VIKTIGT: Ändra ALDRIG state utan setState() — då ser
    // användaren inte förändringen.
    setState(() {
      _folderColors = colors;
      _columns = [
        ColumnData(path: widget.initialPath, items: items),
      ];
      _isLoading = false;
    });
  }

  // =============================================================
  // _onItemTapped() — Användaren klickade på en fil/mapp
  // =============================================================
  // columnIndex = vilken kolumn klicket skedde i
  // itemIndex = vilken rad i den kolumnen
  // =============================================================
  Future<void> _onItemTapped(int columnIndex, int itemIndex) async {
    final item = _columns[columnIndex].items[itemIndex];

    // Markera raden som vald
    _columns[columnIndex].selectedIndex = itemIndex;

    if (item.isDirectory) {
      // ----- MAPP: Öppna i ny kolumn -----

      // Ta bort alla kolumner EFTER den klickade
      // (om användaren klickar "bakåt" i en tidigare kolumn)
      final newColumns = _columns.sublist(0, columnIndex + 1);

      // Ladda innehållet i den nya mappen
      final items = await FileOperations.listDirectory(item.path);

      // Lägg till den nya kolumnen
      newColumns.add(ColumnData(path: item.path, items: items));

      setState(() {
        _columns = newColumns;
      });

      // Scrolla till höger så nya kolumnen syns
      // Vi väntar lite (en frame) så att layouten hinner byggas
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut, // Mjuk animation
          );
        }
      });
    } else {
      // ----- FIL: Ta bort kolumner efter den klickade -----
      // (Vi öppnar inte filer ännu — det kommer i ett senare steg!)
      setState(() {
        _columns = _columns.sublist(0, columnIndex + 1);
      });
    }
  }

  // =============================================================
  // _onFolderColorChanged() — Användaren valde en ny färg
  // =============================================================
  Future<void> _onFolderColorChanged(String path, ColorTag tag) async {
    // Spara till disk
    await FolderColorStore.setColor(path, tag);

    // Uppdatera lokalt state
    setState(() {
      if (tag == ColorTag.none) {
        _folderColors.remove(path);
      } else {
        _folderColors[path] = tag;
      }
    });
  }

  // =============================================================
  // _showColorPicker() — Visa färgväljare för en mapp
  // =============================================================
  void _showColorPicker(FileItem item) {
    final currentColor = _folderColors[item.path] ?? ColorTag.none;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Färg för ${item.name}'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ColorTag.values.map((tag) {
            final isSelected = tag == currentColor;
            return GestureDetector(
              onTap: () {
                _onFolderColorChanged(item.path, tag);
                Navigator.of(context).pop(); // Stäng dialogen
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tag == ColorTag.none
                      ? Colors.grey.shade800
                      : tag.color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: tag == ColorTag.none
                    ? const Icon(Icons.block, size: 20, color: Colors.grey)
                    : isSelected
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // =============================================================
  // build() — Rita hela widgeten
  // =============================================================
  @override
  Widget build(BuildContext context) {
    // Visa laddningssnurra medan vi hämtar data
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Huvudlayout: Horisontellt scrollbar rad med kolumner
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal, // Scrolla horisontellt!
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bygg en _ColumnWidget för varje kolumn i vår lista
            for (int i = 0; i < _columns.length; i++)
              _buildColumn(i),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // _buildColumn() — Bygg EN kolumn
  // =============================================================
  Widget _buildColumn(int columnIndex) {
    final column = _columns[columnIndex];

    return Container(
      // Varje kolumn har fast bredd och en avgränsare till höger
      width: 280,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
      ),
      child: column.items.isEmpty
          // Tom mapp — visa meddelande
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Tom mapp',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          // ListView.builder skapar items LAZY — bara de som syns på skärmen.
          // Mycket effektivare än att bygga alla på en gång!
          : ListView.builder(
              itemCount: column.items.length,
              itemBuilder: (context, itemIndex) {
                final item = column.items[itemIndex];
                final isSelected = column.selectedIndex == itemIndex;
                final folderColor = _folderColors[item.path];

                return _buildFileRow(
                  item: item,
                  isSelected: isSelected,
                  folderColor: folderColor,
                  onTap: () => _onItemTapped(columnIndex, itemIndex),
                  onLongPress: item.isDirectory
                      ? () => _showColorPicker(item)
                      : null,
                );
              },
            ),
    );
  }

  // =============================================================
  // _buildFileRow() — Bygg EN rad (fil eller mapp)
  // =============================================================
  Widget _buildFileRow({
    required FileItem item,
    required bool isSelected,
    ColorTag? folderColor,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
            : null,
        child: Row(
          children: [
            // ----- Ikon -----
            _buildIcon(item, folderColor),
            const SizedBox(width: 10),

            // ----- Filnamn -----
            // Expanded = ta upp all tillgänglig plats (flex)
            Expanded(
              child: Text(
                item.name,
                overflow: TextOverflow.ellipsis, // "..." om texten är för lång
                style: const TextStyle(fontSize: 13),
              ),
            ),

            // ----- Pil för mappar (visar att man kan navigera in) -----
            if (item.isDirectory)
              Icon(
                Icons.chevron_right,
                size: 16,
                color: Colors.grey.shade600,
              ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // _buildIcon() — Välj rätt ikon baserat på filtyp
  // =============================================================
  Widget _buildIcon(FileItem item, ColorTag? colorTag) {
    if (item.isDirectory) {
      // Mapp-ikon med valfri färg
      return Icon(
        Icons.folder,
        size: 20,
        color: (colorTag != null && colorTag != ColorTag.none)
            ? colorTag.color
            : const Color(0xFF90CAF9), // Ljusblå default
      );
    }

    // Fil-ikon baserat på ändelse
    IconData iconData;
    Color iconColor;

    switch (item.extension) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red.shade300;
      case 'jpg' || 'jpeg' || 'png' || 'gif' || 'webp':
        iconData = Icons.image;
        iconColor = Colors.green.shade300;
      case 'mp3' || 'wav' || 'flac':
        iconData = Icons.music_note;
        iconColor = Colors.purple.shade300;
      case 'mp4' || 'avi' || 'mkv':
        iconData = Icons.movie;
        iconColor = Colors.orange.shade300;
      case 'dart' || 'py' || 'js' || 'ts' || 'java':
        iconData = Icons.code;
        iconColor = Colors.cyan.shade300;
      case 'txt' || 'md':
        iconData = Icons.description;
        iconColor = Colors.grey.shade400;
      case 'zip' || 'rar' || 'tar' || 'gz':
        iconData = Icons.archive;
        iconColor = Colors.brown.shade300;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey.shade400;
    }

    return Icon(iconData, size: 20, color: iconColor);
  }
}
