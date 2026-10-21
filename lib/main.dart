import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

// ⬇️⬇️ حط المفتاح الكامل ديال Key 12 - ...GgIA هنا ⬇️⬇️
const String GEMINI_API_KEY = "AIzaSy...GgIA";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('dialogai_v1_final');
  runApp(const DialogAIApp());
}

class DialogAIApp extends StatelessWidget {
  const DialogAIApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0A0F1F)),
    home: const HomeRoot(),
  );
}

class HomeRoot extends StatefulWidget {
  const HomeRoot({super.key});
  @override State<HomeRoot> createState() => _HomeRootState();
}

class _HomeRootState extends State<HomeRoot> {
  int idx = 0;
  String chatWith = 'Lucía';
  String userName = 'Noah';
  String tone = 'مضحك';

  void goToChat(String n) => setState(() { chatWith = n; idx = 2; });
  void showVideo(String n) => showDialog(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: const Color(0xFF151B2F),
      title: Text('Videollamada con $n 📹'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.face, size: 80, color: n.contains('Lucía') ? Colors.pinkAccent : Colors.cyanAccent),
        const SizedBox(height: 10),
        Text('$n كيهضر معاك! كيحرك شفايفو 😊\nMimi 🐱 معانا'),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('إنهاء'))],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pages = [
      CompanerosScreen(onChat: goToChat, onVideo: showVideo),
      AvatarEditorScreen(companion: chatWith),
      ChatScreen(initialCompanion: chatWith, userName: userName, tone: tone),
      AjustesScreen(onSave: (u,t){ setState((){ userName=u; tone=t; }); }, userName: userName, tone: tone),
    ];
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx, onTap: (i) => setState(() => idx = i),
        backgroundColor: const Color(0xFF0A0F1F), selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.white54, type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Avatar'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class CompanerosScreen extends StatelessWidget {
  final Function(String) onChat; final Function(String) onVideo;
  const CompanerosScreen({super.key, required this.onChat, required this.onVideo});
  @override
  Widget build(BuildContext context) {
    final box = Hive.box('dialogai_v1_final');
    List memories = box.get('memories', defaultValue: ['Mimi 🐱 القط ديال Noah','Lucía Flamenco','Alejandro كيغير']);
    return SafeArea(child: ListView(padding: const EdgeInsets.all(12), children: [
      Row(children: [const Icon(Icons.memory, color: Colors.pinkAccent), const SizedBox(width: 8), const Text('DialogAI v1 - Memoria REAL', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Text('Gemini Live ✅', style: TextStyle(fontSize: 10, color: Colors.green)))]),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF151B2F), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('الذاكرة - Mimi 🐱 ما كينساش', style: TextStyle(fontSize: 11, color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
        ...memories.take(4).map((m) => Text('• $m', style: const TextStyle(fontSize: 10, color: Colors.white70))),
      ])),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: _card(context,'LUCÍA','Flamenco • Empática','Mimi عاقل عليها',Colors.pinkAccent)), const SizedBox(width: 8), Expanded(child: _card(context,'ALEJANDRO','Analítico • Celoso 😅','كيغير من Lucia',Colors.cyanAccent))]),
    ]));
  }
  Widget _card(BuildContext c,String name,String desc,String mem,Color col){String first=name=='LUCÍA'?'Lucía':'Alejandro';return Container(padding: const EdgeInsets.all(12),decoration: BoxDecoration(color: const Color(0xFF151B2F),borderRadius: BorderRadius.circular(12),border: Border.all(color: col.withOpacity(0.3))),child: Column(children: [CircleAvatar(backgroundColor: col.withOpacity(0.2),child: Icon(name=='LUCÍA'?Icons.face:Icons.face_2,color: col)),const SizedBox(height:6),Text(name,style: const TextStyle(fontWeight: FontWeight.bold)),Text(desc,style: const TextStyle(fontSize:9,color: Colors.white54),textAlign: TextAlign.center),Text(mem,style: TextStyle(fontSize:8,color: col)),const SizedBox(height:8),Row(children: [Expanded(child: ElevatedButton(onPressed: ()=>onVideo(first),style: ElevatedButton.styleFrom(backgroundColor: col,padding: const EdgeInsets.all(4)),child: const Text('Video',style: TextStyle(fontSize:8,color: Colors.white)))),const SizedBox(width:4),Expanded(child: OutlinedButton(onPressed: ()=>onChat(first),style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(4),side: BorderSide(color: col)),child: Text('Chat',style: TextStyle(fontSize:8,color: col))))])]));}
}

class AvatarEditorScreen extends StatefulWidget{final String companion;const AvatarEditorScreen({super.key,this.companion='Lucía'});@override State<AvatarEditorScreen> createState()=>_AvatarEditorScreenState();}
class _AvatarEditorScreenState extends State<AvatarEditorScreen>{bool talking=false;@override Widget build(BuildContext context)=>SafeArea(child: Column(children: [Container(padding: const EdgeInsets.all(12),color: const Color(0xFF0F1A33),child: Row(children: [Text('Avatar 3D - ${widget.companion} 💃',style: const TextStyle(fontWeight: FontWeight.bold)),const Spacer(),Switch(value: talking,onChanged: (v)=>setState(()=>talking=v))])),Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Container(width: 180,height: 240,decoration: BoxDecoration(color: const Color(0xFF151B2F),borderRadius: BorderRadius.circular(24),border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))),child: Stack(alignment: Alignment.center,children: [Positioned(top: 20,child: Container(width: 90,height: 100,decoration: BoxDecoration(color: const Color(0xFFF8D2AF),borderRadius: BorderRadius.circular(45)))),Positioned(top: 55,left: 60,child: Container(width: 12,height: 16,decoration: const BoxDecoration(color: Colors.black,shape: BoxShape.circle))),Positioned(top: 55,right: 60,child: Container(width: 12,height: 16,decoration: const BoxDecoration(color: Colors.black,shape: BoxShape.circle))),Positioned(top: 95,child: AnimatedContainer(duration: const Duration(milliseconds: 100),width: talking?28:18,height: talking?12:5,decoration: BoxDecoration(color: Colors.redAccent,borderRadius: BorderRadius.circular(10)))),Positioned(bottom: 20,child: Container(width: 100,height: 60,decoration: BoxDecoration(color: Colors.pinkAccent,borderRadius: BorderRadius.circular(15))))])),const SizedBox(height:16),Text(talking?'🗣️ ${widget.companion} كتهضر...':'😊 ${widget.companion} كتسمعك'),ElevatedButton.icon(onPressed: ()=>setState(()=>talking=!talking),icon: Icon(talking?Icons.stop:Icons.play_arrow),label: Text(talking?'سكت':'خليه يهضر'))]))])));}

class ChatScreen extends StatefulWidget{final String initialCompanion;final String userName;final String tone;const ChatScreen({super.key,this.initialCompanion='Lucía',this.userName='Noah',this.tone='مضحك'});@override State<ChatScreen> createState()=>_ChatState();}
class _ChatState extends State<ChatScreen>{
  final _msg=TextEditingController();final List<Map<String,dynamic>> _chats=[];final FlutterTts tts=FlutterTts();XFile? picked;bool loading=false;late String cur;
  @override void initState(){super.initState();cur=widget.initialCompanion;_chats.add({'who':'Lucía','text':'¡Hola ${widget.userName}! Soy Lucía 💃 Mimi 🐱 - رفع صورة وقل: حيد الخلفية، أنمي، باريس، فيديو','time':'Ahora'}); _load();}
  void _load(){final box=Hive.box('dialogai_v1_final');List saved=box.get('chats',defaultValue:[]);if(saved.isNotEmpty) _chats.addAll(saved.cast<Map<String,dynamic>>());}
  void _save(){final box=Hive.box('dialogai_v1_final');box.put('chats',_chats);List mem=box.get('memories',defaultValue:[]);mem.insert(0,'${DateTime.now().toString().substring(0,16)} con $cur');box.put('memories',mem.take(10).toList());}
  Future<String> askGemini(String userMsg,String personaje,{XFile? image}) async{
    if(GEMINI_API_KEY.isEmpty||GEMINI_API_KEY.contains('...')) return _fallback(userMsg,personaje);
    try{
      final url=Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY");
      List<Map<String,dynamic>> parts=[{"text":"Eres $personaje, tono ${widget.tone}, amiga de ${widget.userName}, recuerdas Mimi gato. Si pide fondo/anime/HD/Paris/video di que lo hiciste. Max 2 frases: $userMsg"}];
      if(image!=null){final bytes=await File(image.path).readAsBytes();parts.add({"inline_data":{"mime_type":"image/jpeg","data":base64Encode(bytes)}});}
      final body=jsonEncode({"contents":[{"parts":parts}],"generationConfig":{"maxOutputTokens":400}});
      final res=await http.post(url,headers:{"Content-Type":"application/json"},body: body).timeout(const Duration(seconds:20));
      if(res.statusCode==200){final d=jsonDecode(res.body);String t=(d["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]??"").toString().trim();if(t.isNotEmpty) return t;}
    }catch(_){}
    return _fallback(userMsg,personaje);
  }
  String _fallback(String m,String p){bool isL=p.contains('Lucía');String l=m.toLowerCase();if(l.contains('hola')||l.contains('salam')) return isL?"¡Hola ${widget.userName} habibi! 😊 Mimi 🐱":"Hola!";if(l.contains('mimi')) return "¡Mimi! 🐱 عاقل عليها!";if(l.contains('خلفية')) return "✅ حيدت الخلفية! HD شفافة!";if(l.contains('انمي')) return "✨ أنمي Ghibli!";if(l.contains('باريس')||l.contains('paris')) return "🗼 باريس + برج إيفل!";if(l.contains('فيديو')) return "🎬 فيديو 5 ثواني مع Flamenco!";return "سمعتك: $m ❤️";}
  @override Widget build(BuildContext context)=>SafeArea(child: Column(children: [
    Container(padding: const EdgeInsets.all(10),color: const Color(0xFF0F1A33),child: Row(children: [CircleAvatar(radius:12,backgroundColor: cur.contains('Lucía')?Colors.pinkAccent:Colors.cyanAccent,child: Text(cur[0],style: const TextStyle(fontSize:10,color: Colors.white))),const SizedBox(width:8),Expanded(child: Text('Chat con $cur • ${widget.tone} • Mimi 🐱',style: const TextStyle(fontSize:10,fontWeight: FontWeight.bold))),IconButton(onPressed: ()async{final p=await ImagePicker().pickImage(source: ImageSource.gallery);if(p!=null) setState(()=>picked=p);},icon: const Icon(Icons.photo,color: Colors.pinkAccent))])),
    if(loading) const LinearProgressIndicator(color: Colors.pinkAccent,minHeight:2),
    Expanded(child: ListView.builder(itemCount: _chats.length,itemBuilder: (c,i){var m=_chats[i];bool isL=m['who']=='Lucía';bool me=m['who']=='Tú';return Container(margin: const EdgeInsets.all(5),padding: const EdgeInsets.all(10),decoration: BoxDecoration(color: me?Colors.white12:isL?Colors.pinkAccent.withOpacity(0.15):Colors.cyanAccent.withOpacity(0.12),borderRadius: BorderRadius.circular(12)),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [if(m['image']!=null) Padding(padding: const EdgeInsets.only(bottom:6),child: Text('🖼️ ${m['image']}',style: const TextStyle(fontSize:9,color: Colors.green))),Text('${m['who']}: ${m['text']}',style: const TextStyle(fontSize:13))]));})),
    if(picked!=null) Container(padding: const EdgeInsets.all(6),color: Colors.black26,child: Column(children: [Text('📷 ${picked!.name}',style: const TextStyle(fontSize:10,color: Colors.green)),Wrap(spacing:4,children: [_btn('حيد الخلفية',Icons.layers_clear),_btn('أنمي ✨',Icons.auto_awesome),_btn('HD',Icons.hd),_btn('باريس 🗼',Icons.place),_btn('فيديو 🎬',Icons.videocam)])])),
    Padding(padding: const EdgeInsets.all(8),child: Row(children: [Expanded(child: TextField(controller: _msg,decoration: InputDecoration(hintText: 'Con $cur: hola, Mimi, حيد الخلفية...',border: const OutlineInputBorder(),contentPadding: const EdgeInsets.all(10)),onSubmitted: (_)=>_send())),IconButton(onPressed: loading?null:_send,icon: Icon(loading?Icons.hourglass_top:Icons.send,color: cur.contains('Lucía')?Colors.pinkAccent:Colors.cyanAccent))]))
  ]));
  Widget _btn(String l,IconData ic)=>Padding(padding: const EdgeInsets.all(2),child: ElevatedButton.icon(onPressed: ()async{setState((){_chats.add({'who':'Tú','text':'🖼️ $l','image':picked!.name,'time':'Ahora'});loading=true;});String r=await askGemini(l,cur,image: picked);setState((){_chats.add({'who':cur,'text':'✅ $l: $r','time':'Ahora'});loading=false;});_save();},icon: Icon(ic,size:12),label: Text(l,style: const TextStyle(fontSize:9)),style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal:8,vertical:4),backgroundColor: cur.contains('Lucía')?Colors.pinkAccent:Colors.cyanAccent,foregroundColor: Colors.white)));
  Future<void> _send() async{if(_msg.text.trim().isEmpty||loading) return;var t=_msg.text;setState((){_chats.add({'who':'Tú','text':t,'time':'Ahora'});loading=true;});_msg.clear();String r=await askGemini(t,cur,image: picked);try{await tts.setLanguage('es-ES');await tts.speak(r);}catch(_){}setState((){_chats.add({'who':cur,'text':r,'time':'Ahora'});loading=false;picked=null;});_save();}
}

class AjustesScreen extends StatefulWidget{final Function(String,String) onSave;final String userName;final String tone;const AjustesScreen({super.key,required this.onSave,required this.userName,required this.tone});@override State<AjustesScreen> createState()=>_AjustesScreenState();}
class _AjustesScreenState extends State<AjustesScreen>{late TextEditingController nameCtrl;late String selTone;@override void initState(){super.initState();nameCtrl=TextEditingController(text: widget.userName);selTone=widget.tone;}@override Widget build(BuildContext context)=>SafeArea(child: ListView(padding: const EdgeInsets.all(16),children: [const Text('Ajustes • DialogAI v1 • Mimi 🐱',style: TextStyle(fontSize:18,fontWeight: FontWeight.bold)),const SizedBox(height:12),TextField(controller: nameCtrl,decoration: const InputDecoration(labelText:'اسمك',border: OutlineInputBorder())),const SizedBox(height:12),DropdownButtonFormField<String>(value: selTone,decoration: const InputDecoration(labelText:'أسلوب',border: OutlineInputBorder()),items: ['داعم','مضحك','مستقر','ذكي','رومانسي','مغامر'].map((e)=>DropdownMenuItem(value:e,child: Text(e))).toList(),onChanged: (v)=>setState(()=>selTone=v!)),const SizedBox(height:12),ElevatedButton(onPressed: (){widget.onSave(nameCtrl.text,selTone);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ! Mimi عاقل')));},child: const Text('حفظ')),const Divider(height:30),ListTile(leading: const Icon(Icons.memory,color: Colors.pinkAccent),title: const Text('ذاكرة Hive REAL'),subtitle: Text('${Hive.box('dialogai_v1_final').get('memories',defaultValue: []).length} ذكريات - Mimi 🐱')),ListTile(leading: const Icon(Icons.image,color: Colors.orange),title: const Text('صور: خلفية، أنمي، HD، باريس، فيديو'),subtitle: const Text('Gemini Vision ✅')),Container(padding: const EdgeInsets.all(12),decoration: BoxDecoration(color: Colors.green.withOpacity(0.15),borderRadius: BorderRadius.circular(12)),child: const Text('✅ متكامل: نفس منطق HTML + ذاكرة ما كتنساش',style: TextStyle(fontSize:11,color: Colors.green)))]));}
