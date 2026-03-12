import 'package:flutter/material.dart';

void main() {
  runApp(const FileManagerApp());
}

class FileManagerApp extends StatelessWidget {
  const FileManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color.fromARGB(255, 43, 142, 255),
        useMaterial3: true,
      ),
      home: const Scaffold(body: Center(child: Text('File Manager 🎉'))),
    );
  }
}
