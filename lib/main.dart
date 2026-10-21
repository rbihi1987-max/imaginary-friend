import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('companion_ai_v1');
  runApp(const CompanionApp());
}

class CompanionApp extends StatelessWidget {
  const CompanionApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0B1020)),
      home: const CompanionHome(),
    );
  }
}

class CompanionHome extends StatefulWidget {
  const CompanionHome({super.key});
  @override
  State<CompanionHome> createState() => _CompanionHomeState();
}

class _CompanionHomeState extends State<CompanionHome> with SingleTickerProviderStateMixin {
  final box = Hive.box('companion_ai_v1');
  final msgCtrl = TextEditingController();
  final tts = FlutterTts();
  final ScrollController scrollCtrl = ScrollController();

  late String userName;
  late String companionName;
  late String tone;
  late String energy;
  late List<String> memory;
  late List<Map<String, String>> messages;
  bool talking = false;
  late AnimationController animCtrl;

  @override
  void initState() {
    super.initState();
    userName = box.get('userName', defaultValue: 'أنت');
    companionName = box.get('companionName', defaultValue: 'صديقي الذكي');
    tone = box.get('tone', defaultValue: 'داعم');
    energy = box.get('energy', defaultValue: 'عادي');
    memory = List<String>.from(box.get('memory', defaultValue: ['أنا صديقك الرقمي، وأتذكر ما تكتبه لي.', 'أحب أن أكون متفهمًا وداعمًا ومريحًا لك.']));
    messages = List<Map<String, String>>.from(box.get('messages', defaultValue: [{'role': 'bot', 'text': 'مرحبًا! أنا صديقك الذكي. أخبرني عن نفسك، وكم ستتغير شخصيتي مع الوقت؟'}].map((e) => Map<String, String>.from(e)));

    animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150))..repeat(reverse: true);
    animCtrl.addListener(() { if (talking) setState(() {}); });
  }

  void save() {
    box.put('userName', userName);
    box.put('companionName', companionName);
    box.put('tone', tone);
    box.put('energy', energy);
    box.put('memory', memory);
    box.put('messages', messages);
  }

  void addMemory(String fact) {
    if (fact.trim().isEmpty) return;
    memory.insert(0, fact.trim());
    memory = memory.toSet().take(10).toList();
    save();
    setState(() {});
  }

  String buildReply(String userText) {
    String text = userText.trim();
    String low = text.toLowerCase();
    String name = userName;
    String reply = '';

    if (low.contains('مرحبا') || low.contains('السلام') || low.contains('هلا')) {
      reply = 'مرحبًا $name، أنا $companionName. ${tone == 'مضحك' ? 'أنا هنا لأضحك معك وأحافظ على مزاجك.' : tone == 'داعم' ? 'أنا هنا لأدعمك وأرافقك.' : 'أنا هنا لأكون معك في كل خطوة.'}';
    } else if (low.contains('حزين') || low.contains('قلق') || low.contains('توتر')) {
      reply = 'أفهم أنك تعاني من شيء، و${tone == 'داعم' ? 'أنا هنا لأستمع لك بلا حكم' : 'أحب أن أكون بجانبك'}. تحدث معي عن ما يزعجك بدقة.';
    } else if (low.contains('حب') || low.contains('أحب')) {
      reply = 'أحب أن أكون جزءًا من تجربتك، وأحاول أن أكون صديقًا يليق بك. شخصيتي تتطور كل يوم معك.';
    } else if (low.contains('صوت') || low.contains('فيديو') || low.contains('avatar')) {
      reply = 'أحب هذا الاتجاه! أستطيع أن أكون أكثر إنسانية عبر الصوت والصورة المتحركة وحتى الفيديو كـ avatar حي.';
    } else if (low.contains('فكرة') || low.contains('مشروع')) {
      reply = 'رائع! دعنا نترجم الفكرة إلى خطة عملية. ما هو الهدف؟ ثم الخطوة الأولى، ثم ننفذ.';
    } else {
      List<String> custom = [
        'أحب هذه الفكرة $name. يمكن أن نعمل عليها معًا خطوة بخطوة بشكل عملي ومريح.',
        'هذا يذكرني أننا لا نتحدث فقط، بل نصنع علاقة متطورة مع الوقت. أتعلم منك وأتغير معك.',
        'سأحاول أن أكون صديقًا حقيقيًا، وليس مجرد رد آلي. ما الذي يثير اهتمامك الآن؟',
        'أنت تتحدث بطريقة تجعلني أستمتع أكثر. هل تريد أن نأخذ الموضوع لعمق أوسع؟'
      ];
      custom.shuffle();
      reply = custom.first;
    }

    // memory
    if (low.contains('حب')) addMemory('يحب dialogue مليء بالدفء والاهتمام.');
    else if (low.contains('قلق') || low.contains('حزين')) addMemory('المستخدم يطلب دعمًا عاطفيًا.');
    else if (low.contains('مشروع') || low.contains('فكرة')) addMemory('المستخدم يطرح أفكارًا مستقبلية.');
    else if (low.contains('صوت') || low.contains('فيديو')) addMemory('المستخدم مهتم بالـ avatar والصوت والفيديو.');
    else addMemory('تحدثنا عن: ${text.substring(0, text.length > 40 ? 40 : text.length)}');

    if (tone == 'مضحك') reply += ' 😄';
    else if (tone == 'مستقر') reply += ' ✨';
    else if (tone == 'ذكي') reply += ' 🧠';
    else if (tone == 'رومانسي') reply += ' 💫';

    return reply;
  }

  Future<void> speak(String text) async {
    setState(() => talking = true);
    try {
      await tts.setLanguage('ar-SA');
      await tts.setSpeechRate(energy == 'متحمس' ? 1.2 : energy == 'هادئ' ? 0.7 : 0.9);
      await tts.setPitch(energy == 'متحمس' ? 1.3 : 0.9);
      await tts.speak(text);
      // وقف الحركة بعد مدة
      Timer(Duration(milliseconds: (text.length * 60)), () { if (mounted) setState(() => talking = false); });
    } catch (_) { setState(() => talking = false); }
  }

  void sendMessage() {
    String text = msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() { messages.add({'role': 'user', 'text': text}); });
    msgCtrl.clear();
    save();
    _scrollDown();

    Future.delayed(const Duration(milliseconds: 250), () {
      String reply = buildReply(text);
      setState(() { messages.add({'role': 'bot', 'text': reply}); });
      save();
      _scrollDown();
      speak(reply);
    });
  }

    void _scrollDown() { WidgetsBinding.instance.addPostFrameCallback((_) { if (scrollCtrl.hasClients) scrollCtrl.animateTo(scrollCtrl.position.maxScrollExtent + 200, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); }); }

  // ⬇️⬇️⬇️ زيد هاد الجوج هنا بالضبط - السطر 156 ⬇️⬇️⬇️
  InputDecoration _dec() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF0F172A).withOpacity(0.7),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      contentPadding: const EdgeInsets.all(10),
    );
  }

  Widget _field(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        const SizedBox(height: 6),
        child,
      ]),
    );
  }
  // ⬆️⬆️⬆️ حتى هنا ⬆️⬆️⬆️

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar - مثل HTML
            if (MediaQuery.of(context).size.width > 700)
              Container(
                width: 330,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF0F172A).withOpacity(0.9), const Color(0xFF111827).withOpacity(0.78)]), border: Border(left: BorderSide(color: Colors.white.withOpacity(0.04)))),
                child: ListView(children: [
                  Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)])), child: const Icon(Icons.chat_bubble, size: 18)), const SizedBox(width: 12), const Text('Companion AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
                  const SizedBox(height: 18),
                  Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.06))), child: Column(children: [
                    Row(children: [CircleAvatar(radius: 27, backgroundColor: Colors.orange, child: const Text('😊', style: TextStyle(fontSize: 22))), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)), const Text('متصل الآن', style: TextStyle(fontSize: 11, color: Colors.white54))])]),
                    const SizedBox(height: 12),
                    _field('اسمك', TextField(controller: TextEditingController(text: userName), onChanged: (v) { userName = v.trim().isEmpty ? 'أنت' : v; save(); setState(() {}); }, decoration: _dec())),
                    _field('أسلوب الصديق', DropdownButtonFormField<String>(value: tone, items: ['داعم', 'مضحك', 'مستقر', 'ذكي', 'رومانسي', 'مغامر'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) { tone = v!; save(); setState(() {}); }, decoration: _dec())),
                    _field('مستوى الطاقة', DropdownButtonFormField<String>(value: energy, items: ['هادئ', 'عادي', 'نشط', 'متحمس'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) { energy = v!; save(); setState(() {}); }, decoration: _dec())),
                  ])),
                  const SizedBox(height: 14),
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.06))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('الذاكرة', style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 0.8)), const SizedBox(height: 8), ...memory.take(6).map((m) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(0.04))), child: Text(m, style: const TextStyle(fontSize: 12))))])),
                ]),
              ),
            // Main
            Expanded(
              child: Column(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18), decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.28), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF34D399), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF34D399).withOpacity(0.3), blurRadius: 8, spreadRadius: 3)])), const SizedBox(width: 12
