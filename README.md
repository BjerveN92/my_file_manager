# File Manager

En kolumnbaserad filhanterare (Miller Columns) byggd med Flutter som examensarbete.
Inspirerad av macOS Finders kolumnvy, med stöd för färgläggning av mappar.

## Status

Projektet är i tidig utvecklingsfas. Grundläggande navigation och mappfärger fungerar.

### Implementerat

- Miller Columns-navigation (klicka på mapp → ny kolumn till höger)
- Sidebar med snabbåtkomst (Hem, Dokument, Nedladdningar, etc.)
- Breadcrumb-bar för sökvägsnavigation
- Färgtaggar på mappar (långtryck → välj färg)
- Färger sparas lokalt mellan sessioner
- Filtypsikoner baserat på filändelse
- Mörkt tema

### Kommande

- Context menu (högerklick)
- Öppna/förhandsgranska filer
- Sökfunktion

## Krav

- Flutter SDK ≥ 3.0
- Windows (projektet är skapat med `--platforms=windows`)

## Kom igång

```bash
git clone <repo-url>
cd file_manager
flutter pub get
flutter run -d windows
```

## Projektstruktur

```
lib/
├── main.dart                  # Startpunkt
├── models/
│   ├── file_item.dart         # Datamodell för filer/mappar
│   └── color_tags.dart        # Färgtaggar (enum)
├── screens/
│   └── home_screen.dart       # Huvudskärm (layout)
├── services/
│   ├── file_operations.dart   # Läser filsystemet
│   └── folder_color_store.dart # Sparar mappfärger
└── widgets/
    ├── column_browser.dart    # Miller Columns-vy
    ├── breadcrumb_bar.dart    # Sökvägsnavigation
    └── sidebar.dart           # Snabbåtkomst-panel
```

## Teknik

- **Språk:** Dart
- **Ramverk:** Flutter
- **State management:** setState (planerar utvärdera Riverpod)
- **Lokal lagring:** SharedPreferences
