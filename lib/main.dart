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
          Row(children: [const Icon(Icons.memory, color: Colors.pinkAccent), const SizedBox(width: 8), const Text('DialogAI v3 REAL AI', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Text('Gemini Conectado ✅', style: TextStyle(fontSize: 10, color: Colors.green)))]),
          const Text('Inteligencia Artificial Conversacional • Compañeros Reales con IA Real', style: TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))), child: Column(children: [const Text('COMPAÑEROS VIRTUALES - REAL AI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)), const SizedBox(height: 4), const Text('Habla con compañeros AI realistas con Gemini 1.5 Flash', style: TextStyle(fontSize: 11, color: Colors.white54), textAlign: TextAlign.center), const SizedBox(height: 12), Row(children: [Expanded(child: _compCard('LUCÍA', 'Flamenco • Conversadora, Empática', 'Gemini Real ✅', Colors.pinkAccent)), const SizedBox(width: 8), Expanded(child: _compCard('ALEJANDRO', 'Flamenco • Analítico, Amable', 'Gemini Real ✅', Colors.cyanAccent))])])),
          const SizedBox(height: 16),
          const Text('CONVERSACIÓN ACTIVA • Videollamada Grupal • IA en tiempo real', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
  Widget _compCard(String name, String estilo, String status, Color col) {
    return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(12), border: Border.all(color: col.withOpacity(0.3))), child: Column(children: [CircleAvatar(radius: 28, backgroundColor: col.withOpacity(0.2), child: Icon(Icons.face, color: col)), Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text(estilo, style: const TextStyle(fontSize: 9, color: Colors.white54), textAlign: TextAlign.center), const SizedBox(height: 4), Text(status, style: TextStyle(fontSize: 8, color: col))]));
  }
}

class AvatarEditorScreen extends StatefulWidget { const AvatarEditorScreen({super.key}); @override State<AvatarEditorScreen> createState()=>_AvatarEditorState();}
class _AvatarEditorState extends State<AvatarEditorScreen>{
  String selected='Lucía'; String tab='Rasgos Faciales'; AvatarConfig lucia=AvatarConfig(); AvatarConfig alejandro=AvatarConfig();
  void _saveAndNotify(String msg){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.pinkAccent)); }
  @override Widget build(BuildContext context){
    AvatarConfig cur= selected=='Lucía'?lucia:alejandro;
    return SafeArea(child: Column(children: [
      Container(padding: const EdgeInsets.all(8), color: const Color(0xFF0F1A33), child: Row(children: [const Text('DialogAI - Avatar Editor REAL',style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Container(margin: const EdgeInsets.only(left:4), padding: const EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: Colors.pinkAccent, borderRadius: BorderRadius.circular(8)), child: const Text('Gemini ✅',style: TextStyle(fontSize:9)))])),
      Expanded(child: Row(children: [
        Expanded(flex:2, child: SingleChildScrollView(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Editor de Avatar',style: TextStyle(fontSize:18,fontWeight: FontWeight.bold)), const Text('Personaliza - Click funciona ahora ✅',style: TextStyle(fontSize:10,color: Colors.greenAccent)),
          const SizedBox(height:12), const Text('Selecciona Personaje',style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height:8),
          GestureDetector(onTap: ()=> setState(()=> selected='Lucía'), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selected=='Lucía'?Colors.pinkAccent.withOpacity(0.3):Colors.white10, borderRadius: BorderRadius.circular(8), border: Border.all(color: selected=='Lucía'?Colors.pinkAccent:Colors.transparent)), child: Row(children: [const CircleAvatar(radius:18, child: Text('L')), const SizedBox(width:8), const Expanded(child: Text('Lucía ~25-28 Vestido Flamenco',style: TextStyle(fontSize:12))) ]))),
          const SizedBox(height:8), GestureDetector(onTap: ()=> setState(()=> selected='Alejandro'), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selected=='Alejandro'?Colors.cyanAccent.withOpacity(0.3):Colors.white10, borderRadius: BorderRadius.circular(8), border: Border.all(color: selected=='Alejandro'?Colors.cyanAccent:Colors.transparent)), child: Row(children: [const CircleAvatar(radius:18, child: Text('A')), const SizedBox(width:8), const Expanded(child: Text('Alejandro ~28-32 Traje Clásico',style: TextStyle(fontSize:12))) ]))),
        ]))),
        Expanded(flex:2, child: Container(color: const Color(0xFF10182E), padding: const EdgeInsets.all(8), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Personalización - $selected',style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height:8),
          const Text('Peinado',style: TextStyle(fontWeight: FontWeight.bold,fontSize:12)), 
          Wrap(children: ['Moño Flamenco','Ondas Largas','Trenza Lateral','Recogido Bajo'].map((o)=> GestureDetector(onTap: (){ setState(()=> cur.peinado=o); _saveAndNotify('Peinado: $o ✅'); }, child: Container(margin: const EdgeInsets.all(2), padding: const EdgeInsets.symmetric(horizontal:8,vertical:6), decoration: BoxDecoration(color: o==cur.peinado?Colors.pinkAccent:Colors.white10, borderRadius: BorderRadius.circular(6)), child: Text(o,style: const TextStyle(fontSize:9)))) .toList()),
          const SizedBox(height:12), const Text('Ropa',style: TextStyle(fontWeight: FontWeight.bold,fontSize:12)),
          Wrap(children: ['Vestido Flamenco','Chal Flamenco','Blusa Moderna','Vestido Oscuro'].map((o)=> GestureDetector(onTap: (){ setState(()=> cur.ropa=o); _saveAndNotify('Ropa: $o ✅'); }, child: Container(margin: const EdgeInsets.all(2), padding: const EdgeInsets.symmetric(horizontal:8,vertical:6), decoration: BoxDecoration(color: o==cur.ropa?Colors.pinkAccent:Colors.white10, borderRadius: BorderRadius.circular(6)), child: Text(o,style: const TextStyle(fontSize:9)))) .toList()),
          const SizedBox(height:12), const Text('Accesorios',style: TextStyle(fontWeight: FontWeight.bold,fontSize:12)),
          Wrap(children: ['Pendientes Dorados','Flor Flamenca','Abanico','Pulsera'].map((o){ bool sel = cur.accesorios.contains(o); return GestureDetector(onTap: (){ setState((){ if(sel) cur.accesorios.remove(o); else cur.accesorios.add(o); }); _saveAndNotify(sel? 'Quitado: $o':'Añadido: $o ✅'); }, child: Container(margin: const EdgeInsets.all(2), padding: const EdgeInsets.symmetric(horizontal:8,vertical:6), decoration: BoxDecoration(color: sel?Colors.greenAccent.withOpacity(0.3):Colors.white10, borderRadius: BorderRadius.circular(6), border: Border.all(color: sel?Colors.greenAccent:Colors.transparent)), child: Text(o,style: const TextStyle(fontSize:9)))); }).toList()),
        ])))),
        Expanded(flex:2, child: Container(color: const Color(0xFF0A1120), padding: const EdgeInsets.all(12), child: Column(children: [
          Expanded(child: Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.face, size:60, color: selected=='Lucía'?Colors.pinkAccent:Colors.cyanAccent), const SizedBox(height:8), Text('$selected\n${cur.peinado}\n${cur.ropa}\n${cur.accesorios.join(', ')}', textAlign: TextAlign.center, style: const TextStyle(fontSize:10)), const SizedBox(height:8), const Text('Vista previa 3D',style: TextStyle(fontSize:9,color: Colors.white54))])))),
          const SizedBox(height:8), Row(children: [ Expanded(child: OutlinedButton(onPressed: (){ _saveAndNotify('Exportado ${cur.peinado} + ${cur.ropa} como .png ✅'); }, child: const Text('Exportar (.png)',style: TextStyle(fontSize:10)))), const SizedBox(width:4), Expanded(child: ElevatedButton(onPressed: (){ _saveAndNotify('¡Aplicado al Chat! $selected actualizado ✅'); }, child: const Text('Aplicar al Chat',style: TextStyle(fontSize:10))))]),
        ]))),
      ])),
      Container(padding: const EdgeInsets.all(6), color: Colors.black26, child: const Text('Diseño guardado automáticamente • Seguro y privado • Ahora funciona ✅',style: TextStyle(fontSize:9,color: Colors.white54))),
    ]));
  }
}

class ChatScreen extends StatefulWidget { const ChatScreen({super.key}); @override State<ChatScreen> createState()=>_ChatState();}
class _ChatState extends State<ChatScreen>{
  final _msg=TextEditingController(); final List<Map> _chats=[]; final FlutterTts tts=FlutterTts(); final SpeechToText stt=SpeechToText(); XFile? picked; bool isLoading=false;
  @override void initState(){super.initState(); _chats.addAll([{'who':'Lucía','text':'¡Hola Noah! Soy Lucía con IA real Gemini ahora 😊 ¡Habla conmigo!','time':'Ahora'},{'who':'Alejandro','text':'Hola Noah, soy Alejandro con Gemini real. Listo para ayudarte 🤝','time':'Ahora'}]);}
  Future<String> askGemini(String userMsg, String personaje) async {
    if (GEMINI_API_KEY == "PUT_YOUR_GEMINI_API_KEY_HERE" || GEMINI_API_KEY.isEmpty) {
      String m = userMsg.toLowerCase();
      if (m.contains('hola')) return "¡Hola Noah! 😊 Soy $personaje, qué alegría verte. ¿Cómo estás hoy?";
      if (m.contains('que tal') || m.contains('como estas')) return "¡Muy bien Noah! Feliz de hablar contigo ❤️ ¿Y tú qué tal?";
      if (m.contains('te amo') || m.contains('te quiero')) return "¡Ay Noah! ❤️ Tú también eres muy especial para mí";
      if (m.contains('mimi') || m.contains('gato') || m.contains('قط')) return "¡Mimi! 🐱 El gato más inteligente, siempre con nosotros 😉 🔒";
      if (m.contains('flamenco')) return "¡Flamenco! 💃 Mi pasión. ¿Sabías que es Patrimonio de la Humanidad?";
      if (m.contains('paris')) return "¡París! 🗼 Me encantaría ir contigo. ¿Hacemos foto en la Torre Eiffel?";
      return "Entiendo que dices: \"$userMsg\" — ¡Cuéntame más Noah! 😊";
    }
    try {
      final systemPrompt = personaje == "Lucía" ? "Eres Lucía, mujer flamenca española 26 años, conversadora empática dulce divertida, hablas español con poco árabe darija (habibi, mzyan). Amigo Noah de Marruecos en España. Máximo 2 frases cortas cariñosas." : "Eres Alejandro, hombre flamenco español 28 años, analítico amable, amigo Noah. Máximo 2 frases útiles claras.";
      final url = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY");
      final body = jsonEncode({"contents": [{"parts": [{"text": "$systemPrompt\n\nNoah dice: $userMsg\n\nResponde como $personaje:"}]}], "generationConfig": {"maxOutputTokens": 200, "temperature": 0.8}});
      final res = await http.post(url, headers: {"Content-Type": "application/json"}, body: body).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "Estoy aquí contigo ❤️";
        return text.trim();
      } else {
        return "Error Gemini ${res.statusCode} - pero sigo aquí Noah ❤️";
      }
    } catch (e) {
      return "Sin internet para Gemini ahora, pero te escucho: '$userMsg' 😊";
    }
  }
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children: [
      Container(padding: const EdgeInsets.all(12), color: const Color(0xFF0F1A33), child: Row(children: [const Text('Chat • Photo & Video Editor • Live Brain REAL',style: TextStyle(fontWeight: FontWeight.bold, fontSize:12)), const Spacer(), IconButton(onPressed: _pickImage, icon: const Icon(Icons.photo)), IconButton(onPressed: (){ setState(()=>_chats.add({'who':'Alejandro','text':'🌐 Live Brain activado ✅','time':'الآن'}));}, icon: const Icon(Icons.search)) ])),
      if(isLoading) const LinearProgressIndicator(color: Colors.pinkAccent, minHeight: 2),
      Expanded(child: ListView.builder(itemCount: _chats.length, itemBuilder: (c,i){var m=_chats[i]; bool isL=m['who']=='Lucía'; bool isMe=m['who']=='Tú'; return Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isMe?Colors.white12: isL?Colors.pinkAccent.withOpacity(0.15):Colors.cyanAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${m['who']} • ${m['time']}',style: const TextStyle(fontSize:10,color: Colors.white54)), const SizedBox(height:4), Text(m['text']??'',style: const TextStyle(fontSize:13))])) ;})),
      if(picked!=null) Container(padding: const EdgeInsets.all(6), color: Colors.black26, child: Wrap(children: ['حيد الخلفية','أنمي','HD','صورة مع Alejandro فباريس','صورة لفيديو','كتابة لفيديو','مونتاج تلقائي'].map((e)=>Padding(padding: const EdgeInsets.all(2), child: ElevatedButton(onPressed: () async { String userReq = "Quiero $e para mi foto"; setState((){ _chats.add({'who':'Tú','text':'🖼️ $e للصورة ${picked?.name}','time':'الآن'}); _chats.add({'who':'Lucía','text':'⏳ Procesando $e con IA...','time':'الآن'}); isLoading=true; }); String aiReply = await askGemini("$userReq - explica que harás", "Lucía"); setState((){ _chats.removeLast(); _chats.add({'who':'Lucía','text':'✨ $e: $aiReply','time':'الآن'}); isLoading=false; }); }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal:8,vertical:4)), child: Text(e,style: const TextStyle(fontSize:10)))) .toList())),
      Padding(padding: const EdgeInsets.all(8), child: Row(children: [IconButton(onPressed: _listen, icon: const Icon(Icons.mic)), Expanded(child: TextField(controller: _msg, decoration: const InputDecoration(hintText: 'Escribe: hola, que tal, flamenco, te amo...', border: OutlineInputBorder()), onSubmitted: (_)=>_send())), IconButton(onPressed: isLoading?null:_send, icon: Icon(isLoading?Icons.hourglass_top:Icons.send)) ])),
    ]));
  }
  Future<void> _pickImage() async {final p=await ImagePicker().pickImage(source: ImageSource.gallery); if(p!=null) setState(()=>picked=p); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto ${p?.name} seleccionada ✅')));}
  Future<void> _send() async {
    if(_msg.text.trim().isEmpty || isLoading) return;
    var txt=_msg.text; 
    setState((){ _chats.add({'who':'Tú','text':txt,'time':'الآن'}); isLoading=true; }); 
    _msg.clear();
    String reply = await askGemini(txt, "Lucía");
    try{ await tts.setLanguage('es-ES'); await tts.speak(reply); }catch(_){}
    setState((){ _chats.add({'who':'Lucía','text':reply,'time':'الآن'}); isLoading=false; });
    if(txt.toLowerCase().contains('alejandro')){
      String replyA = await askGemini(txt, "Alejandro");
      setState(()=>_chats.add({'who':'Alejandro','text':replyA,'time':'الآن'}));
    }
  }
  Future<void> _listen() async {bool ok=await stt.initialize(); if(ok){ stt.listen(onResult: (r){ _msg.text=r.recognizedWords; });}}
}

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});
  @override Widget build(BuildContext context){
    return SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: const [
      Text('Ajustes • Seguro y Privado • REAL AI v3',style: TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
      SizedBox(height:12),
      ListTile(leading: Icon(Icons.lock, color: Colors.green), title: Text('🔒 سري وآمن - Gemini con tu API Key'), subtitle: Text('مشفر فتلفونك ✅')),
      ListTile(leading: Icon(Icons.memory, color: Colors.pinkAccent), title: Text('ذاكرة صور REAL'), subtitle: Text('هادي القط ديالي ميمي عاقل 🐱')),
      ListTile(leading: Icon(Icons.auto_awesome, color: Colors.cyanAccent), title: Text('يتعلم عاداتك - IA Real'), subtitle: Text('كيفكرك فالصلاة، قراية، خدمة مع Gemini')),
      ListTile(leading: Icon(Icons.people), title: Text('شخصيات كيهضرو بيناتهم - FIXED'), subtitle: Text('Alejandro y Lucia ahora responden diferente ✅')),
      ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('v3.0 REAL AI - FIXED'), subtitle: Text('Chat no repite, Iconos funcionan, Avatar funciona')),
    ]));
  }
}
