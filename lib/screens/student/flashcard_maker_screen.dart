import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class FlashcardMakerScreen extends StatefulWidget {
  const FlashcardMakerScreen({super.key});
  @override
  State<FlashcardMakerScreen> createState() => _FlashcardMakerScreenState();
}

class _FlashcardMakerScreenState extends State<FlashcardMakerScreen> {
  final _ctrl = TextEditingController();
  List<Map<String, String>> _cards = [];
  int _current = 0;
  bool _flipped = false;
  bool _loading = false;

  Future<void> _generate() async {
    final topic = _ctrl.text.trim();
    if (topic.isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _cards = []; _current = 0; _flipped = false; });
    try {
      final prompt = '''Generate 10 flashcards for: "$topic"
Format exactly like this, nothing else:
FRONT: [term or question]
BACK: [definition or answer]

FRONT: ...
BACK: ...''';
      final raw = await GeminiService.instance.generateContent(prompt);
      if (!mounted) return;
      setState(() => _cards = _parse(raw));
    } catch (e) {
      _snack('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<Map<String, String>> _parse(String raw) {
    final cards = <Map<String, String>>[];
    final lines = raw.split('\n');
    String front = '', back = '';
    for (final line in lines) {
      final l = line.trim();
      if (l.startsWith('FRONT:')) front = l.substring(6).trim();
      else if (l.startsWith('BACK:')) {
        back = l.substring(5).trim();
        if (front.isNotEmpty && back.isNotEmpty) {
          cards.add({'front': front, 'back': back});
          front = ''; back = '';
        }
      }
    }
    return cards;
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.rajdhani()),
      backgroundColor: isError ? AppTheme.red : AppTheme.purple,
    ));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Flashcard Maker', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [
          if (_cards.isNotEmpty)
            TextButton(onPressed: () => setState(() { _cards = []; }), child: Text('New', style: GoogleFonts.rajdhani(color: AppTheme.purple))),
        ],
      ),
      body: _cards.isEmpty ? _buildSetup() : _buildCards(),
    );
  }

  Widget _buildSetup() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
            child: TextField(
              controller: _ctrl,
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Topic ya notes paste karo (e.g. Periodic Table, Indian History)',
                hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
              ),
              maxLines: 5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _generate,
              icon: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.style_outlined),
              label: Text(_loading ? 'Generating...' : 'Generate Flashcards', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCards() {
    final card = _cards[_current];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_current + 1} / ${_cards.length}', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary)),
              Text('Tap card to flip', style: GoogleFonts.rajdhani(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ),
        LinearProgressIndicator(value: (_current + 1) / _cards.length, backgroundColor: AppTheme.cardBg2, color: AppTheme.purple),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () => setState(() => _flipped = !_flipped),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_flipped),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _flipped ? AppTheme.purple.withOpacity(0.15) : AppTheme.cardBg2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _flipped ? AppTheme.purple : AppTheme.borderColor, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_flipped ? 'ANSWER' : 'QUESTION', style: GoogleFonts.rajdhani(color: _flipped ? AppTheme.purple : AppTheme.textSecondary, fontSize: 12, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(_flipped ? card['back']! : card['front']!,
                      style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold, height: 1.5),
                      textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _current > 0 ? () => setState(() { _current--; _flipped = false; }) : null,
              icon: const Icon(Icons.arrow_back_ios, color: AppTheme.purple),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => setState(() => _flipped = !_flipped),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cardBg2, foregroundColor: AppTheme.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Flip', style: GoogleFonts.rajdhani(fontSize: 14)),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: _current < _cards.length - 1 ? () => setState(() { _current++; _flipped = false; }) : null,
              icon: const Icon(Icons.arrow_forward_ios, color: AppTheme.purple),
            ),
          ],
        ),
      ],
    );
  }
}
