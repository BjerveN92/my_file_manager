// =============================================================
// screens/home_screen.dart — Huvudskärmen
// =============================================================
// Det här är skärmen som sätter ihop alla widgets:
//   - Sidebar (vänster)
//   - BreadcrumbBar (toppen)
//   - ColumnBrowser (mitten — huvudinnehållet)
//
// FLUTTER-KONCEPT HÄR:
//   - StatefulWidget med state som delas mellan barn-widgets
//   - GlobalKey — ett sätt att komma åt en widget "utifrån"
//   - Layout med Row, Column, Expanded
// =============================================================

import 'package:flutter/material.dart';
import '../services/file_operations.dart';
import '../widgets/sidebar.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/column_browser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Den aktuella rotmappen (startar med hemkatalogen)
  late String _rootPath;

  // "Key" tvingar Flutter att bygga om ColumnBrowser helt från scratch
  // när vi byter rotmapp. Utan detta kan gammal data hänga kvar.
  Key _browserKey = UniqueKey();

  // =============================================================
  // initState() — Sätt startvärden
  // =============================================================
  @override
  void initState() {
    super.initState();
    // "late" i deklarationen ovan betyder: "Jag lovar att sätta värdet
    // innan det används". Vi sätter det här i initState.
    _rootPath = FileOperations.getHomeDirectory();
  }

  // =============================================================
  // _navigateTo() — Byt rotmapp (t.ex. från sidebar eller breadcrumb)
  // =============================================================
  void _navigateTo(String path) {
    setState(() {
      _rootPath = path;
      // Ny nyckel = Flutter bygger om ColumnBrowser helt
      _browserKey = UniqueKey();
    });
  }

  // =============================================================
  // build() — Bygg layouten
  // =============================================================
  // Layouten ser ut så här:
  //
  // ┌──────────┬────────────────────────────────┐
  // │          │  Breadcrumb: Hem > Dok > ...    │
  // │ Sidebar  ├────────────────────────────────│
  // │          │  ColumnBrowser                  │
  // │ Hem      │  [Kol1] [Kol2] [Kol3] →       │
  // │ Dok      │                                │
  // │ Nedl.    │                                │
  // │          │                                │
  // └──────────┴────────────────────────────────┘
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold ger grundstrukturen: appbar, body, etc.
      backgroundColor: const Color(0xFF181825),
      body: Row(
        children: [
          // ===== VÄNSTER: Sidebar =====
          Sidebar(currentPath: _rootPath, onFolderSelected: _navigateTo),

          // ===== HÖGER: Breadcrumb + ColumnBrowser =====
          // Expanded = ta upp RESTEN av platsen (efter sidebar)
          Expanded(
            child: Column(
              children: [
                // --- Toppen: Breadcrumb ---
                BreadcrumbBar(
                  currentPath: _rootPath,
                  onPathTapped: _navigateTo,
                ),

                // --- Mitten: ColumnBrowser ---
                // Expanded här också = fyll resten av höjden
                Expanded(
                  child: ColumnBrowser(
                    key: _browserKey, // Ny key → ny widget
                    initialPath: _rootPath,
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
