// =============================================================
// screens/home_screen.dart — Huvudskärmen
// =============================================================
import 'package:flutter/material.dart';
import '../models/color_tags.dart';
import '../services/file_operations.dart';
import '../services/folder_color_store.dart';
import '../widgets/sidebar.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/column_browser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _rootPath;

  Key _browserKey = UniqueKey();

  Map<String, ColorTag> _folderColors = {};

  String? _selectedFolderPath;

  // =============================================================
  // initState() — Sätt startvärden
  // =============================================================
  @override
  void initState() {
    super.initState();
    _rootPath = FileOperations.getHomeDirectory();
    _loadFolderColors();
  }

  // Ladda sparade mappfärger från disk
  Future<void> _loadFolderColors() async {
    final colors = await FolderColorStore.getAllColors();
    setState(() {
      _folderColors = colors;
    });
  }

  // =============================================================
  // _navigateTo() — Byt rotmapp (t.ex. från sidebar eller breadcrumb)
  // =============================================================
  void _navigateTo(String path) {
    setState(() {
      _rootPath = path;
      _browserKey =
          UniqueKey(); // Ny nyckel = Flutter bygger om ColumnBrowser helt
      _selectedFolderPath = null; // Rensa markering vid rotbyte
    });
  }

  // =============================================================
  // _onFolderSelected() — ColumnBrowser berättar vilken mapp som är vald
  // =============================================================
  void _onFolderSelected(String? path) {
    setState(() {
      _selectedFolderPath = path;
    });
  }

  // =============================================================
  // _onFolderColorChanged() — Sidebar valde en ny färg för en mapp
  // =============================================================
  Future<void> _onFolderColorChanged(String path, ColorTag tag) async {
    // Spara till disk (SharedPreferences)
    await FolderColorStore.setColor(path, tag);
    // Uppdatera state — triggar omritning i Sidebar OCH ColumnBrowser
    setState(() {
      if (tag == ColorTag.none) {
        _folderColors.remove(path);
      } else {
        _folderColors[path] = tag;
      }
    });
  }

  // =============================================================
  // build() — Bygg layouten
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181825),
      body: Row(
        children: [
          // ===== VÄNSTER: Sidebar =====
          Sidebar(
            currentPath: _rootPath,
            onFolderSelected: _navigateTo,
            selectedFolderPath: _selectedFolderPath,
            folderColors: _folderColors,
            onFolderColorChanged: _onFolderColorChanged,
          ),

          // ===== HÖGER: Breadcrumb + ColumnBrowser =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BreadcrumbBar(
                  currentPath: _rootPath,
                  onPathTapped: _navigateTo,
                ),
                Expanded(
                  child: ColumnBrowser(
                    key: _browserKey,
                    initialPath: _rootPath,
                    folderColors: _folderColors,
                    onFolderSelected: _onFolderSelected,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
