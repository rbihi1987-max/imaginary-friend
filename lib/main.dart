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
        messages = (box.get('messages', defaultValue: [{'role': 'bot', 'text': 'مرحبا! انا صديقك الذكي'}]) as List).map((e) => Map<String, String>.from(e as Map)).toList();
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
                  Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF34D399), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF34D399).withOpacity(0.3), blurRadius: 8, spreadRadius: 3)])), const SizedBox(width: 12), Text(companionName, style: const TextStyle(fontWeight: FontWeight.bold))]),
                  Row(children: [_chip('تغيير مزاجه', true, () { List<String> moods = ['داعم', 'مضحك', 'مستقر', 'ذكي', 'رومانسي', 'مغامر']; int i = moods.indexOf(tone); tone = moods[(i + 1) % moods.length]; save(); setState(() { messages.add({'role': 'bot', 'text': 'أصبحت أكثر $tone معك.'}); }); _scrollDown(); }), const SizedBox(width: 8), _chip('مسح', false, () { setState(() { messages = [{'role': 'bot', 'text': 'تمت المحادثة. جاهز لبدء صفحة جديدة.'}]; memory = ['أنا صديقك الرقمي.']; }); save(); })]),
                ])),
                Expanded(child: wide ? Row(children: [Expanded(flex: 11, child: _chatPanel()), const SizedBox(width: 20), Expanded(flex: 9, child: _avatarPanel())]) : Column(children: [Expanded(child: _chatPanel()), SizedBox(height: 200, child: _avatarPanel())])),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool primary, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: primary ? const Color(0xFF4F46E5) : Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(20)), child: Text(label, style: const TextStyle(fontSize: 11))));
  }

  Widget _chatPanel() {
    return Container(margin: const EdgeInsets.fromLTRB(20, 18, 0, 12), decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.45), borderRadius: BorderRadius.circular(24)), child: Column(children: [
      Expanded(child: ListView.builder(controller: scrollCtrl, padding: const EdgeInsets.all(18), itemCount: messages.length, itemBuilder: (c, i) { var m = messages[i]; bool isUser = m['role'] == 'user'; return Align(alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isUser ? const Color(0xFF4F46E5) : const Color(0xFF1E293B), borderRadius: BorderRadius.circular(18)), child: Text(m['text']!))); })),
      Container(padding: const EdgeInsets.all(14), child: Row(children: [Expanded(child: TextField(controller: msgCtrl, decoration: InputDecoration(hintText: 'اكتب...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))), onSubmitted: (_) => sendMessage())), const SizedBox(width: 12), ElevatedButton(onPressed: sendMessage, child: const Text('إرسال'))])),
    ]));
  }

  Widget _avatarPanel() {
    double mouthH = talking ? 10 + animCtrl.value * 18 : 6;
    return Container(margin: const EdgeInsets.fromLTRB(0, 18, 20, 12), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.7), borderRadius: BorderRadius.circular(24)), child: Column(children: [
      Expanded(child: Center(child: SizedBox(width: 180, height: 300, child: Stack(children: [
        Positioned(top: 28, left: 15, child: Container(width: 150, height: 170, decoration: BoxDecoration(color: const Color(0xFFF8D2AF), borderRadius: BorderRadius.circular(60)))),
        Positioned(top: 108, left: 46, child: Container(width: 18, height: 24, decoration: const BoxDecoration(color: Color(0xFF111827), shape: BoxShape.circle))),
        Positioned(top: 108, right: 46, child: Container(width: 18, height: 24, decoration: const BoxDecoration(color: Color(0xFF111827), shape: BoxShape.circle))),
        Positioned(top: 164, left: 63, child: Container(width: 54, height: mouthH + 10, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF9A3F3F), width: 5)), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))))),
        Positioned(bottom: 14, left: 0, child: Container(width: 180, height: 120, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)]), borderRadius: BorderRadius.circular(30)))),
      ])))),
          Text('الذاكرة: ${memory.length}'),
      ]),
    );
  }
}
