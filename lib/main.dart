import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

// ===================== حط API KEY ديالك هنا =====================
const String GEMINI_API_KEY = "AQ.Ab8RN6J9G6UWkMJzD8q4uIiQPoT6LjyS1HPjWi5OUC27mT4K2w";
// ==============================================================

void main() => runApp(const DialogAIApp());

class DialogAIApp extends StatelessWidget {
  const DialogAIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0A0F1F)),
      home: const HomeRoot(),
    );
  }
}

class HomeRoot extends StatefulWidget {
  const HomeRoot({super.key});
  @override
  State<HomeRoot> createState() => _HomeRootState();
}

class _HomeRootState extends State<HomeRoot> {
  int idx = 0;
  final pages = const [CompanerosScreen(), AvatarEditorScreen(), ChatScreen(), AjustesScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
        backgroundColor: const Color(0xFF0A0F1F),
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Compañeros'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class AvatarConfig {
  String peinado = 'Moño Flamenco';
  String colorPelo = '#8B4513';
  String colorOjos = '#8B4513';
  String ropa = 'Vestido Flamenco';
  List<String> accesorios = [];
  Map<String, dynamic> toJson() => {'peinado': peinado, 'colorPelo': colorPelo, 'colorOjos': colorOjos, 'ropa': ropa, 'accesorios': accesorios};
  static AvatarConfig fromJson(Map j) {
    var a = AvatarConfig();
    a.peinado = j['peinado'] ?? 'Moño Flamenco';
    a.colorPelo = j['colorPelo'] ?? '#8B4513';
    a.colorOjos = j['colorOjos'] ?? '#8B4513';
    a.ropa = j['ropa'] ?? 'Vestido Flamenco';
