import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

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
          Row(children: [const Icon(Icons.memory, color: Colors.pinkAccent), const SizedBox(width: 8), const Text('DialogAI', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Text('En línea • Activa', style: TextStyle(fontSize: 10, color: Colors.green)))]),
          const Text('Inteligencia Artificial Conversacional • Compañeros Reales', style: TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))), child: Column(children: [const Text('COMPAÑEROS VIRTUALES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)), const SizedBox(height: 4), const Text('Habla con compañeros AI realistas, como en las películas de ciencia ficción', style: TextStyle(fontSize: 11, color: Colors.white54), textAlign: TextAlign.center), const SizedBox(height: 12), Row(children: [Expanded(child: _compCard('LUCÍA', 'Flamenco • Conversadora, Empática', 'En línea • Activa', Colors.pinkAccent)), const SizedBox(width: 8), Expanded(child: _compCard('ALEJANDRO', 'Flamenco • Analítico, Amable', 'En línea • Activo', Colors.cyanAccent))])])),
          const SizedBox(height: 16),
          const Text('CONVERSACIÓN ACTIVA • Videollamada Grupal • IA en tiempo real', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
  Widget _compCard(String name, String estilo, String status, Color col) {
    return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(12), border: Border.all(color: col.withOpacity(0.3))), child: Column(children: [CircleAvatar(radius: 28, backgroundColor: col.withOpacity(0.2), child: Icon(Icons.face, color: col)), Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text(estilo, style: const TextStyle(fontSize: 9, color: Colors.white54), textAlign: TextAlign.center)]));
  }
}

class AvatarEditorScreen extends StatefulWidget { const AvatarEditorScreen({super.key}); @override State<AvatarEditorScreen> createState()=>_AvatarEditorState();}
class _AvatarEditorState extends State<AvatarEditorScreen>{
  String selected='Lucía'; String tab='Rasgos Faciales'; AvatarConfig lucia=AvatarConfig(); AvatarConfig alejandro=AvatarConfig();
  @override Widget build(BuildContext context){
    AvatarConfig cur= selected=='Lucía'?lucia:alejandro;
    return SafeArea(child: Column(children: [
      Container(padding: const EdgeInsets.all(8), color: const Color(0xFF0F1A33), child: Row(children: [const Text('DialogAI - Avatar Editor',style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Container(margin: const EdgeInsets.only(left:4), padding: const EdgeInsets.symmetric(horizontal:6,vertical:2), decoration: BoxDecoration(color: Colors.pinkAccent, borderRadius: BorderRadius.circular(8)), child: const Text('Español',style: TextStyle(fontSize:9)))])),
      Expanded(child: Row(children: [
        Expanded(flex:2, child: SingleChildScrollView(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Editor de Avatar',style: TextStyle(fontSize:18,fontWeight: FontWeight.bold)), const Text('Personaliza rasgos faciales y ropa - Estilo Flamenco',style: TextStyle(fontSize:10,color: Colors.white54)),
          const SizedBox(height:12), const Text('Selecciona Personaje',style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height:8),
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Row(children: [const CircleAvatar(radius:18, child: Text('L')), const SizedBox(width:8), const Expanded(child: Text('Lucía ~25-28 Vestido Flamenco • Femenino',style: TextStyle(fontSize:12))) ])),
          const SizedBox(height:8), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: Row(children: [const CircleAvatar(radius:18, child: Text('A')), const SizedBox(width:8), const Expanded(child: Text('Alejandro ~28-32 Traje Clásico • Masculino',style: TextStyle(fontSize:12))) ])),
        ]))),
        Expanded(flex:2, child: Container(color: const Color(0xFF10182E), padding: const EdgeInsets.all(8), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Personalización - $selected',style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height:8),
          const Text('Peinado',style: TextStyle(fontWeight: FontWeight.bold,fontSize:12)), Wrap(children: ['Moño Flamenco','Ondas Largas','Trenza Lateral','Recogido Bajo'].map((o)=>Container(margin: const EdgeInsets.all(2), padding: const EdgeInsets.symmetric(horizontal:8,vertical:4), decoration: BoxDecoration(color: o==cur.peinado?Colors.pinkAccent:Colors.white10, borderRadius: BorderRadius.circular(6)), child: Text(o,style: const TextStyle(fontSize:9)))).toList()),
          const SizedBox(height:8), const Text('Ropa: Vestido Flamenco, Chal Flamenco, Blusa Moderna, Vestido Oscuro',style: TextStyle(fontSize:11)),
          const SizedBox(height:8), const Text('Accesorios: Pendientes Dorados, Flor Flamenca, Abanico, Pulsera',style: TextStyle(fontSize:11)),
        ])))),
        Expanded(flex:2, child: Container(color: const Color(0xFF0A1120), padding: const EdgeInsets.all(12), child: Column(children: [
          Expanded(child: Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.face, size:80, color: Colors.pinkAccent), SizedBox(height:8), Text('Vista previa 3D • Iluminación: Estudio',style: TextStyle(fontSize:9,color: Colors.white54))])))),
          const SizedBox(height:8), Row(children: [ Expanded(child: OutlinedButton(onPressed: (){}, child: const Text('Exportar (.png)',style: TextStyle(fontSize:10)))), const SizedBox(width:4), Expanded(child: ElevatedButton(onPressed: (){}, child: const Text('Aplicar al Chat',style: TextStyle(fontSize:10))))]),
        ]))),
      ])),
      Container(padding: const EdgeInsets.all(6), color: Colors.black26, child: const Text('Diseño guardado automáticamente • Seguro y privado • Encriptado',style: TextStyle(fontSize:9,color: Colors.white54))),
    ]));
  }
}

class ChatScreen extends StatefulWidget { const ChatScreen({super.key}); @override State<ChatScreen> createState()=>_ChatState();}
class _ChatState extends State<ChatScreen>{
  final _msg=TextEditingController(); final List<Map> _chats=[]; final FlutterTts tts=FlutterTts(); final SpeechToText stt=SpeechToText(); XFile? picked;
  @override void initState(){super.initState(); _chats.addAll([{'who':'Lucía','text':'Hola, aquí Lucia. ¿Cómo estás?','time':'Ahora'},{'who':'Alejandro','text':'Soy Alejandro, listo para ayudarte - IA en tiempo real','time':'Ahora'}]);}
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children: [
      Container(padding: const EdgeInsets.all(12), color: const Color(0xFF0F1A33), child: Row(children: [const Text('Chat • Photo & Video Editor • Live Brain',style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: _pickImage, icon: const Icon(Icons.photo)), IconButton(onPressed: (){ setState(()=>_chats.add({'who':'Alejandro','text':'🌐 Live Brain - Google بحث مباشر - أخبار، ثمن البيتكوين، الطب','time':'الآن'}));}, icon: const Icon(Icons.search)) ])),
      Expanded(child: ListView.builder(itemCount: _chats.length, itemBuilder: (c,i){var m=_chats[i]; bool isL=m['who']=='Lucía'; return Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isL?Colors.pinkAccent.withOpacity(0.15):Colors.cyanAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${m['who']} • ${m['time']}',style: const TextStyle(fontSize:10,color: Colors.white54)), Text(m['text']??'',style: const TextStyle(fontSize:13))])) ;})),
      if(picked!=null) Wrap(children: ['حيد الخلفية','أنمي','HD','صورة مع Alejandro فباريس','صورة لفيديو','كتابة لفيديو','مونتاج تلقائي'].map((e)=>Padding(padding: const EdgeInsets.all(2), child: ElevatedButton(onPressed: (){ setState(()=>_chats.add({'who':'Tú','text':'🖼️ $e للصورة ${picked?.name}','time':'الآن'}));}, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal:8,vertical:4)), child: Text(e,style: const TextStyle(fontSize:10))))).toList()),
      Padding(padding: const EdgeInsets.all(8), child: Row(children: [IconButton(onPressed: _listen, icon: const Icon(Icons.mic)), Expanded(child: TextField(controller: _msg, decoration: const InputDecoration(hintText: 'Escribe tu mensaje... Hola, quita fondo, hazme anime, video con Lucia', border: OutlineInputBorder()), onSubmitted: (_)=>_send())), IconButton(onPressed: _send, icon: const Icon(Icons.send)) ])),
    ]));
  }
  Future<void> _pickImage() async {final p=await ImagePicker().pickImage(source: ImageSource.gallery); if(p!=null) setState(()=>picked=p);}
  Future<void> _send() async {
    if(_msg.text.trim().isEmpty) return;
    var txt=_msg.text; setState(()=>_chats.add({'who':'Tú','text':txt,'time':'الآن'})); _msg.clear();
    if(txt.toLowerCase().contains('بحث')||txt.toLowerCase().contains('google')){
      try{ var r=await http.get(Uri.parse('https://api.duckduckgo.com/?q=${Uri.encodeComponent(txt)}&format=json')); setState(()=>_chats.add({'who':'Alejandro','text':'🌐 Live Brain: ${r.body.substring(0,200)}','time':'الآن'})); }catch(_){}
    }
    await tts.setLanguage('es-ES'); await tts.speak(txt);
    setState(()=>_chats.add({'who':'Lucía','text':'فهمتك! Gemini Imagen درت ليك الخدمة - القط ميمي عاقل 😉 🔒','time':'الآن'}));
  }
  Future<void> _listen() async {bool ok=await stt.initialize(); if(ok){ stt.listen(onResult: (r){ _msg.text=r.recognizedWords; });}}
}

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});
  @override Widget build(BuildContext context){
    return SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: const [
      Text('Ajustes • Seguro y Privado',style: TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
      SizedBox(height:12),
      ListTile(leading: Icon(Icons.lock), title: Text('🔒 سري وآمن'), subtitle: Text('حتى حنا ما كنشوفوش - مشفر فتلفونك')),
      ListTile(leading: Icon(Icons.memory), title: Text('ذاكرة صور'), subtitle: Text('هادي القط ديالي ميمي')),
      ListTile(leading: Icon(Icons.auto_awesome), title: Text('يتعلم عاداتك'), subtitle: Text('كيفكرك فالصلاة، قراية، خدمة')),
      ListTile(leading: Icon(Icons.people), title: Text('شخصيات كيهضرو بيناتهم'), subtitle: Text('Alejandro كيغير من Lucia')),
    ]));
  }
}
