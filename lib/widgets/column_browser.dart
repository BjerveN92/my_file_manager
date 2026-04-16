// =============================================================
// widgets/column_browser.dart — Miller Columns (kolumnbaserad vy)
// =============================================================
import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../models/color_tags.dart';
import '../services/file_operations.dart';

// =============================================================
// ColumnData — Hjälpklass som håller data för EN kolumn
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
class ColumnBrowser extends StatefulWidget {
  final String initialPath;

  // Mappfärger ägs av HomeScreen och skickas hit för visning.
  // När en färg ändras (via Sidebar) uppdateras denna map och
  // Flutter ritar om automatiskt.
  final Map<String, ColorTag> folderColors;

  // Callback till HomeScreen när användaren markerar en mapp.
  // Skickar null om en fil markerades (ingen mapp vald).
  final void Function(String? path)? onFolderSelected;

  const ColumnBrowser({
    super.key,
    required this.initialPath,
    required this.folderColors,
    this.onFolderSelected,
  });

  @override
  State<ColumnBrowser> createState() => _ColumnBrowserState();
}

class _ColumnBrowserState extends State<ColumnBrowser> {
  List<ColumnData> _columns = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  DateTime? _lastTapTime;
  String? _lastTapPath;
  static const _doubleTapThreshold = Duration(milliseconds: 300);

  String? _copiedFilePath;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // =============================================================
  // _loadInitialData() — Ladda första kolumnen
  // =============================================================
  // Mappfärger laddas nu av HomeScreen — vi behöver bara
  // hämta innehållet i startmappen.
  Future<void> _loadInitialData() async {
    final items = await FileOperations.listDirectory(widget.initialPath);
    setState(() {
      _columns = [ColumnData(path: widget.initialPath, items: items)];
      _isLoading = false;
    });
  }

  // =============================================================
  // _onItemTapped() — Användaren klickade på en fil/mapp
  // =============================================================
  Future<void> _onItemTapped(int columnIndex, int itemIndex) async {
    final item = _columns[columnIndex].items[itemIndex];
    final now = DateTime.now();

    final isDoubleTap =
        _lastTapTime != null &&
        _lastTapPath == item.path &&
        now.difference(_lastTapTime!) < _doubleTapThreshold;

    _lastTapTime = now;
    _lastTapPath = item.path;

    if (isDoubleTap && !item.isDirectory) {
      await _openFile(item);
      return;
    }

    _columns[columnIndex].selectedIndex = itemIndex;

    if (item.isDirectory) {
      // Meddela HomeScreen vilken mapp som är markerad
      widget.onFolderSelected?.call(item.path);

      final newColumns = _columns.sublist(0, columnIndex + 1);
      final items = await FileOperations.listDirectory(item.path);
      newColumns.add(ColumnData(path: item.path, items: items));

      setState(() {
        _columns = newColumns;
      });

      Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      // Fil vald — ingen mapp markerad
      widget.onFolderSelected?.call(null);

      setState(() {
        _columns = _columns.sublist(0, columnIndex + 1);
      });
    }
  }

  Future<void> _openFile(FileItem item) async {
    await FileOperations.openFile(item.path);
  }

  Future<void> _refreshColumn(int columnIndex) async {
    final path = _columns[columnIndex].path;
    final items = await FileOperations.listDirectory(path);
    setState(() {
      _columns[columnIndex] = ColumnData(path: path, items: items);
    });
  }

  // =============================================================
  // _showFileContextMenu() — Högerklick-meny för filer
  // =============================================================
  Future<void> _showFileContextMenu(
    BuildContext ctx,
    Offset position,
    FileItem item,
    int columnIndex,
  ) async {
    final result = await showMenu<String>(
      context: ctx,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(value: 'copy', child: Text('Kopiera')),
        PopupMenuItem(
          value: 'paste',
          enabled: _copiedFilePath != null,
          child: const Text('Klistra in'),
        ),
        const PopupMenuItem(value: 'rename', child: Text('Byta namn')),
        const PopupMenuItem(value: 'delete', child: Text('Ta bort')),
      ],
    );

    switch (result) {
      case 'copy':
        setState(() => _copiedFilePath = item.path);
      case 'paste':
        await _pasteFile(columnIndex);
      case 'rename':
        await _renameFile(item, columnIndex);
      case 'delete':
        await _deleteFile(item, columnIndex);
    }
  }

  // =============================================================
  // _showDirectoryContextMenu() — Högerklick-meny för mappar
  // =============================================================
  // Färgvalet finns nu i Sidebar — menyn har bara fil-operationer.
  Future<void> _showDirectoryContextMenu(
    BuildContext ctx,
    Offset position,
    FileItem item,
    int columnIndex,
  ) async {
    final result = await showMenu<String>(
      context: ctx,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(value: 'copy', child: Text('Kopiera')),
        PopupMenuItem(
          value: 'paste',
          enabled: _copiedFilePath != null,
          child: const Text('Klistra in'),
        ),
        const PopupMenuItem(value: 'rename', child: Text('Byta namn')),
        const PopupMenuItem(value: 'delete', child: Text('Ta bort')),
      ],
    );

    switch (result) {
      case 'copy':
        setState(() => _copiedFilePath = item.path);
      case 'paste':
        await _pasteFile(columnIndex);
      case 'rename':
        await _renameFile(item, columnIndex);
      case 'delete':
        await _deleteFile(item, columnIndex);
    }
  }

  Future<void> _pasteFile(int columnIndex) async {
    if (_copiedFilePath == null) return;
    final destFolder = _columns[columnIndex].path;
    await FileOperations.copyFile(_copiedFilePath!, destFolder);
    await _refreshColumn(columnIndex);
  }

  Future<void> _renameFile(FileItem item, int columnIndex) async {
    final controller = TextEditingController(text: item.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Byta namn'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Spara'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && newName != item.name) {
      await FileOperations.renameFile(item.path, newName);
      await _refreshColumn(columnIndex);
    }
  }

  Future<void> _deleteFile(FileItem item, int columnIndex) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ta bort ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ta bort'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FileOperations.deleteFile(item.path);
      await _refreshColumn(columnIndex);
    }
  }

  // =============================================================
  // build() — Rita hela widgeten
  // =============================================================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (int i = 0; i < _columns.length; i++) _buildColumn(i)],
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
      width: 280,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
      ),
      child: column.items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Tom mapp', style: TextStyle(color: Colors.grey)),
              ),
            )
          : ListView.builder(
              itemCount: column.items.length,
              itemBuilder: (context, itemIndex) {
                final item = column.items[itemIndex];
                final isSelected = column.selectedIndex == itemIndex;
                // Hämta färg från widget.folderColors (ägs av HomeScreen)
                final folderColor = widget.folderColors[item.path];

                return _buildFileRow(
                  item: item,
                  isSelected: isSelected,
                  folderColor: folderColor,
                  columnIndex: columnIndex,
                  onTap: () => _onItemTapped(columnIndex, itemIndex),
                  onLongPress: null,
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
    required int columnIndex,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    final inkWell = InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
            : null,
        child: Row(
          children: [
            _buildIcon(item, folderColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            if (item.isDirectory)
              Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
    );

    return GestureDetector(
      onSecondaryTapUp: (details) => item.isDirectory
          ? _showDirectoryContextMenu(
              context,
              details.globalPosition,
              item,
              columnIndex,
            )
          : _showFileContextMenu(
              context,
              details.globalPosition,
              item,
              columnIndex,
            ),
      child: inkWell,
    );
  }

  // =============================================================
  // _buildIcon() — Välj rätt ikon baserat på filtyp
  // =============================================================
  Widget _buildIcon(FileItem item, ColorTag? colorTag) {
    if (item.isDirectory) {
      return Icon(
        Icons.folder,
        size: 20,
        color: (colorTag != null && colorTag != ColorTag.none)
            ? colorTag.color
            : const Color(0xFF90CAF9),
      );
    }

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
