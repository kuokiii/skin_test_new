import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class SkinMonitorApp extends StatelessWidget {
  const SkinMonitorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Monitor Pro',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F8DFE),
        brightness: Brightness.light,
      ),
      home: const HomePage(),
    );
  }
}
