import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class RandomTopicPickerScreen extends StatefulWidget {
  const RandomTopicPickerScreen({super.key});
  @override
  State<RandomTopicPickerScreen> createState() => _RandomTopicPickerScreenState();
}

class _RandomTopicPickerScreenState extends State<RandomTopicPickerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _spinAnim;
  bool _spinning = false;
  String? _picked;
  String _category = 'All';

  final Map<String, List<Map<String, String>>> _topicsByCategory = {
    'Science': [
      {'topic': 'Black Holes', 'desc': 'Infinite density ke regions jahan se light bhi escape nahi kar sakti'},
      {'topic': 'CRISPR Gene Editing', 'desc': 'DNA ko precisely edit karne ki revolutionary technique'},
      {'topic': 'Quantum Entanglement', 'desc': 'Particles ka instant connection across any distance'},
      {'topic': 'Neuroplasticity', 'desc': 'Brain ki khud ko rewire karne ki amazing ability'},
      {'topic': 'The Fermi Paradox', 'desc': 'Aliens kahan hain? Universe ka biggest mystery'},
      {'topic': 'Plate Tectonics', 'desc': 'Earth ki moving plates aur earthquakes/volcanoes ka connection'},
      {'topic': 'Photosynthesis Deep Dive', 'desc': 'Sunlight ko food mein convert karne ka magical process'},
      {'topic': 'Dark Matter', 'desc': 'Universe ka 27% — jo dikhta nahi lekin exist karta hai'},
    ],
    'Tech': [
      {'topic': 'How Wi-Fi Works', 'desc': 'Radio waves se internet kaise milta hai?'},
      {'topic': 'Blockchain Basics', 'desc': 'Decentralized ledger technology ka concept'},
      {'topic': 'Machine Learning 101', 'desc': 'Computers khud kaise seekhte hain patterns se'},
      {'topic': 'How GPS Works', 'desc': 'Satellites se exact location kaise milti hai?'},
      {'topic': 'Encryption Explained', 'desc': 'Data ko secure rakhne ki mathematics'},
      {'topic': 'Compiler vs Interpreter', 'desc': 'Code run hone ke do alag tarike'},
      {'topic': 'How Touchscreens Work', 'desc': 'Capacitive technology ka magic'},
      {'topic': 'The Internet Protocol', 'desc': 'Data packets ka global journey'},
    ],
    'History': [
      {'topic': 'The Silk Road', 'desc': 'Ancient trade routes jinhone duniya badal di'},
      {'topic': 'The Industrial Revolution', 'desc': 'World ki pehli tech revolution'},
      {'topic': 'Indus Valley Civilization', 'desc': 'World ka pehla planned city — Mohenjo-daro'},
      {'topic': 'World War I Causes', 'desc': 'Ek assassination se global war kaise hua?'},
      {'topic': 'The Renaissance', 'desc': 'Europe mein art aur science ka rebirth'},
      {'topic': 'Indian Independence Movement', 'desc': 'Gandhi aur freedom fighters ki kahani'},
      {'topic': 'Space Race', 'desc': 'USA vs USSR — Moon tak ki race'},
      {'topic': 'The Cold War', 'desc': 'Nuclear threat ke saath decades ki tension'},
    ],
    'Math': [
      {'topic': 'Fibonacci in Nature', 'desc': 'Flowers, shells aur galaxies mein same pattern kyun?'},
      {'topic': 'Prime Numbers Mystery', 'desc': 'Primes ka infinite pattern — abhi bhi unsolved'},
      {'topic': 'Game Theory', 'desc': 'Decisions aur strategy ki mathematics'},
      {'topic': 'Chaos Theory', 'desc': 'Butterfly effect aur unpredictable systems'},
      {'topic': 'Probability Paradoxes', 'desc': 'Monty Hall problem aur brain-bending probability'},
      {'topic': 'Euler\'s Identity', 'desc': 'e^(iπ) + 1 = 0 — Most beautiful equation ever'},
      {'topic': 'Infinity Types', 'desc': 'Kuch infinities dusron se badi kyun hain?'},
      {'topic': 'The Riemann Hypothesis', 'desc': 'Million dollar unsolved math problem'},
    ],
    'Psychology': [
      {'topic': 'Cognitive Biases', 'desc': 'Brain kaise aur kyun galat decisions leta hai'},
      {'topic': 'The Dunning-Kruger Effect', 'desc': 'Jitna kam jano utna zyada confident'},
      {'topic': 'Classical Conditioning', 'desc': 'Pavlov ke dog experiments aur learning'},
      {'topic': 'Flow State', 'desc': 'Deep focus ki peak performance condition'},
      {'topic': 'Memory and Forgetting', 'desc': 'Ebbinghaus forgetting curve aur how to remember'},
      {'topic': 'Social Conformity', 'desc': 'Milgram experiments — obedience ka dark side'},
      {'topic': 'Growth vs Fixed Mindset', 'desc': 'Dweck ki research on how beliefs shape success'},
      {'topic': 'Sleep and the Brain', 'desc': 'Sleep ke dauran brain kya karta hai?'},
    ],
  };

  List<Map<String, String>> get _currentTopics {
    if (_category == 'All') {
      return _topicsByCategory.values.expand((e) => e).toList();
    }
    return _topicsByCategory[_category] ?? [];
  }

  final List<String> _categories = ['All', 'Science', 'Tech', 'History', 'Math', 'Psychology'];
  final _rng = Random();
  Map<String, String>? _pickedTopic;

  Future<void> _spinFunc() async {
    if (_spinning) return;
    setState(() { _spinning = true; _picked = null; _pickedTopic = null; });
    _ctrl.reset();
    await _ctrl.forward();
    final topics = _currentTopics;
    final selected = topics[_rng.nextInt(topics.length)];
    if (!mounted) return;
    setState(() {
      _spinning = false;
      _pickedTopic = selected;
      _picked = selected['topic'];
    });
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _spin = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Random Topic Picker', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Category', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _categories.map((c) {
              final sel = c == _category;
              return GestureDetector(
                onTap: () => setState(() { _category = c; _pickedTopic = null; _picked = null; }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.purple : AppTheme.cardBg2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor),
                  ),
                  child: Text(c, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                ),
              );
            }).toList()),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _spinFunc,
              child: AnimatedBuilder(
                animation: _spinAnim,
                builder: (_, child) => Transform.rotate(
                  angle: _spinning ? _spinAnim.value * 2 * pi * 3 : 0,
                  child: child,
                ),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.purple, AppTheme.purple.withOpacity(0.5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [BoxShadow(color: AppTheme.purple.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.casino_outlined, color: Colors.white, size: 40),
                      const SizedBox(height: 8),
                      Text('SPIN', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Tap to spin!', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 28),
            if (_spinning)
              const CircularProgressIndicator(color: AppTheme.purple),
            if (_pickedTopic != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.purple.withOpacity(0.6), width: 2),
                  boxShadow: [BoxShadow(color: AppTheme.purple.withOpacity(0.15), blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    Text('🎯 Aaj Seekho:', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(_pickedTopic!['topic']!, style: GoogleFonts.orbitron(color: AppTheme.purple, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    Text(_pickedTopic!['desc']!, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14, height: 1.5), textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _spinFunc,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text('Pick Again', style: GoogleFonts.rajdhani(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.purple,
                    side: const BorderSide(color: AppTheme.purple),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text('${_currentTopics.length} topics available in ${_category == 'All' ? 'all categories' : _category}',
                style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
