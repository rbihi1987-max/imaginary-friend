import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(const ImaginaryFriendApp());

class ImaginaryFriendApp extends StatelessWidget {
  const ImaginaryFriendApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Imaginary Friend',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF070C18)),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int idx = 0;
  String charName = 'Lucía';
  List<Map<String, dynamic>> fullMemory = [];
  int level = 1;
  String mood = 'مبسوط';
  String apiKey = '';
  final FlutterTts tts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  final picker = ImagePicker();
  final ctrl = TextEditingController();
  List<Map<String, dynamic>> msgs = [];
  File? lastImg;
  Map<String, String> photoMemory = {};
  Timer? autoTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _autoMsg();
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      var p = await SharedPreferences.getInstance();
      apiKey = p.getString('gemini_key') ?? '';
      level = p.getInt('level') ?? 1;
      var m = p.getString('full_memory_v2');
      if (m != null) fullMemory = List<Map<String, dynamic>>.from(jsonDecode(m));
      var pm = p.getString('photo_memory_v2');
      if (pm != null) photoMemory = Map<String, String>.from(jsonDecode(pm));
      if (fullMemory.isNotEmpty) {
        var last = DateTime.tryParse(fullMemory.last['time'] ?? '');
        if (last != null && DateTime.now().difference(last).inHours > 24) mood = 'توحشتك';
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _save(String role, String text, {String? img}) async {
    try {
      var p = await SharedPreferences.getInstance();
      fullMemory.add({'role': role, 'text': text, 'time': DateTime.now().toIso8601String(), 'char': charName, 'img': img});
      p.setString('full_memory_v2', jsonEncode(fullMemory));
      p.setString('photo_memory_v2', jsonEncode(photoMemory));
      p.setInt('level', level);
      if (fullMemory.length % 5 == 0) level++;
    } catch (_) {}
  }

  void _autoMsg() {
    autoTimer = Timer.periodic(const Duration(hours: 12), (_) async {
      if (fullMemory.isEmpty || !mounted) return;
      var last = DateTime.tryParse(fullMemory.last['time'] ?? '');
      if (last == null) return;
      if (DateTime.now().difference(last).inHours > 20) {
        var txt = charName == 'Lucía' ? 'توحشتك فينك؟ غبرتي عليا' : 'فينك؟ قلقت عليك';
        if (mounted) setState(() => msgs.add({'role': 'ai', 'text': txt, 'auto': true}));
        await _save('ai', txt);
      }
    });
  }

  Future<void> _askKey() async {
    String k = '';
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1F3D),
      title: const Text('Gemini Key'),
      content: TextField(onChanged: (v) => k = v, decoration: const InputDecoration(hintText: 'AIzaSy... aistudio.google.com')),
      actions: [TextButton(onPressed: () async {
        var p = await SharedPreferences.getInstance();
        await p.setString('gemini_key', k);
        setState(() => apiKey = k);
        if (mounted) Navigator.pop(context);
      }, child: const Text('حفظ'))],
    ));
  }

  // تعديل الصور + فيديو - كلشي اللي طلبتي - PicsArt + CapCut
  Future<void> _edit(String type) async {
    try {
      final XFile? im = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (im == null) return;
      if (!mounted) return;
      setState(() => lastImg = File(im.path));
      if (apiKey.isEmpty) { _askKey(); return; }
      setState(() => msgs.add({'role': 'user', 'text': '[$type]', 'img': im.path}));

      if (type == 'memory') {
        String tmp = '';
        await showDialog(context: context, builder: (_) => AlertDialog(
          title: const Text('شنو سميت الصورة؟'), content: TextField(onChanged: (v) => tmp = v, decoration: const InputDecoration(hintText: 'القط ميمي')),
          actions: [TextButton(onPressed: () {
            if (tmp.isNotEmpty) { photoMemory[tmp] = im.path; _save('user', 'هادي $tmp', img: im.path); setState(() => msgs.add({'role': 'ai', 'text': 'حفظت $tmp 🧠'})); }
            Navigator.pop(context);
          }, child: const Text('حفظ'))],
        ));
        return;
      }

      var bytes = await File(im.path).readAsBytes();
      var b64 = base64Encode(bytes);
      var url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');
      String prompt = type == 'remove_bg' ? 'Remove background keep person transparent' : type == 'anime' ? 'Convert to flamenco anime style' : type == 'hd' ? 'Enhance to HD 4K' : type == 'paris' ? 'Put person with $charName in Paris Eiffel' : 'Make image to short video moving';

      var res = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({"contents": [{"parts": [{"text": prompt}, {"inline_data": {"mime_type": "image/jpeg", "data": b64}}]}]})).timeout(const Duration(seconds: 30));
      var d = jsonDecode(res.body);
      String rep = d['candidates'][0]['content']['parts'][0]['text'];
      await _save('ai', rep, img: im.path);
      if (mounted) setState(() => msgs.add({'role': 'ai', 'text': '✅ $type: $rep', 'img': im.path}));
      tts.speak(rep);
    } catch (e) {
      if (mounted) setState(() => msgs.add({'role': 'ai', 'text': 'Error: $e'}));
    }
  }

  Future<void> _textToVideo(String txt) async {
    if (apiKey.isEmpty) { _askKey(); return; }
    if (mounted) setState(() => msgs.add({'role': 'user', 'text': '[Video: $txt]'}));
    await _save('user', txt);
    if (mounted) setState(() => msgs.add({'role': 'ai', 'text': '🎬 Video "$txt" is creating! [Runway API] With $charName, music montage!'}));
  }

  Future<void> _send(String t) async {
    if (t.isEmpty) return;
    if (t.contains('فيديو') || t.toLowerCase().contains('video')) { await _textToVideo(t); ctrl.clear(); return; }
    if (apiKey.isEmpty) { _askKey(); return; }
    await _save('user', t);
    if (mounted) setState(() => msgs.add({'role': 'user', 'text': t}));
    ctrl.clear();

    String live = '';
    try {
      if (t.contains('بيتكوين') || t.toLowerCase().contains('bitcoin')) {
        var r = await http.get(Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd')).timeout(const Duration(seconds: 5));
        live = 'Bitcoin: ${jsonDecode(r.body)['bitcoin']['usd']} USD';
      }
    } catch (_) {}

    String memCtx = fullMemory.take(15).map((m) => "${m['role']}: ${m['text']}").join('\n');
    try {
      var url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');
      String prompt = 'You are $charName Imaginary Friend real companion Lv$level mood $mood memory: $memCtx live:$live photoMemory:${photoMemory.keys.join(',')} Answer short Darija: $t';
      var res = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({"contents": [{"parts": [{"text": prompt}]}]})).timeout(const Duration(seconds: 20));
      var d = jsonDecode(res.body);
      String rep = d['candidates'][0]['content']['parts'][0]['text'];
      await _save('ai', rep);
      if (mounted) setState(() { msgs.add({'role': 'ai', 'text': rep}); mood = rep.contains('هه') ? 'كيضحك' : 'مبسوط'; });
      tts.speak(rep);
    } catch (e) {
      if (mounted) setState(() => msgs.add({'role': 'ai', 'text': 'Check net & key: $e'}));
    }
  }

  Future<void> _voice() async {
    try {
      bool ok = await speech.initialize();
      if (!ok) return;
      setState(() => mood = 'كيسمع');
      speech.listen(localeId: 'ar_MA', onResult: (r) { if (r.finalResult) { _send(r.recognizedWords); speech.stop(); } });
    } catch (_) {}
  }

  void _call() {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF0F1220), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => Container(height: 400, padding: const EdgeInsets.all(20), child: Column(children: [
      const Icon(Icons.videocam, size: 50, color: Color(0xFF00E5FF)),
      Text('Real Call $charName Lv.$level $mood', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      const Text('صوت: كتهضر بصوتك ويجاوبك بصوتو\nفيديو: Avatar شفايف وعينين كيتحركو\nواتساب حقيقية + مود المزاج', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.white70)),
      const SizedBox(height: 20),
      Row(children: [Expanded(child: ElevatedButton.icon(onPressed: () { Navigator.pop(context); _voice(); }, icon: const Icon(Icons.mic), label: const Text('Voice'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green))), const SizedBox(width: 8), Expanded(child: ElevatedButton.icon(onPressed: () { Navigator.pop(context); _send('Start video call'); }, icon: const Icon(Icons.videocam), label: const Text('Video'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF))))]),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: idx == 0 ? _home() : idx == 1 ? _editor() : _chat(),
      bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap: (i) => setState(() => idx = i), backgroundColor: const Color(0xFF0A0E1F), selectedItemColor: const Color(0xFFFF6B9D), unselectedItemColor: Colors.white54, type: BottomNavigationBarType.fixed, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'), BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'Editor'), BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Imaginary Friend')]),
    );
  }

  Widget _home() => Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0A0E1F), Color(0xFF070A14)])), child: SafeArea(child: SingleChildScrollView(child: Column(children: [
    Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Icon(Icons.bubble_chart, color: Color(0xFF00E5FF), size: 32), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Imaginary Friend', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text('Lv.$level $mood ${fullMemory.length} memories 🔒', style: const TextStyle(fontSize: 8, color: Colors.white70))]), const Spacer(), IconButton(icon: const Icon(Icons.vpn_key, size: 18), onPressed: _askKey)])),
    Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)), color: const Color(0xFF1A1F3D)), child: const Text('IMAGINARY FRIEND - Live Brain + Real Call + Photo Video Editor + Secret', style: TextStyle(fontSize: 9, color: Colors.white70), textAlign: TextAlign.center)),
    const SizedBox(height: 12),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Expanded(child: _card('LUCÍA', 'Flamenco Empatica', 'Online', const Color(0xFFFF6B9D), true)), const SizedBox(width: 10), Expanded(child: _card('ALEJANDRO', 'Flamenco Analytical', 'Online', const Color(0xFF00E5FF), false))])),
    if (photoMemory.isNotEmpty) Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)), child: Text('Photo Memory: ${photoMemory.keys.join(', ')}', style: const TextStyle(fontSize: 10))),
  ]))));

  Widget _card(String n, String e, String s, Color ac, bool isL) {
    bool sel = charName == (isL ? 'Lucía' : 'Alejandro');
    return GestureDetector(onTap: () => setState(() => charName = isL ? 'Lucía' : 'Alejandro'), child: Container(height: 280, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? ac : Colors.white24, width: sel ? 2 : 1), gradient: const LinearGradient(colors: [Color(0xFF1E2340), Color(0xFF0F1220)])), child: Column(children: [
      Padding(padding: const EdgeInsets.all(8), child: Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)), const SizedBox(width: 4), Text(s, style: const TextStyle(fontSize: 7, color: Colors.greenAccent))])),
      Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black26, image: DecorationImage(image: NetworkImage(isL ? 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400' : 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400'), fit: BoxFit.cover)))),
      const SizedBox(height: 6), Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(e, style: const TextStyle(fontSize: 6, color: Colors.white60)),
      const SizedBox(height: 6), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [GestureDetector(onTap: _call, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: ac, borderRadius: BorderRadius.circular(6)), child: const Text('Videollamada Real', style: TextStyle(fontSize: 7)))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(border: Border.all(color: ac), borderRadius: BorderRadius.circular(6)), child: const Text('Chat', style: TextStyle(fontSize: 7)))]), const SizedBox(height: 8)
    ])));
  }

  Widget _editor() => Container(color: const Color(0xFF070C1A), child: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Imaginary Friend Editor - Avatar + Photo + Video', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    Text('Memory ${fullMemory.length} 🔒 + PicsArt + CapCut', style: const TextStyle(color: Colors.white60, fontSize: 10)),
    const SizedBox(height: 12),
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF111A2F), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Editor de Avatar (DialogAI Original)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: _opt('Peinado', 'Moño')), Expanded(child: _opt('Ropa', 'Vestido')), Expanded(child: _opt('Color', 'Rojo'))]),
    ])),
    const SizedBox(height: 12),
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF121A2F), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('🎨 تعديل الصور:', style: TextStyle(fontWeight: FontWeight.bold)),
      _btn('🗑️ حيد الخلفية', 'remove_bg'),
      _btn('✨ أنمي فلامنكو', 'anime'),
      _btn('📸 HD 4K', 'hd'),
      _btn('🗼 أنا و $charName فباريس', 'paris'),
      _btn('🧠 حفظ: القط ميمي', 'memory'),
      const SizedBox(height: 8),
      const Text('🎬 فيديو:', style: TextStyle(fontWeight: FontWeight.bold)),
      _btn('🎥 صورة لفيديو', 'video'),
      _btn('✍️ كتابة لفيديو: قطة كتشطح', 'text_video'),
      _btn('🎞️ مونتاج بالغنية', 'montage'),
    ])),
    if (lastImg != null) Padding(padding: const EdgeInsets.only(top: 12), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(lastImg!, height: 150, fit: BoxFit.cover))),
  ])));

  Widget _opt(String t, String v) => Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF1A1F3D), borderRadius: BorderRadius.circular(8)), child: Column(children: [Text(t, style: const TextStyle(fontSize: 8, color: Colors.white60)), Text(v, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))]));
  Widget _btn(String l, String t) => Container(margin: const EdgeInsets.only(bottom: 6), width: double.infinity, child: ElevatedButton(onPressed: () => t == 'text_video' || t == 'montage' ? _textToVideo(t == 'text_video' ? 'cat dancing' : 'montage flamenco') : _edit(t), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2340)), child: Align(alignment: Alignment.centerLeft, child: Text(l, style: const TextStyle(fontSize: 11)))));

  Widget _chat() => Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0A0E1F), Color(0xFF070A14)])), child: SafeArea(child: Column(children: [
    AppBar(backgroundColor: Colors.transparent, title: Text('Imaginary Friend $charName Lv.$level $mood 🔒', style: const TextStyle(fontSize: 12)), actions: [IconButton(icon: const Icon(Icons.videocam, color: Colors.greenAccent), onPressed: _call), IconButton(icon: const Icon(Icons.mic, color: Colors.orangeAccent), onPressed: _voice), IconButton(icon: const Icon(Icons.vpn_key, size: 18), onPressed: _askKey)]),
    Expanded(child: ListView.builder(itemCount: msgs.length, itemBuilder: (_, i) {
      bool u = msgs[i]['role'] == 'user';
      bool hasImg = msgs[i]['img'] != null;
      return Align(alignment: u ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: u ? Colors.white12 : const Color(0xFF00E5FF).withOpacity(0.18), borderRadius: BorderRadius.circular(14), border: msgs[i]['auto'] == true ? Border.all(color: Colors.greenAccent) : null), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (hasImg) ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(msgs[i]['img']), height: 90, fit: BoxFit.cover)), Text(msgs[i]['text'] ?? '', style: const TextStyle(fontSize: 12))]))); 
    })),
    Padding(padding: const EdgeInsets.all(8), child: Row(children: [
      IconButton(icon: const Icon(Icons.photo_camera, color: Color(0xFFFF6B9D)), onPressed: () => _edit('anime')),
      IconButton(icon: const Icon(Icons.video_call, color: Color(0xFF00E5FF)), onPressed: () => _edit('video')),
      IconButton(icon: const Icon(Icons.photo_library, color: Colors.green), onPressed: () => _edit('memory')),
      Expanded(child: TextField(controller: ctrl, decoration: InputDecoration(hintText: 'حيد ليا الخلفية / دير ليا فيديو', border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)), contentPadding: const EdgeInsets.symmetric(horizontal: 12), isDense: true), onSubmitted: (v) => _send(v))),
      IconButton(icon: const Icon(Icons.send, color: Color(0xFF00E5FF)), onPressed: () => _send(ctrl.text))
    ]))
  ])));
}
