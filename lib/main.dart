import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

const String GEMINI_API_KEY = String.fromEnvironment('GEMINI_KEY', defaultValue: 'AQ.Ab8RN6L9ZkiQFgEUrBEEy7sgNtmfXv4Rl7zDVmRk2BN5Q4nyEA');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  runApp(const DialogAIApp());
}

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
  
  // دمج الشاشات الأربعة مع تمرير الحالة لتحديث البيانات فوريًا
  @override
  Widget build(BuildContext context) {
    final pages = [
      const CompanerosScreen(),
      const AvatarEditorScreen(),
      const ChatScreen(),
      const AjustesScreen()
    ];

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
  String peinado;
  String ropa;
  List<String> accesorios;
  AvatarConfig({required this.peinado, required this.ropa, required this.accesorios});
}

class CompanerosScreen extends StatelessWidget {
  const CompanerosScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(children: [
              const Icon(Icons.memory, color: Colors.pinkAccent), 
              const SizedBox(width: 8), 
              const Text('DialogAI v1.5 - Memoria Real', style: TextStyle(fontWeight: FontWeight.bold)), 
              const Spacer(), 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), 
                child: const Text('Gemini Live ✅', style: TextStyle(fontSize: 10, color: Colors.green))
              )
            ]),
            const SizedBox(height: 12),
            const Text('COMPAÑEROS VIRTUALES - Habla como en películas de ciencia ficción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _card(context, 'LUCÍA', 'Flamenco • Conversadora, Empática', 'En línea • Activa', Colors.pinkAccent, Icons.face)),
              const SizedBox(width: 8),
              Expanded(child: _card(context, 'ALEJANDRO', 'Flamenco • Analítico, Amable', 'En línea • Activo', Colors.cyanAccent, Icons.face_2)),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10), 
              decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(12)), 
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('CONVERSACIÓN ACTIVA • IA en tiempo real', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), 
                const SizedBox(height: 8), 
                Row(children: [
                  const Icon(Icons.mic, color: Colors.pinkAccent, size: 16), 
                  const SizedBox(width: 4), 
                  const Text('LUCÍA conectada...', style: TextStyle(fontSize: 10, color: Colors.pinkAccent)), 
                  const Spacer(), 
                  const Icon(Icons.mic, color: Colors.cyanAccent, size: 16), 
                  const Text(' ALEJANDRO listo', style: TextStyle(fontSize: 10, color: Colors.cyanAccent))
                ])
              ])
            ),
            const SizedBox(height: 12),
            const Text('CHAT RECIENTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10), 
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), 
              child: const Text('Hola, aquí Lucía. ¿Cómo estás? Puedو contarte sobre cultura flamenca. Y recuerdo a Mimi tu gato 🐱', style: TextStyle(fontSize: 12))
            ),
            Container(
              padding: const EdgeInsets.all(10), 
              decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), 
              child: const Text('Soy Alejandro. Si hablas mucho con Lucía, me pongo celoso 😅 Pero te ayudo con todo.', style: TextStyle(fontSize: 12))
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String name, String desc, String status, Color col, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12), 
      decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(12), border: Border.all(color: col.withOpacity(0.3))), 
      child: Column(children: [
        CircleAvatar(backgroundColor: col.withOpacity(0.2), child: Icon(icon, color: col)), 
        const SizedBox(height: 6), 
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), 
        Text(desc, style: const TextStyle(fontSize: 9, color: Colors.white54), textAlign: TextAlign.center), 
        const SizedBox(height: 6), 
        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: col.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Text(status, style: TextStyle(fontSize: 8, color: col))), 
        const SizedBox(height: 8), 
        Row(children: [
          Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: col, padding: const EdgeInsets.all(4)), child: const Text('Llamar', style: TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.bold)))), 
          const SizedBox(width: 4), 
          Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(4)), child: const Text('Chat', style: TextStyle(fontSize: 8))))
        ])
      ])
    );
  }
}

class AvatarEditorScreen extends StatefulWidget { 
  const AvatarEditorScreen({super.key}); 
  @override State<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends State<AvatarEditorScreen> {
  String selected = 'Lucía';
  final AvatarConfig lucia = AvatarConfig(peinado: 'Moño Flamenco', ropa: 'Vestido Flamenco Rojo', accesorios: []);
  final AvatarConfig alejandro = AvatarConfig(peinado: 'Corto Clásico', ropa: 'Traje Campero', accesorios: []);

  final List<String> _peinados = ['Moño Flamenco', 'Corto Clásico', 'Largo Rizado', 'Estilo Moderno'];
  final List<String> _ropas = ['Vestido Flamenco Rojo', 'Traje Campero', 'Casual Inteligente', 'Ropa de Gala'];
  final List<String> _accesoriosList = ['Pendientes', 'Sombrero', 'Abanico', 'Gafas'];

  void _notify(String msg) { 
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.pinkAccent)); 
  }

  Widget chip(String label, bool sel, VoidCallback tap) { 
    return GestureDetector(
      onTap: tap, 
      child: Container(
        margin: const EdgeInsets.all(4), 
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
        decoration: BoxDecoration(color: sel ? Colors.pinkAccent : Colors.white10, borderRadius: BorderRadius.circular(8)), 
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
      )
    ); 
  }

  @override Widget build(BuildContext context) {
    AvatarConfig cur = selected == 'Lucía' ? lucia : alejandro;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(12), 
            color: const Color(0xFF0F1A33), 
            child: Row(children: [
              const Text('DialogAI - Editor de Personalización', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), 
              const Spacer(), 
              DropdownButton<String>(
                value: selected,
                dropdownColor: const Color(0xFF0F1A33),
                items: ['Lucía', 'Alejandro'].map((String val) {
                  return DropdownMenuItem<String>(value: val, child: Text(val));
                }).toList(),
                onChanged: (val) { if (val != null) setState(() => selected = val); },
              )
            ])
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
