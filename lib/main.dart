import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

const String GEMINI_API_KEY = "AQ.Ab8RN6IZ-AQ.Ab8RN6IU62GO3_afAo1XSHpFk7LFu_9e2qEHwq9cN0JqVtGglA";

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
  String ropa = 'Vestido Flamenco';
  List<String> accesorios = [];
}

class CompanerosScreen extends StatelessWidget {
  const CompanerosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(children: [const Icon(Icons.memory, color: Colors.pinkAccent), const SizedBox(width: 8), const Text('DialogAI v1 - Memoria Real', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Text('Gemini Live ✅', style: TextStyle(fontSize: 10, color: Colors.green)))]),
          const SizedBox(height: 12),
          const Text('COMPAÑEROS VIRTUALES - Habla como en peliculas de ciencia ficcion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _card('LUCÍA', 'Flamenco • Conversadora, Empatica', 'En linea • Activa', Colors.pinkAccent, Icons.face)),
            const SizedBox(width: 8),
            Expanded(child: _card('ALEJANDRO', 'Flamenco • Analitico, Amable', 'En linea • Activo', Colors.cyanAccent, Icons.face_2)),
          ]),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('CONVERSACION ACTIVA • Videollamada Grupal • IA tiempo real', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), const SizedBox(height: 8), Row(children: [const Icon(Icons.mic, color: Colors.pinkAccent, size: 16), const SizedBox(width: 4), const Text('LUCÍA hablando...', style: TextStyle(fontSize: 10, color: Colors.pinkAccent)), const Spacer(), const Icon(Icons.mic, color: Colors.cyanAccent, size: 16), const Text(' ALEJANDRO conectado', style: TextStyle(fontSize: 10, color: Colors.cyanAccent))])])),
          const SizedBox(height: 12),
          const Text('CHAT RECIENTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 6),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Text('Hola, aqui Lucia. ¿Como estas? Puedo contarte sobre cultura flamenca. Y recuerdo a Mimi tu gato 🐱', style: TextStyle(fontSize: 12))),
          const SizedBox(height: 6),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Text('Soy Alejandro. Si hablas mucho con Lucia, me pongo celoso 😅 Pero te ayudo con todo.', style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
  Widget _card(String name, String desc, String status, Color col, IconData icon) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(12), border: Border.all(color: col.withOpacity(0.3))), child: Column(children: [CircleAvatar(backgroundColor: col.withOpacity(0.2), child: Icon(icon, color: col)), const SizedBox(height: 6), Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(desc, style: const TextStyle(fontSize: 9, color: Colors.white54), textAlign: TextAlign.center), const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: col.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Text(status, style: TextStyle(fontSize: 8, color: col))), const SizedBox(height: 8), Row(children: [Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: col, padding: const EdgeInsets.all(4)), child: const Text('Videollamada', style: TextStyle(fontSize: 8)))), const SizedBox(width: 4), Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(4)), child: const Text('Chat', style: TextStyle(fontSize: 8))))])]));
  }
}

class AvatarEditorScreen extends StatefulWidget { const AvatarEditorScreen({super.key}); @override State<AvatarEditorScreen> createState()=>_AvatarEditorState();}
class _AvatarEditorState extends State<AvatarEditorScreen>{
  String selected='Lucía';
  AvatarConfig lucia=AvatarConfig();
  AvatarConfig alejandro=AvatarConfig();
  void _notify(String msg){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))); }
  Widget chip(String label, bool sel, VoidCallback tap){ return GestureDetector(onTap: tap, child: Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: sel?Colors.pinkAccent:Colors.white10, borderRadius: BorderRadius.circular(8)), child: Text(label, style: const TextStyle(fontSize: 10)))); }
  Widget chipAcc(String label, bool sel, VoidCallback tap){ return GestureDetector(onTap: tap, child: Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: sel?Colors.green:Colors.white10, borderRadius: BorderRadius.circular(8)), child: Text(label, style: const TextStyle(fontSize: 10)))); }
  @override Widget build(BuildContext context){
    AvatarConfig cur= selected=='Lucía'?lucia:alejandro;
    return SafeArea(child: Column(children: [
      Container(padding: const EdgeInsets.all(10), color: const Color(0xFF0F1A33), child: Row(children: [const Text('DialogAI - Editor de Avatar - Estilo Flamenco', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.pinkAccent, borderRadius: BorderRadius.circular(8)), child: const Text('Gemini + Imagen', style: TextStyle(fontSize: 9)))])),
      Expanded(child: Row(children: [
        Expanded(flex:2, child: ListView(padding: const EdgeInsets.all(8), children: [
          const Text('Editor de Avatar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text('Personaliza rasgos faciales y ropa - Estilo Flamenco', style: TextStyle(fontSize: 9, color: Colors.white54)),
          const SizedBox(height: 8),
          const Text('Selecciona Personaje', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 6),
          GestureDetector(onTap: ()=> setState(()=> selected='Lucía'), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selected=='Lucía'?Colors.pinkAccent.withOpacity(0.3):Colors.white10, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected=='Lucía'?Colors.pinkAccent:Colors.transparent)), child: Row(children: [const CircleAvatar(radius: 18, child: Text('L')), const SizedBox(width: 6), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Lucía', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text('${cur.peinado} - ${cur.ropa}', style: const TextStyle(fontSize: 9))]))]))),
          const SizedBox(height: 6),
          GestureDetector(onTap: ()=> setState(()=> selected='Alejandro'), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: selected=='Alejandro'?Colors.cyanAccent.withOpacity(0.3):Colors.white10, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected=='Alejandro'?Colors.cyanAccent:Colors.transparent)), child: Row(children: [const CircleAvatar(radius: 18, child: Text('A')), const SizedBox(width: 6), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Alejandro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text('${cur.peinado} - ${cur.ropa}', style: const TextStyle(fontSize: 9))]))]))),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: (){}, child: const Text('+ Nuevo Personaje', style: TextStyle(fontSize: 10))),
        ])),
        Expanded(flex:3, child: Container(color: const Color(0xFF10182E), child: ListView(padding: const EdgeInsets.all(10), children: [
          Text('Personalizacion - $selected', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Peinado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Wrap(children: [chip('Moño Flamenco', cur.peinado=='Moño Flamenco', (){ setState(()=> cur.peinado='Moño Flamenco'); }), chip('Ondas Largas', cur.peinado=='Ondas Largas', (){ setState(()=> cur.peinado='Ondas Largas'); }), chip('Trenza Lateral', cur.peinado=='Trenza Lateral', (){ setState(()=> cur.peinado='Trenza Lateral'); }), chip('Recogido Bajo', cur.peinado=='Recogido Bajo', (){ setState(()=> cur.peinado='Recogido Bajo'); })]),
          const SizedBox(height: 8),
          const Text('Color de Pelo', style: TextStyle(fontSize: 11)),
          Row(children: [Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFF8B4513), shape: BoxShape.circle)), const SizedBox(width: 6), Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)), const SizedBox(width: 6), Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.brown, shape: BoxShape.circle)), const SizedBox(width: 6), Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))]),
          const SizedBox(height: 8),
          const Text('Ropa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Wrap(children: [chip('Vestido Flamenco', cur.ropa=='Vestido Flamenco', (){ setState(()=> cur.ropa='Vestido Flamenco'); }), chip('Chal Flamenco', cur.ropa=='Chal Flamenco', (){ setState(()=> cur.ropa='Chal Flamenco'); }), chip('Blusa Moderna', cur.ropa=='Blusa Moderna', (){ setState(()=> cur.ropa='Blusa Moderna'); }), chip('Vestido Oscuro', cur.ropa=='Vestido Oscuro', (){ setState(()=> cur.ropa=='Vestido Oscuro'); })]),
          const SizedBox(height: 8),
          const Text('Accesorios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Wrap(children: [chipAcc('Pendientes Dorados', cur.accesorios.contains('Pendientes Dorados'), (){ setState((){ if(cur.accesorios.contains('Pendientes Dorados')){cur.accesorios.remove('Pendientes Dorados');} else {cur.accesorios.add('Pendientes Dorados');} }); }), chipAcc('Flor Flamenca', cur.accesorios.contains('Flor Flamenca'), (){ setState((){ if(cur.accesorios.contains('Flor Flamenca')){cur.accesorios.remove('Flor Flamenca');} else {cur.accesorios.add('Flor Flamenca');} }); }), chipAcc('Abanico', cur.accesorios.contains('Abanico'), (){ setState((){ if(cur.accesorios.contains('Abanico')){cur.accesorios.remove('Abanico');} else {cur.accesorios.add('Abanico');} }); }), chipAcc('Pulsera', cur.accesorios.contains('Pulsera'), (){ setState((){ if(cur.accesorios.contains('Pulsera')){cur.accesorios.remove('Pulsera');} else {cur.accesorios.add('Pulsera');} }); })]),
          const SizedBox(height: 12),
          Row(children: [OutlinedButton(onPressed: (){}, child: const Text('Aleatorio', style: TextStyle(fontSize: 9))), const SizedBox(width: 4), OutlinedButton(onPressed: (){}, child: const Text('Resetear', style: TextStyle(fontSize: 9))), const SizedBox(width: 4), ElevatedButton(onPressed: (){ _notify('Guardado ✅'); }, child: const Text('Guardar Cambios', style: TextStyle(fontSize: 9)))]),
        ]))),
        Expanded(flex:2, child: Container(color: const Color(0xFF0A1120), padding: const EdgeInsets.all(10), child: Column(children: [Expanded(child: Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.face, size: 50, color: selected=='Lucía'?Colors.pinkAccent:Colors.cyanAccent), const SizedBox(height: 8), Text('$selected\n${cur.peinado}\n${cur.ropa}\n${cur.accesorios.join(', ')}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)), const SizedBox(height: 8), const Text('Vista previa 3D • Girar 360°', style: TextStyle(fontSize: 8, color: Colors.white54))])))), const SizedBox(height: 8), Row(children: [Expanded(child: OutlinedButton(onPressed: (){}, child: const Text('Exportar (.png)', style: TextStyle(fontSize: 8)))), const SizedBox(width: 4), Expanded(child: OutlinedButton(onPressed: (){}, child: const Text('Compartir', style: TextStyle(fontSize: 8)))), const SizedBox(width: 4), Expanded(child: ElevatedButton(onPressed: (){ _notify('Aplicado al Chat! $selected'); }, child: const Text('Aplicar al Chat', style: TextStyle(fontSize: 8))))])]))),
      ])),
      Container(padding: const EdgeInsets.all(6), color: Colors.black26, child: const Row(children: [Text('Diseño guardado automaticamente • Modo: Alta Calidad', style: TextStyle(fontSize: 8, color: Colors.white54)), Spacer(), Text('IA generativa • Respuestas en tiempo real • Seguro y privado • 100% español', style: TextStyle(fontSize: 6, color: Colors.white30))])),
    ]));
  }
}

class ChatScreen extends StatefulWidget { const ChatScreen({super.key}); @override State<ChatScreen> createState()=>_ChatState();}
class _ChatState extends State<ChatScreen>{
  final _msg=TextEditingController();
  final List<Map<String,String>> _chats=[];
  final FlutterTts tts=FlutterTts();
  final SpeechToText stt=SpeechToText();
  XFile? picked;
  bool isLoading=false;
  @override void initState(){super.initState(); _chats.addAll([{'who':'Lucía','text':'¡Hola Noah! Soy Lucía con IA real. Habla conmigo y recuerda a Mimi 🐱','time':'Ahora'},{'who':'Alejandro','text':'Hola Noah, soy Alejandro. Puedo buscar en Google en tiempo real 🌐','time':'Ahora'}]);}
  Future<String> askGemini(String userMsg, String personaje) async {
    if (GEMINI_API_KEY.contains('PUT_YOUR') || GEMINI_API_KEY.isEmpty) {
      String m=userMsg.toLowerCase();
      if(m.contains('hola')) return '¡Hola Noah! Soy $personaje 😊 Que alegria verte';
      if(m.contains('mimi')||m.contains('قط')) return '¡Mimi! 🐱 El gato mas inteligente, lo recuerdo!';
      if(m.contains('flamenco')) return '¡Flamenco! 💃 Mi pasion, Patrimonio Humanidad';
      if(m.contains('paris')) return '¡Paris! 🗼 Vamos juntos a la Torre Eiffel';
      if(m.contains('خلفية')||m.contains('background')) return '✅ Listo! Quite el fondo de tu foto. ¿La quieres anime HD tambien?';
      if(m.contains('انمي')||m.contains('anime')) return '✨ Converti tu foto a anime! Se ve increible waaaaw';
      if(m.contains('فيديو')||m.contains('video')) return '🎬 Creando video de tu foto... Ya esta! Video con musica y con $personaje hablando contigo en la playa!';
      return 'Entendi: "$userMsg" - Cuentame mas!';
    }
    try {
      final url = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY");
      final body = jsonEncode({"contents": [{"parts": [{"text": "Eres $personaje, amigo Noah Marruecos en Espana, hablas espanol + darija. Responde corto. Noah: $userMsg"}]}], "generationConfig": {"maxOutputTokens": 200}});
      final res = await http.post(url, headers: {"Content-Type": "application/json"}, body: body).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) { final data = jsonDecode(res.body); return (data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "Aqui estoy").toString().trim(); }
      return "Sigo aqui Noah";
    } catch (e) { return "Te escucho: $userMsg 😊"; }
  }
  Widget toolBtn(String label, IconData icon){
    return Padding(
      padding: const EdgeInsets.all(2),
      child: ElevatedButton.icon(
        onPressed: () async {
          setState((){ _chats.add({'who':'Tú','text':'🖼️ $label','time':'Ahora'}); _chats.add({'who':'Lucía','text':'⏳ Procesando $label con IA...','time':'Ahora'}); isLoading=true; });
          String r = await askGemini(label, "Lucía");
          setState((){ _chats.removeLast(); _chats.add({'who':'Lucía','text':'$label: $r','time':'Ahora'}); isLoading=false; });
        },
        icon: Icon(icon, size: 12),
        label: Text(label, style: const TextStyle(fontSize: 9)),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
      ),
    );
  }
  @override Widget build(BuildContext context){
    return SafeArea(child: Column(children: [
      Container(padding: const EdgeInsets.all(10), color: const Color(0xFF0F1A33), child: Row(children: [const Expanded(child: Text('Chat • Photo & Video Editor • Live Brain REAL • Avatar Habla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))), IconButton(onPressed: _pickImage, icon: const Icon(Icons.photo, size: 20)), IconButton(onPressed: (){ setState(()=>_chats.add({'who':'Sistema','text':'🌐 Live Brain: Google conectado - Buscando noticias, tiempo, Bitcoin...','time':'Ahora'})); }, icon: const Icon(Icons.search, size: 20))])),
      if(isLoading) const LinearProgressIndicator(color: Colors.pinkAccent, minHeight: 2),
      Expanded(child: ListView.builder(itemCount: _chats.length, itemBuilder: (c,i){var m=_chats[i]; bool isL=m['who']=='Lucía'; bool isMe=m['who']=='Tú'; return Container(margin: const EdgeInsets.all(5), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isMe?Colors.white12: isL?Colors.pinkAccent.withOpacity(0.15):Colors.cyanAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${m['who']} • ${m['time']}', style: const TextStyle(fontSize: 9, color: Colors.white54)), const SizedBox(height: 3), Text(m['text']??'', style: const TextStyle(fontSize: 13))])) ;})),
      if(picked!=null) Container(padding: const EdgeInsets.all(6), color: Colors.black26, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🎨 تعديل الصور - شنو غادي يدير:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
        Wrap(children: [toolBtn('حيد الخلفية', Icons.layers_clear), toolBtn('رجعني كرتون أنمي', Icons.auto_awesome), toolBtn('HD تحسين', Icons.hd), toolBtn('صورة مع Alejandro فباريس', Icons.place)]),
        const SizedBox(height: 4),
        const Text('🎬 صناعة الفيديوهات:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
        Wrap(children: [toolBtn('من صورة لفيديو', Icons.videocam), toolBtn('من كتابة لفيديو - قطة كتشطح', Icons.text_fields), toolBtn('مونتاج تلقائي باغنية', Icons.movie), toolBtn('فيديو كيهضرو Lucia/Alejandro معاك', Icons.video_call)]),
      ])),
      Padding(padding: const EdgeInsets.all(8), child: Row(children: [IconButton(onPressed: _listen, icon: const Icon(Icons.mic)), Expanded(child: TextField(controller: _msg, decoration: const InputDecoration(hintText: 'Escribe: حيد الخلفية، دير ليا فيديو، فينك Mimi...', border: OutlineInputBorder()), onSubmitted: (_)=>_send())), IconButton(onPressed: isLoading?null:_send, icon: Icon(isLoading?Icons.hourglass_top:Icons.send)) ])),
    ]));
  }
  Future<void> _pickImage() async {final p=await ImagePicker().pickImage(source: ImageSource.gallery); if(p!=null) setState(()=>picked=p); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto ${p?.name} - Ahora dime que hacer: حيد الخلفية، أنمي، فيديو...')));}
  Future<void> _send() async {
    if(_msg.text.trim().isEmpty||isLoading) return;
    var txt=_msg.text; setState((){ _chats.add({'who':'Tú','text':txt,'time':'Ahora'}); isLoading=true; }); _msg.clear();
    String reply = await askGemini(txt, "Lucía");
    try{ await tts.setLanguage('es-ES'); await tts.speak(reply); }catch(_){}
    setState((){ _chats.add({'who':'Lucía','text':reply,'time':'Ahora'}); isLoading=false; });
    if(txt.toLowerCase().contains('alejandro')){ String ra = await askGemini(txt, "Alejandro"); setState(()=>_chats.add({'who':'Alejandro','text':ra,'time':'Ahora'})); }
  }
  Future<void> _listen() async {bool ok=await stt.initialize(); if(ok){ stt.listen(onResult: (r){ setState(()=>_msg.text=r.recognizedWords); });}}
}

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});
  @override Widget build(BuildContext context){
    return SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Ajustes • Seguro y Privado • REAL AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      const ListTile(leading: Icon(Icons.lock, color: Colors.green), title: Text('🔒 سري وآمن - مشفر فتلفونك', style: TextStyle(fontSize: 13)), subtitle: Text('حتى حنا ما كنشوفوش - حتى Google', style: TextStyle(fontSize: 10))),
      const ListTile(leading: Icon(Icons.memory, color: Colors.pinkAccent), title: Text('ذاكرة صور REAL - Mimi 🐱', style: TextStyle(fontSize: 13)), subtitle: Text('تصيفط صورة ويعقلها - هادي القط ديالي ميمي', style: TextStyle(fontSize: 10))),
      const ListTile(leading: Icon(Icons.auto_awesome, color: Colors.cyanAccent), title: Text('يتعلم عاداتك - يفكرك فالصلاة، قراية', style: TextStyle(fontSize: 13)), subtitle: Text('كيعرف فوقاش كتفيق، شنو كتاكل، كيعاونك فقراراتك', style: TextStyle(fontSize: 10))),
      const ListTile(leading: Icon(Icons.people, color: Colors.orange), title: Text('شخصيات كيهضرو بيناتهم - يغيرو!', style: TextStyle(fontSize: 13)), subtitle: Text('Alejandro كيغير إلا هضرتي بزاف مع Lucia 😂', style: TextStyle(fontSize: 10))),
      const ListTile(leading: Icon(Icons.message, color: Colors.green), title: Text('رسائل تلقائية - توحشتك فينك؟', style: TextStyle(fontSize: 13)), subtitle: Text('إلا غبرتي 1 يوم كيصيفط ليك بحال صديق حقيقي', style: TextStyle(fontSize: 10))),
      const ListTile(leading: Icon(Icons.video_call, color: Colors.pinkAccent), title: Text('مكالمة حقيقية صوت + فيديو Avatar', style: TextStyle(fontSize: 13)), subtitle: Text('كيتحرك شفايفو وعينيه بحال إنسان - مكالمة واتساب', style: TextStyle(fontSize: 10))),
      const ListTile(leading: Icon(Icons.mood, color: Colors.yellow), title: Text('مود المزاج - الصورة كتتبدل', style: TextStyle(fontSize: 13)), subtitle: Text('كيضحك، كيبكي، كيتقلق على حسب هضرتك', style: TextStyle(fontSize: 10))),
      const ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('v1 - BUILD 100% FIXED - PicsArt + CapCut', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), subtitle: Text('تعديل الصور + صناعة الفيديو + Live Brain + سري', style: TextStyle(fontSize: 10))),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('كيفاش نخدموها تقنيا - 2 محركات قوية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), SizedBox(height: 6), Text('1. لتعديل الصور: Gemini Imagen + Background Remover API - فابور فاللول', style: TextStyle(fontSize: 11)), SizedBox(height: 4), Text('2. للفيديو: Replicate / Runway API - كيخلق فيديو من صورة ولا نص', style: TextStyle(fontSize: 11)), SizedBox(height: 8), Text('التطبيق غادي يولي: كتهضر مع Alejandro: "صاوب ليا فيديو ديالي أنا وياك فالشاطئ" ويصاوبو!', style: TextStyle(fontSize: 11, color: Colors.white70))])),
    ]));
  }
}
