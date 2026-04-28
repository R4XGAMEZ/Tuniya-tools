import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/gemini_service.dart';

class AiQuizGenScreen extends StatefulWidget {
  const AiQuizGenScreen({super.key});
  @override
  State<AiQuizGenScreen> createState() => _AiQuizGenScreenState();
}

class _AiQuizGenScreenState extends State<AiQuizGenScreen> {
  final _topicCtrl = TextEditingController();
  int _numQ = 5;
  String _difficulty = 'Medium';
  bool _loading = false;

  // Quiz state
  List<Map<String, dynamic>> _questions = [];
  int _current = 0;
  int? _selected;
  int _score = 0;
  bool _quizDone = false;
  bool _answered = false;

  final _difficulties = ['Easy', 'Medium', 'Hard'];

  Future<void> _generateQuiz() async {
    final topic = _topicCtrl.text.trim();
    if (topic.isEmpty) return;
    if (!GeminiService.instance.isReady) {
      _snack('Gemini API key Settings mein daal do', isError: true);
      return;
    }
    setState(() { _loading = true; _questions = []; _current = 0; _score = 0; _quizDone = false; });
    try {
      final prompt = '''Generate exactly $_numQ MCQ questions on topic: "$topic" (difficulty: $_difficulty).
Return ONLY this format, nothing else:
Q1: [question]
A: [option A]
B: [option B]
C: [option C]
D: [option D]
ANS: [A/B/C/D]

Q2: ...''';
      final raw = await GeminiService.instance.generateContent(prompt);
      if (!mounted) return;
      setState(() => _questions = _parseQuiz(raw));
    } catch (e) {
      _snack('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _parseQuiz(String raw) {
    final result = <Map<String, dynamic>>[];
    final blocks = raw.split(RegExp(r'Q\d+:'));
    for (final block in blocks) {
      if (block.trim().isEmpty) continue;
      final lines = block.trim().split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      if (lines.length < 6) continue;
      final question = lines[0];
      final opts = <String>[];
      String ans = 'A';
      for (final l in lines.skip(1)) {
        if (l.startsWith('A:')) opts.add(l.substring(2).trim());
        else if (l.startsWith('B:')) opts.add(l.substring(2).trim());
        else if (l.startsWith('C:')) opts.add(l.substring(2).trim());
        else if (l.startsWith('D:')) opts.add(l.substring(2).trim());
        else if (l.startsWith('ANS:')) ans = l.substring(4).trim();
      }
      if (opts.length == 4) {
        final ansIdx = ['A','B','C','D'].indexOf(ans);
        result.add({'q': question, 'opts': opts, 'ans': ansIdx < 0 ? 0 : ansIdx});
      }
    }
    return result;
  }

  void _answer(int idx) {
    if (_answered) return;
    final correct = _questions[_current]['ans'] == idx;
    setState(() {
      _selected = idx;
      _answered = true;
      if (correct) _score++;
    });
  }

  void _next() {
    if (_current + 1 >= _questions.length) {
      setState(() => _quizDone = true);
    } else {
      setState(() { _current++; _selected = null; _answered = false; });
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.rajdhani()),
      backgroundColor: isError ? AppTheme.red : AppTheme.purple,
    ));
  }

  @override
  void dispose() { _topicCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('AI Quiz Generator', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [
          if (_questions.isNotEmpty)
            TextButton(onPressed: () => setState(() { _questions = []; _current = 0; _score = 0; _quizDone = false; }),
              child: Text('New', style: GoogleFonts.rajdhani(color: AppTheme.purple))),
        ],
      ),
      body: _questions.isEmpty ? _buildSetup() : _quizDone ? _buildResult() : _buildQuiz(),
    );
  }

  Widget _buildSetup() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Topic', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
            child: TextField(
              controller: _topicCtrl,
              style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Photosynthesis, World War 2, Algebra...',
                hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                contentPadding: const EdgeInsets.all(12),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Questions: $_numQ', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          Slider(
            value: _numQ.toDouble(),
            min: 3, max: 15, divisions: 12,
            activeColor: AppTheme.purple,
            onChanged: (v) => setState(() => _numQ = v.toInt()),
          ),
          const SizedBox(height: 8),
          Text('Difficulty', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            children: _difficulties.map((d) {
              final sel = d == _difficulty;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = d),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.purple : AppTheme.cardBg2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor),
                    ),
                    child: Center(child: Text(d, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontWeight: FontWeight.bold))),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _generateQuiz,
              icon: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.quiz_outlined),
              label: Text(_loading ? 'Generating Quiz...' : 'Generate Quiz', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purple, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    final q = _questions[_current];
    final opts = q['opts'] as List<String>;
    final ans = q['ans'] as int;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Q ${_current + 1}/${_questions.length}', style: GoogleFonts.rajdhani(color: AppTheme.purple, fontWeight: FontWeight.bold)),
              Text('Score: $_score', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: (_current + 1) / _questions.length, backgroundColor: AppTheme.cardBg2, color: AppTheme.purple),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
            child: Text(q['q'] as String, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold, height: 1.5)),
          ),
          const SizedBox(height: 16),
          ...List.generate(4, (i) {
            Color bg = AppTheme.cardBg2;
            Color border = AppTheme.borderColor;
            if (_answered) {
              if (i == ans) { bg = Colors.green.withValues(alpha: 0.2); border = Colors.green; }
              else if (i == _selected) { bg = AppTheme.red.withValues(alpha: 0.2); border = AppTheme.red; }
            }
            return GestureDetector(
              onTap: () => _answer(i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: AppTheme.cardBg, shape: BoxShape.circle, border: Border.all(color: border)),
                      child: Center(child: Text(['A','B','C','D'][i], style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(opts[i], style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14))),
                  ],
                ),
              ),
            );
          }),
          if (_answered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(_current + 1 >= _questions.length ? 'See Result' : 'Next →', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final pct = (_score / _questions.length * 100).toInt();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pct >= 80 ? '🎉' : pct >= 50 ? '👍' : '💪', style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text('Quiz Complete!', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 22)),
            const SizedBox(height: 8),
            Text('$_score / ${_questions.length} correct ($pct%)', style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 18)),
            const SizedBox(height: 8),
            Text(pct >= 80 ? 'Excellent! Bahut badiya!' : pct >= 50 ? 'Good job! Aur practice karo!' : 'Keep going! Baar baar practice karo!',
              style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() { _questions = []; _quizDone = false; }),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
              child: Text('New Quiz', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
