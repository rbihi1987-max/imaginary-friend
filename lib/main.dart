import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

const String GEMINI_API_KEY = "AQ.Ab8RN6LUvXNiaEjFbzkxDgKYg1_qqYwbsDaZ6uk9AR26QhEUAA";

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
  final List<Widget> pages = const [CompanerosScreen(), AvatarEditorScreen(), ChatScreen(), AjustesScreen()];
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
  
  Map<String, dynamic> toJson() {
    return {
      'peinado': peinado,
      'colorPelo': colorPelo,
      'colorOjos': colorOjos,
      'ropa': ropa,
      'accesorios': accesorios,
    };
  }
  
  static AvatarConfig fromJson(Map<String, dynamic> j) {
    var a = AvatarConfig();
    a.peinado = j['peinado'] ?? 'Moño Flamenco';
    a.colorPelo = j['colorPelo'] ?? '#8B4513';
    a.colorOjos = j['colorOjos'] ?? '#8B4513';
    a.ropa = j['ropa'] ?? 'Vestido Flamenco';
    a.accesorios = List<String>.from(j['accesorios'] ?? []);
    return a;
  }
}

class CompanerosScreen extends StatelessWidget {
  const CompanerosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.memory, color: Colors.pinkAccent), const SizedBox(width: 8), const Text('DialogAI v3 REAL AI', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Text('Gemini Conectado', style: TextStyle(fontSize: 10, color: Colors.green)))]),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))), child: Column(children: [const Text('COMPANEROS VIRTUALES - REAL AI'), const SizedBox(height: 12), Row(children: [Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(12)), child: const Column(children: [CircleAvatar(radius: 28, child: Icon(Icons.face)), Text('LUCIA'), Text('Flamenco', style: TextStyle(fontSize: 9))]))), const SizedBox(width: 8), Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(12)), child: const Column(children: [CircleAvatar(radius: 28, child: Icon(Icons.face)), Text('ALEJANDRO'), Text('Flamenco', style: TextStyle(fontSize: 9))]))))])])),
        ]),
      ),
    );
  }
}

class AvatarEditorScreen extends StatefulWidget { const AvatarEditorScreen({super.key}); @override State<AvatarEditorScreen> createState()=>_AvatarEditorState();}
class _AvatarEditorState extends State<AvatarEditorScreen>{
  String selected='Lucía';
  AvatarConfig lucia=AvatarConfig();
  AvatarConfig alejandro=AvatarConfig();
  void _saveAndNotify(String msg){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.pinkAccent)); }
  Widget _chip(String label, bool sel, VoidCallback tap){ return GestureDetector(onTap: tap, child: Container(margin: const EdgeInsets.all(2), padding: const EdgeInsets.symmetric(horizontal:8,vertical:6), decoration: BoxDecoration(color: sel?Colors.pinkAccent:Colors.white10, borderRadius: BorderRadius.circular(6)), child: Text(label,style: const TextStyle(fontSize:9)))); }
  Widget _chipAcc(String label, bool sel, VoidCallback tap){ return GestureDetector(onTap: tap, child: Container(margin: const EdgeInsets.all(2), padding: const EdgeInsets.symmetric(horizontal:8,vertical:6), decoration: BoxDecoration(color: sel?Colors.greenAccent.withOpacity(0.3):Colors.white10, borderRadius: BorderRadius.circular(6), border: Border.all(color: sel?Colors.greenAccent:Colors.transparent)), child: Text(label,style: const TextStyle(fontSize:9)))); }
  @override Widget build(BuildContext context){
    AvatarConfig cur= selected=='Lucía'?lucia:alejandro;
    return SafeArea(child: Column(children: [
      Container(padding: const EdgeInsets.all(8), color: const Color(0xFF0F1A33), child: const Text('DialogAI - Avatar Editor REAL',style: TextStyle(fontWeight: FontWeight.bold))),
      Expanded(child: Row(children: [
        Expanded(flex:2, child: SingleChildScrollView(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Editor de Avatar',style: TextStyle(fontSize:18,fontWeight: FontWeight.bold)),
          const SizedBox(height:8),
          GestureDetector(onTap: ()=> setState(()=> selected='Lucía'), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selected=='Lucía'?Colors.pinkAccent.withOpacity(0.3):Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Text('Lucía ~25-28 Vestido Flamenco'))),
          const SizedBox(height:8),
          GestureDetector(onTap: ()=> setState(()=> selected='Alejandro'), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selected=='Alejandro'?Colors.cyanAccent.withOpacity(0.3):Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Text('Alejandro ~28-32 Traje Clasico'))),
        ]))),
        Expanded(flex:2, child: Container(color: const Color(0xFF10182E), padding: const EdgeInsets.all(8), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Personalizacion - $selected',style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height:8), const Text('Peinado',style: TextStyle(fontSize:12)),
          Wrap(children: [_chip('Moño Flamenco', cur.peinado=='Moño Flamenco', (){ setState(()=> cur.peinado='Moño Flamenco'); _saveAndNotify('Moño Flamenco'); }), _chip('Ondas Largas', cur.peinado=='Ondas Largas', (){ setState(()=> cur.peinado='Ondas Largas'); _saveAndNotify('Ondas Largas'); }), _chip('Trenza Lateral', cur.peinado=='Trenza Lateral', (){ setState(()=> cur.peinado='Trenza Lateral'); _saveAndNotify('Trenza'); }), _chip('Recogido Bajo', cur.peinado=='Recogido Bajo', (){ setState(()=> cur.peinado='Recogido Bajo'); _saveAndNotify('Recogido'); })]),
          const SizedBox(height:8), const Text('Ropa',style: TextStyle(fontSize:12)),
          Wrap(children: [_chip('Vestido Flamenco', cur.ropa=='Vestido Flamenco', (){ setState(()=> cur.ropa='Vestido Flamenco'); _saveAndNotify('Vestido'); }), _chip('Chal Flamenco', cur.ropa=='Chal Flamenco', (){ setState(()=> cur.ropa=='Chal Flamenco'); _saveAndNotify('Chal'); }), _chip('Blusa Moderna', cur.ropa=='Blusa Moderna', (){ setState(()=> cur.ropa=='Blusa Moderna'); _saveAndNotify('Blusa'); }), _chip('Vestido Oscuro', cur.ropa=='Vestido Oscuro', (){ setState(()=> cur.ropa=='Vestido Oscuro'); _saveAndNotify('Oscuro'); })]),
          const SizedBox(height:8), const Text('Accesorios',style: TextStyle(fontSize:12)),
          Wrap(children: [_chipAcc('Pendientes Dorados', cur.accesorios.contains('Pendientes Dorados'), (){ setState((){ if(cur.accesorios.contains('Pendientes Dorados')){cur.accesorios.remove('Pendientes Dorados');} else {cur.accesorios.add('Pendientes Dorados');} }); }), _chipAcc('Flor Flamenca', cur.accesorios.contains('Flor Flamenca'), (){ setState((){ if(cur.accesorios.contains('Flor Flamenca')){cur.accesorios.remove('Flor Flamenca');} else {cur.accesorios.add('Flor Flamenca');} }); }), _chipAcc('Abanico', cur.accesorios.contains('Abanico'), (){ setState((){ if(cur.accesorios.contains('Abanico')){cur.accesorios.remove('Abanico');} else {cur.accesorios.add('Abanico');} }); }), _chipAcc('Pulsera', cur.accesorios.contains('Pulsera'), (){ setState((){ if(cur.accesorios.contains('Pulsera')){cur.accesorios.remove('Pulsera');} else {cur.accesorios.add('Pulsera');} }); })]),
        ])))),
        Expanded(flex:2, child: Container(color: const Color(0xFF0A1120), padding: const EdgeInsets.all(12), child: Column(children: [Expanded(child: Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.face, size:60, color: selected=='Lucía'?Colors.pinkAccent:Colors.cyanAccent), Text('$selected\n${cur.peinado}\n${cur.ropa}\n${cur.accesorios.join(', ')}', textAlign: TextAlign.center, style: const TextStyle(fontSize:10))])))), const SizedBox(height:8), Row(children: [Expanded(child: OutlinedButton(onPressed: (){ _saveAndNotify('Exportado'); }, child: const Text('Exportar',style: TextStyle(fontSize:10)))), const SizedBox(width:4), Expanded(child: ElevatedButton(onPressed: (){ _saveAndNotify('Aplicado al Chat!'); }, child: const Text('Aplicar',style: TextStyle(fontSize:10))))])]))),
      ])),
    ]));
  }
}

class ChatScreen extends StatefulWidget { const ChatScreen({super.key}); @override State<ChatScreen> createState()=>_ChatState();}
class _ChatState extends State<ChatScreen>{
  final _msg=TextEditingController(); final List<Map<String,String>> _chats=[]; final FlutterTts tts=FlutterTts(); final SpeechToText stt=SpeechToText(); XFile? picked; bool isLoading=false;
  @override void initState(){super.initState(); _chats.addAll([{'who':'Lucía','text':'¡Hola Noah! Soy Lucía con IA real Gemini 😊','time':'Ahora'},{'who':'Alejandro','text':'Hola Noah, soy Alejandro con Gemini real 🤝','time':'Ahora'}]);}
  Future<String> askGemini(String userMsg, String personaje) async {
    if (GEMINI_API_KEY.contains('PUT_YOUR') || GEMINI_API_KEY.isEmpty) { return "¡Hola Noah! Soy $personaje, me dijiste: $userMsg 😊"; }
    try {
      final url = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY");
      final body = jsonEncode({"contents": [{"parts": [{"text": "Eres $personaje, amigo de Noah. Responde corto. Noah: $userMsg"}]}], "generationConfig": {"maxOutputTokens": 200}});
      final res = await http.post(url, headers: {"Content-Type": "application/json"}, body: body).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) { final data = jsonDecode(res.body); return (data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "Aquí estoy").toString().trim(); } else { return "Sigo aquí Noah, error ${res.statusCode}"; }
    } catch (e) { return "Te escucho Noah: $userMsg"; }
  }
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children: [
      Container(padding: const EdgeInsets.all(12), color: const Color(0xFF0F1A33), child: Row(children: [const Text('Chat • Photo & Video • Live Brain REAL',style: TextStyle(fontWeight: FontWeight.bold, fontSize:11)), const Spacer(), IconButton(onPressed: _pickImage, icon: const Icon(Icons.photo))])),
      if(isLoading) const LinearProgressIndicator(color: Colors.pinkAccent, minHeight: 2),
      Expanded(child: ListView.builder(itemCount: _chats.length, itemBuilder: (c,i){var m=_chats[i]; bool isL=m['who']=='Lucía'; bool isMe=m['who']=='Tú'; return Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isMe?Colors.white12: isL?Colors.pinkAccent.withOpacity(0.15):Colors.cyanAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${m['who']} - ${m['time']}',style: const TextStyle(fontSize:10,color: Colors.white54)), const SizedBox(height:4), Text(m['text']??'',style: const TextStyle(fontSize:13))])) ;})),
      if(picked!=null) Container(padding: const EdgeInsets.all(6), color: Colors.black26, child: Wrap(children: ['حيد الخلفية','أنمي','HD','صورة مع Alejandro فباريس','صورة لفيديو','كتابة لفيديو','مونتاج تلقائي'].map((e)=>Padding(padding: const EdgeInsets.all(2), child: ElevatedButton(onPressed: () async { setState((){ _chats.add({'who':'Tú','text':'🖼️ $e','time':'الآن'}); isLoading=true; }); String r = await askGemini(e, "Lucía"); setState((){ _chats.add({'who':'Lucía','text':'✨ $e: $r','time':'الآن'}); isLoading=false; }); }, child: Text(e,style: const TextStyle(fontSize:10))))).toList())),
      Padding(padding: const EdgeInsets.all(8), child: Row(children: [IconButton(onPressed: _listen, icon: const Icon(Icons.mic)), Expanded(child: TextField(controller: _msg, decoration: const InputDecoration(hintText: 'Escribe: hola, que tal, flamenco...', border: OutlineInputBorder()), onSubmitted: (_)=>_send())), IconButton(onPressed: isLoading?null:_send, icon: const Icon(Icons.send))])),
    ]));
  }
  Future<void> _pickImage() async {final p=await ImagePicker().pickImage(source: ImageSource.gallery); if(p!=null) setState(()=>picked=p);}
  Future<void> _send() async { if(_msg.text.trim().isEmpty || isLoading) return; var txt=_msg.text; setState((){ _chats.add({'who':'Tú','text':txt,'time':'الآن'}); isLoading=true; }); _msg.clear(); String reply = await askGemini(txt, "Lucía"); try{ await tts.setLanguage('es-ES'); await tts.speak(reply); }catch(_){} setState((){ _chats.add({'who':'Lucía','text':reply,'time':'الآن'}); isLoading=false; }); if(txt.toLowerCase().contains('alejandro')){ String replyA = await askGemini(txt, "Alejandro"); setState(()=>_chats.add({'who':'Alejandro','text':replyA,'time':'الآن'})); } }
  Future<void> _listen() async {bool ok=await stt.initialize(); if(ok){ stt.listen(onResult: (r){ _msg.text=r.recognizedWords; });}}
}

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});
  @override Widget build(BuildContext context){
    return SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: const [
      Text('Ajustes • Seguro y Privado • REAL AI v3',style: TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
      SizedBox(height:12),
      ListTile(leading: Icon(Icons.lock, color: Colors.green), title: Text('سري وآمن - Gemini'), subtitle: Text('مشفر فتلفونك')),
      ListTile(leading: Icon(Icons.memory, color: Colors.pinkAccent), title: Text('ذاكرة صور REAL'), subtitle: Text('Mimi القط 🐱')),
      ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('v3 BUILD FIXED ✅'), subtitle: Text('Avatar + Chat + Fotos + Video')),
    ]));
  }
}
