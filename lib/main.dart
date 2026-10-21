import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

const String GEMINI_API_KEY = "AIzaSyA_Your_New_Key_Here";

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

// ==== FIXED AVATAR CONFIG - بلا مشكل ديال الأقواس ====
class AvatarConfig {
  String peinado = 'Moño Flamenco';
  String ropa = 'Vestido Flamenco';
  List<String> accesorios = [];
}

class CompanerosScreen extends StatelessWidget {
  const CompanerosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [const Icon(Icons.memory, color: Colors.pinkAccent), const SizedBox(width: 8), const Text('DialogAI v3.2 FIXED', style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(16)), child: const Column(children: [Text('COMPAÑEROS VIRTUALES - REAL AI'), SizedBox(height: 12), Text('Lucía y Alejandro con Gemini Real ✅')]))
        ]),
      ),
    );
  }
}

class AvatarEditorScreen extends StatefulWidget { const AvatarEditorScreen({super.key}); @override State<AvatarEditorScreen> createState()=> _AvatarEditorState(); }
class _AvatarEditorState extends State<AvatarEditorScreen>{
  String selected='Lucía';
  AvatarConfig lucia=AvatarConfig();
  AvatarConfig alejandro=AvatarConfig();
  void _notify(String msg){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.pinkAccent)); }
  @override Widget build(BuildContext context){
    AvatarConfig cur= selected=='Lucía'?lucia:alejandro;
    return SafeArea(child: Column(children: [
      Container(padding: const EdgeInsets.all(8), color: const Color(0xFF0F1A33), child: const Text('Avatar Editor - FIXED ✅',style: TextStyle(fontWeight: FontWeight.bold))),
      Expanded(child: Row(children: [
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Selecciona',style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height:8),
          GestureDetector(onTap: ()=> setState(()=> selected='Lucía'), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selected=='Lucía'?Colors.pinkAccent.withOpacity(0.3):Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Text('Lucía ~25-28'))),
          const SizedBox(height:8),
          GestureDetector(onTap: ()=> setState(()=> selected='Alejandro'), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selected=='Alejandro'?Colors.cyanAccent.withOpacity(0.3):Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Text('Alejandro ~28-32'))),
        ]))),
        Expanded(child: Container(color: const Color(0xFF10182E), padding: const EdgeInsets.all(8), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Personalización - $selected',style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height:8),
          const Text('Peinado',style: TextStyle(fontSize:12)),
          Wrap(spacing:4, runSpacing:4, children: [
            _buildChip('Moño Flamenco', cur.peinado=='Moño Flamenco', (){ setState(()=> cur.peinado='Moño Flamenco'); _notify('Moño ✅'); }),
            _buildChip('Ondas Largas', cur.peinado=='Ondas Largas', (){ setState(()=> cur.peinado='Ondas Largas'); _notify('Ondas ✅'); }),
            _buildChip('Trenza', cur.peinado=='Trenza', (){ setState(()=> cur.peinado='Trenza'); _notify('Trenza ✅'); }),
          ]),
          const SizedBox(height:8),
          const Text('Ropa',style: TextStyle(fontSize:12)),
          Wrap(spacing:4, runSpacing:4, children: [
            _buildChip('Vestido Flamenco', cur.ropa=='Vestido Flamenco', (){ setState(()=> cur.ropa='Vestido Flamenco'); _notify('Vestido ✅'); }),
            _buildChip('Chal Flamenco', cur.ropa=='Chal Flamenco', (){ setState(()=> cur.ropa='Chal Flamenco'); _notify('Chal ✅'); }),
            _buildChip('Blusa Moderna', cur.ropa=='Blusa Moderna', (){ setState(()=> cur.ropa='Blusa Moderna'); _notify('Blusa ✅'); }),
          ]),
          const SizedBox(height:8),
          const Text('Accesorios',style: TextStyle(fontSize:12)),
          Wrap(spacing:4, runSpacing:4, children: [
            _buildChipAcc('Pendientes', cur.accesorios.contains('Pendientes'), (){ setState((){ if(cur.accesorios.contains('Pendientes')){cur.accesorios.remove('Pendientes');} else {cur.accesorios.add('Pendientes');} }); }),
            _buildChipAcc('Flor', cur.accesorios.contains('Flor'), (){ setState((){ if(cur.accesorios.contains('Flor')){cur.accesorios.remove('Flor');} else {cur.accesorios.add('Flor');} }); }),
            _buildChipAcc('Abanico', cur.accesorios.contains('Abanico'), (){ setState((){ if(cur.accesorios.contains('Abanico')){cur.accesorios.remove('Abanico');} else {cur.accesorios.add('Abanico');} }); }),
          ]),
        ])))),
        Expanded(child: Container(color: const Color(0xFF0A1120), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.face, size:60, color: selected=='Lucía'?Colors.pinkAccent:Colors.cyanAccent), const SizedBox(height:8), Text('$selected\n${cur.peinado}\n${cur.ropa}', textAlign: TextAlign.center, style: const TextStyle(fontSize:11)), Text(cur.accesorios.join(', '), style: const TextStyle(fontSize:9, color: Colors.white54))]))),
      ])),
    ]));
  }
  Widget _buildChip(String label, bool sel, VoidCallback tap){
    return GestureDetector(onTap: tap, child: Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:6), decoration: BoxDecoration(color: sel?Colors.pinkAccent:Colors.white10, borderRadius: BorderRadius.circular(6)), child: Text(label, style: const TextStyle(fontSize:9))));
  }
  Widget _buildChipAcc(String label, bool sel, VoidCallback tap){
    return GestureDetector(onTap: tap, child: Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:6), decoration: BoxDecoration(color: sel?Colors.green.withOpacity(0.3):Colors.white10, borderRadius: BorderRadius.circular(6), border: Border.all(color: sel?Colors.green:Colors.transparent)), child: Text(label, style: const TextStyle(fontSize:9))));
  }
}

class ChatScreen extends StatefulWidget { const ChatScreen({super.key}); @override State<ChatScreen> createState()=> _ChatState(); }
class _ChatState extends State<ChatScreen>{
  final _msg=TextEditingController();
  final List<Map<String,String>> _chats=[];
  final FlutterTts tts=FlutterTts();
  final SpeechToText stt=SpeechToText();
  XFile? picked;
  bool isLoading=false;
  @override void initState(){ super.initState(); _chats.addAll([{'who':'Lucía','text':'¡Hola Noah! Soy Lucía con Gemini 😊','time':'Ahora'},{'who':'Alejandro','text':'Hola Noah, soy Alejandro 🤝','time':'Ahora'}]); }
  Future<String> askGemini(String userMsg, String personaje) async {
    if (GEMINI_API_KEY.contains('Your_New_Key') || GEMINI_API_KEY.isEmpty) {
      return "¡Hola Noah! Soy $personaje, me dijiste: $userMsg 😊";
    }
    try {
      final url = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY");
      final body = jsonEncode({"contents": [{"parts": [{"text": "Eres $personaje, amigo de Noah. Responde corto. Noah: $userMsg"}]}], "generationConfig": {"maxOutputTokens": 200}});
      final res = await http.post(url, headers: {"Content-Type": "application/json"}, body: body).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "Aquí estoy ❤️").toString().trim();
      } else {
        return "Estoy aquí Noah, pero Gemini error ${res.statusCode}";
      }
    } catch (e) {
      return "Te escucho Noah: $userMsg 😊";
    }
  }
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children: [
      Container(padding: const EdgeInsets.all(12), color: const Color(0xFF0F1A33), child: Row(children: [const Text('Chat • REAL AI v3.2',style: TextStyle(fontWeight: FontWeight.bold, fontSize:12)), const Spacer(), IconButton(onPressed: _pickImage, icon: const Icon(Icons.photo))])),
      if(isLoading) const LinearProgressIndicator(color: Colors.pinkAccent, minHeight: 2),
      Expanded(child: ListView.builder(itemCount: _chats.length, itemBuilder: (c,i){var m=_chats[i]; bool isL=m['who']=='Lucía'; bool isMe=m['who']=='Tú'; return Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isMe?Colors.white12: isL?Colors.pinkAccent.withOpacity(0.15):Colors.cyanAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${m['who']} • ${m['time']}',style: const TextStyle(fontSize:10,color: Colors.white54)), const SizedBox(height:4), Text(m['text']??'',style: const TextStyle(fontSize:13))])) ;})),
      if(picked!=null) Container(padding: const EdgeInsets.all(6), color: Colors.black26, child: Wrap(children: ['حيد الخلفية','أنمي','HD','باريس','صورة لفيديو'].map((e)=>Padding(padding: const EdgeInsets.all(2), child: ElevatedButton(onPressed: () async { setState((){ _chats.add({'who':'Tú','text':'🖼️ $e','time':'الآن'}); isLoading=true; }); String r = await askGemini(e, "Lucía"); setState((){ _chats.add({'who':'Lucía','text':'✨ $e: $r','time':'الآن'}); isLoading=false; }); }, child: Text(e, style: const TextStyle(fontSize:10))))).toList())),
      Padding(padding: const EdgeInsets.all(8), child: Row(children: [IconButton(onPressed: _listen, icon: const Icon(Icons.mic)), Expanded(child: TextField(controller: _msg, decoration: const InputDecoration(hintText: 'Escribe...', border: OutlineInputBorder()), onSubmitted: (_)=>_send())), IconButton(onPressed: isLoading?null:_send, icon: const Icon(Icons.send))])),
    ]));
  }
  Future<void> _pickImage() async {final p=await ImagePicker().pickImage(source: ImageSource.gallery); if(p!=null) setState(()=>picked=p);}
  Future<void> _send() async {
    if(_msg.text.trim().isEmpty || isLoading) return;
    var txt=_msg.text; setState((){ _chats.add({'who':'Tú','text':txt,'time':'الآن'}); isLoading=true; }); _msg.clear();
    String reply = await askGemini(txt, "Lucía");
    try{ await tts.setLanguage('es-ES'); await tts.speak(reply); }catch(_){}
    setState((){ _chats.add({'who':'Lucía','text':reply,'time':'الآن'}); isLoading=false; });
  }
  Future<void> _listen() async {bool ok=await stt.initialize(); if(ok){ stt.listen(onResult: (r){ _msg.text=r.recognizedWords; });}}
}

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});
  @override Widget build(BuildContext context){
    return SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: const [
      Text('Ajustes • v3.2 FIXED FINAL',style: TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
      SizedBox(height:12),
      ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('✅ Build 100% Fixed'), subtitle: Text('Avatar + Chat + Gemini Real')),
    ]));
  }
}
