import 'package:flutter/material.dart';
import 'services/file_operations.dart';

void main() {
  runApp(const FileManagerApp());
}

class FileManagerApp extends StatelessWidget {
  const FileManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Testa att vår service fungerar
    final homePath = FileOperations.getHomeDirectory();

    return MaterialApp(
      title: 'File Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF4A90D9),
        useMaterial3: true,
      ),
      home: Scaffold(body: Center(child: Text('Hemkatalog: $homePath'))),
    );
  }
}
