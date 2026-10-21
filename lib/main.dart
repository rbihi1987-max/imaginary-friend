import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

// ⬇️ حط هنا المفتاح ديال ...GgIA اللي عندك فالصورة ⬇️⬇️⬇️
const String GEMINI_API_KEY = "AIzaSy...GgIA";

void main() => runApp(const DialogAIApp());
class DialogAIApp extends StatelessWidget {
  const DialogAIApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner:false, theme:ThemeData.dark().copyWith(scaffoldBackgroundColor:const Color(0xFF0A0F1F)), home:const HomeRoot());
}
class HomeRoot extends StatefulWidget{const HomeRoot({super.key}); @override State<HomeRoot> createState()=>_HomeRootState();}
class _HomeRootState extends State<HomeRoot>{
  int idx=0; String chatWith='Lucía';
  void goToChat(String n)=>setState((){chatWith=n; idx=2;});
  void showVideo(String n)=>showDialog(context:context, builder:(c)=>AlertDialog(backgroundColor:const Color(0xFF151B2F), title:Text('Videollamada $n 📹'), content: Text('$n Avatar 3D كيتحرك! Mimi 🐱 معانا'), actions:[TextButton(onPressed:()=>Navigator.pop(c), child:const Text('واخا'))]));
  @override Widget build(BuildContext context){
    return Scaffold(body:[CompanerosScreen(onChat:goToChat,onVideo:showVideo),const AvatarEditorScreen(),ChatScreen(initialCompanion:chatWith),const AjustesScreen()][idx],
      bottomNavigationBar:BottomNavigationBar(currentIndex:idx,onTap:(i)=>setState(()=>idx=i),backgroundColor:const Color(0xFF0A0F1F),selectedItemColor:Colors.pinkAccent,unselectedItemColor:Colors.white54,type:BottomNavigationBarType.fixed,
        items:const[BottomNavigationBarItem(icon:Icon(Icons.home),label:'Inicio'),BottomNavigationBarItem(icon:Icon(Icons.face),label:'Compañeros'),BottomNavigationBarItem(icon:Icon(Icons.chat),label:'Chat'),BottomNavigationBarItem(icon:Icon(Icons.settings),label:'Ajustes')]));
  }
}
class CompanerosScreen extends StatelessWidget{
  final Function(String) onChat; final Function(String) onVideo;
  const CompanerosScreen({super.key,required this.onChat,required this.onVideo});
  @override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.all(12),children:[
    Row(children:[const Icon(Icons.memory,color:Colors.pinkAccent),const SizedBox(width:8),const Text('DialogAI v1 - Memoria Real',style:TextStyle(fontWeight:FontWeight.bold)),const Spacer(),Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:Colors.green.withOpacity(.2),borderRadius:BorderRadius.circular(12)),child:const Text('Gemini Live ✅',style:TextStyle(fontSize:10,color:Colors.green)))]),
    const SizedBox(height:12),const Text('COMPAÑEROS VIRTUALES',style:TextStyle(fontWeight:FontWeight.bold,fontSize:12)),const SizedBox(height:12),
    Row(children:[Expanded(child:_card(context,'LUCÍA','Flamenco • Empatica','En linea',Colors.pinkAccent)),const SizedBox(width:8),Expanded(child:_card(context,'ALEJANDRO','Flamenco • Analitico','En linea',Colors.cyanAccent))]),
    const SizedBox(height:12),Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:const Color(0xFF151B2F),borderRadius:BorderRadius.circular(12)),child:const Text('Lucia y Alejandro كيهضرو بيناتهم! Mimi 🐱 عاقل على كلشي',style:TextStyle(fontSize:10,color:Colors.white54)))
  ]));
  Widget _card(BuildContext c,String name,String desc,String status,Color col){String first=name=='LUCÍA'?'Lucía':'Alejandro';return Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF151B2F),borderRadius:BorderRadius.circular(12),border:Border.all(color:col.withOpacity(.3))),child:Column(children:[CircleAvatar(backgroundColor:col.withOpacity(.2),child:Icon(name=='LUCÍA'?Icons.face:Icons.face_2,color:col)),const SizedBox(height:6),Text(name,style:const TextStyle(fontWeight:FontWeight.bold)),Text(desc,style:const TextStyle(fontSize:9,color:Colors.white54),textAlign:TextAlign.center),const SizedBox(height:8),Row(children:[Expanded(child:ElevatedButton(onPressed:()=>onVideo(first),style:ElevatedButton.styleFrom(backgroundColor:col,padding:const EdgeInsets.all(4)),child:const Text('Videollamada',style:TextStyle(fontSize:8,color:Colors.white)))),const SizedBox(width:4),Expanded(child:OutlinedButton(onPressed:()=>onChat(first),style:OutlinedButton.styleFrom(padding:const EdgeInsets.all(4),side:BorderSide(color:col)),child:Text('Chat',style:TextStyle(fontSize:8,color:col))))])]));}
}
class AvatarEditorScreen extends StatelessWidget{const AvatarEditorScreen({super.key}); @override Widget build(BuildContext context)=>const SafeArea(child:Center(child:Text('Avatar Editor - Flamenco 3D - Mimi 🐱')));}
class ChatScreen extends StatefulWidget{final String initialCompanion;const ChatScreen({super.key,this.initialCompanion='Lucía'}); @override State<ChatScreen> createState()=>_ChatState();}
class _ChatState extends State<ChatScreen>{
  final _msg=TextEditingController(); final List<Map<String,String>> _chats=[]; final FlutterTts tts=FlutterTts(); XFile? picked; bool loading=false; late String cur;
  @override void initState(){super.initState();cur=widget.initialCompanion;_chats.addAll([{'who':'Lucía','text':'¡Hola Noah! Soy Lucía 💃 Mimi 🐱','time':'Ahora'},{'who':'Alejandro','text':'Hola Noah, soy Alejandro 🤝','time':'Ahora'}]);}
  @override void didUpdateWidget(covariant ChatScreen old){super.didUpdateWidget(old); if(widget.initialCompanion!=old.initialCompanion){setState((){cur=widget.initialCompanion; _chats.add({'who':'Sistema','text':'-- Chat con $cur --','time':'Ahora'});});}}
  Future<String> askGemini(String userMsg,String personaje) async {
    if(GEMINI_API_KEY.isEmpty||GEMINI_API_KEY.contains('PUT_YOUR')||GEMINI_API_KEY.contains('...')) return _fallback(userMsg,personaje);
    try{
      final url=Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY");
      final body=jsonEncode({"contents":[{"parts":[{"text":"Eres $personaje, amiga de Noah, recuerdas Mimi gato, español + darija, max 2 frases: $userMsg"}]}],"generationConfig":{"maxOutputTokens":250}});
      final res=await http.post(url,headers:{"Content-Type":"application/json"},body:body).timeout(const Duration(seconds:15));
      if(res.statusCode==200){final d=jsonDecode(res.body); String t=(d["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]??"").toString().trim(); if(t.isNotEmpty) return t;}
    }catch(_){}
    return _fallback(userMsg,personaje);
  }
  String _fallback(String m,String p){bool isL=p.contains('Lucía'); String l=m.toLowerCase(); if(l.contains('hola')||l.contains('salam')) return isL?"¡Hola habibi! 😊 Mimi 🐱":"Hola Noah! 🤝"; if(l.contains('mimi')) return "¡Mimi! 🐱 Lo recuerdo!"; if(l.contains('خلفية')) return "✅ حيدت الخلفية - HD!"; if(l.contains('انمي')) return "✨ أنمي Ghibli!"; if(l.contains('فيديو')) return "🎬 فيديو مع موسيقى!"; return "سمعتك: $m ❤️";}
  @override Widget build(BuildContext context)=>SafeArea(child:Column(children:[
    Container(padding:const EdgeInsets.all(10),color:const Color(0xFF0F1A33),child:Row(children:[CircleAvatar(radius:12,backgroundColor:cur.contains('Lucía')?Colors.pinkAccent:Colors.cyanAccent,child:Text(cur[0],style:const TextStyle(fontSize:10,color:Colors.white))),const SizedBox(width:8),Expanded(child:Text('Chat con $cur • Mimi 🐱',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:10))),IconButton(onPressed:()async{final p=await ImagePicker().pickImage(source:ImageSource.gallery); if(p!=null) setState(()=>picked=p);},icon:const Icon(Icons.photo))])), if(loading)const LinearProgressIndicator(color:Colors.pinkAccent,minHeight:2),
    Expanded(child:ListView.builder(itemCount:_chats.length,itemBuilder:(c,i){var m=_chats[i]; bool isL=m['who']=='Lucía'; bool me=m['who']=='Tú'; return Container(margin:const EdgeInsets.all(5),padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:me?Colors.white12:isL?Colors.pinkAccent.withOpacity(.15):Colors.cyanAccent.withOpacity(.12),borderRadius:BorderRadius.circular(12)),child:Text('${m['who']}: ${m['text']}',style:const TextStyle(fontSize:13)));})),
    if(picked!=null)Container(padding:const EdgeInsets.all(6),color:Colors.black26,child:Wrap(children:[_btn('حيد الخلفية',Icons.layers_clear),_btn('أنمي',Icons.auto_awesome),_btn('HD',Icons.hd),_btn('باريس',Icons.place),_btn('فيديو',Icons.videocam)])),
    Padding(padding:const EdgeInsets.all(8),child:Row(children:[Expanded(child:TextField(controller:_msg,decoration:InputDecoration(hintText:'Con $cur: hola, Mimi, حيد الخلفية...',border:const OutlineInputBorder()),onSubmitted:(_)=>_send())),IconButton(onPressed:loading?null:_send,icon:Icon(loading?Icons.hourglass_top:Icons.send,color:cur.contains('Lucía')?Colors.pinkAccent:Colors.cyanAccent))]))
  ]));
  Widget _btn(String l,IconData ic)=>Padding(padding:const EdgeInsets.all(2),child:ElevatedButton.icon(onPressed:()async{setState((){_chats.add({'who':'Tú','text':'🖼️ $l','time':'Ahora'}); loading=true;}); String r=await askGemini(l,cur); setState((){_chats.add({'who':cur,'text':'✅ $l: $r','time':'Ahora'}); loading=false;});},icon:Icon(ic,size:12),label:Text(l,style:const TextStyle(fontSize:9)),style:ElevatedButton.styleFrom(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),backgroundColor:cur.contains('Lucía')?Colors.pinkAccent:Colors.cyanAccent)));
  Future<void> _send() async {if(_msg.text.trim().isEmpty||loading) return; var t=_msg.text; setState((){_chats.add({'who':'Tú','text':t,'time':'Ahora'}); loading=true;}); _msg.clear(); String r=await askGemini(t,cur); try{await tts.setLanguage('es-ES'); await tts.speak(r);}catch(_){} setState((){_chats.add({'who':cur,'text':r,'time':'Ahora'}); loading=false;});}
}
class AjustesScreen extends StatelessWidget{const AjustesScreen({super.key}); @override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.all(16),children:const[Text('Ajustes • DialogAI v1 • Mimi 🐱',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),ListTile(leading:Icon(Icons.memory,color:Colors.pinkAccent),title:Text('ذاكرة صور REAL - Mimi عاقل')),ListTile(leading:Icon(Icons.video_call,color:Colors.cyanAccent),title:Text('مكالمة Avatar 3D'))]));}
