// =============================================================
// main.dart — Appens startpunkt (entry point)
// =============================================================
// Det här är första filen Flutter letar efter när appen startar.
//
// GRUNDREGEL I DART:
//   Varje app börjar med funktionen main().
//   I Flutter kallar vi runApp() som tar emot vår "root widget".
//
// WIDGET = Allt i Flutter är widgets!
//   - En knapp? Widget.
//   - En text? Widget.
//   - Hela skärmen? Widget.
//   Widgets bygger på varandra som LEGO-klossar.
// =============================================================

import 'package:flutter/material.dart'; // Flutters grund-bibliotek med Material Design
import 'screens/home_screen.dart'; // Vår huvudskärm

/// main() — Här startar allt!
/// "void" betyder att funktionen inte returnerar något värde.
void main() {
  // runApp() tar en widget och gör den till hela appens rot.
  runApp(const FileManagerApp());
}

// =============================================================
// FileManagerApp — Vår rot-widget (root widget)
// =============================================================
// StatelessWidget = En widget som INTE ändrar sig efter att den byggts.
//   Perfekt för saker som inte behöver uppdateras dynamiskt,
//   t.ex. app-tema, titel, grundinställningar.
//
// Det finns också StatefulWidget = En widget som KAN ändra sig.
//   Den använder vi för skärmar med interaktion (knapptryck, scroll, etc.)
//   Mer om det i home_screen.dart!
// =============================================================
class FileManagerApp extends StatelessWidget {
  // "const" = skapar objektet vid kompilering (snabbare).
  // "super.key" = skickar vidare en unik nyckel till förälder-klassen.
  const FileManagerApp({super.key});

  // build() anropas av Flutter för att "rita" widgeten.
  // Den MÅSTE returnera en widget.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ----- App-inställningar -----
      title: 'File Manager', // Visas i task manager / app switcher
      debugShowCheckedModeBanner: false, // Tar bort "DEBUG"-bannern i hörnet
      // ----- Tema (utseende) -----
      // ThemeData styr färger, typsnitt, etc. för HELA appen.
      theme: ThemeData(
        // Mörkt tema — passar bra för en filhanterare
        brightness: Brightness.dark,

        // Primärfärg — används av knappar, headers, etc.
        colorSchemeSeed: const Color(0xFF4A90D9), // En snygg blå ton
        // Använd Material 3 (senaste designstandarden)
        useMaterial3: true,
      ),

      // ----- Startskärm -----
      // home: bestämmer vilken widget som visas först.
      home: const HomeScreen(),
    );
  }
}
